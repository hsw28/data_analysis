clear;
%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1 1 1 1 2 2 2 2];
day = [18, 22, 23, 24, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3];

thold = .15;
win = [-.25 .5];

[hpcRateHC, hpcRateLC] = deal([]);

fprintf('\n\n');

dPeakHpc = [];
dPeakCtx = [];


eCorr = [];

for E = 1:8;
    
    % LOAD THE DATA
    epoch = sprintf('sleep%d', ep(E));
    edir = sprintf('/data/%s/day%d', base{bId(E)}, day(E));
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));
    fprintf('Loading:%s\n', fullfile(edir, fName));
    mu = load( fullfile(edir, fName) );
    mu = mu.mu;
  
    muBursts = find_mua_bursts(mu);

    nBurst = size(muBursts,1);
    
    fprintf('Detected %d MU-Bursts', nBurst);
    
    
    % Filter MU-Bursts
    burstLen = diff(muBursts, [], 2);
    burstLenIdx = burstLen > thold;
    
    muBursts = muBursts(burstLenIdx,:);
    nBurst = size(muBursts,1);
    fprintf(', keeping %d\n', nBurst);
    
    muPkIdxHC = [];
    muPkIdxLC = [];
    
    for i = 1:nBurst
        
        b = muBursts(i,:);
        
        startIdx = find( b(1) == mu.ts, 1, 'first');
        
        muIdx =  mu.ts>=b(1) & mu.ts <= b(2) ;
        rateH = mu.hpc( muIdx );
        rateC = mu.ctx( muIdx );
        eCorr(i) = corr(rateH', rateC');
        
        [~, pk] = findpeaks(rateH); % <------- FIRST LOCAL MAX
        
        if numel(pk)<1
            continue
        end
        pk = pk + startIdx -1;
        
        if ( eCorr(i) <= 0 )
            muPkIdxLC = [muPkIdxLC, pk(1)];  %#ok
        else
            muPkIdxHC = [muPkIdxHC, pk(1)];  %#ok
        end
    end
    
    [mHpcHC, ~, ts, sampHpcHC] = meanTriggeredSignal( mu.ts( muPkIdxHC ), mu.ts, mu.hpc, win);
    [mHpcLC, ~, ~ , sampHpcLC] = meanTriggeredSignal( mu.ts( muPkIdxLC ), mu.ts, mu.hpc, win);
    
    hpcRateHC = [hpcRateHC; sampHpcHC];
    hpcRateLC = [hpcRateLC; sampHpcLC];
end

%%
% close all;
% figure;
% axes;
% [fHpc, xHpc] = ksdensity(dPeakHpc * 1000/mu.fs);
% [fCtx, xCtx] = ksdensity(dPeakCtx * 1000/mu.fs);
% 
% line(xHpc, fHpc, 'Color', 'b');
% line(xCtx, fCtx, 'Color', 'r');

%%
% bins = 0:5:250;
% 
% close all;
% figure;
% axes;
% [fHpc, xHpc] = hist(dPeakHpc * 1000/mu.fs, bins);
% [fCtx, xCtx] = hist(dPeakCtx * 1000/mu.fs, bins);
% 
% line(xHpc, smoothn(fHpc,2), 'Color', 'b');
% line(xCtx, smoothn(fCtx,2), 'Color', 'r');
% 




% %%
% close all;
% figure('Position', [1 353 1272 350]);
% ax(1) = axes('Position', [.03 .53 .96 .4]);
% ax(2) = axes('Position', [.03 .11 .96 .4]);
% 
% 
% 
% patch_browser( mu.ts, mu.ctx, 'Parent', ax(1), 'color', 'c');
% patch_browser( mu.ts, mu.hpc, 'Parent', ax(2), 'color', 'b');
% 
% % for i = 1:size(cFrames,1);
% %     line(cFrames(i,1) * [1 1], [0 500], 'color', 'g', 'Parent', ax(1));
% %     line(cFrames(i,2) * [1 1], [0 500], 'color', 'r', 'Parent', ax(1));
% % end
% 
% for i = 1:size(muBursts,1);
%     line(muBursts(i,1) * [1 1], [0 2000], 'color', 'g', 'Parent', ax(2));
%     line(muBursts(i,2) * [1 1], [0 2000], 'color', 'r', 'Parent', ax(2));
% end
% 
% linkaxes(ax,'x');
% 
% %%
% rmEmpty = @(x) (x(~cellfun(@isempty, x)));
% h = rmEmpty(sampHpc)';
% c = rmEmpty(sampCtx)';
% 
% h = cell2mat(h);
% c = cell2mat(c);
% 
% close all;
% 
% figure('Position', [300 56 500 650]);
% 
% nExample = floor((size(h,1)-1)/3);
% nExample = 8;
% 
% ax = [];
% y = .05; dy = .95 / nExample;
% for i = 1:nExample/2
%     ax((i*2)-1) = axes('Position', [.05 y .9 dy-.01]);
%     y = y + dy;
%     
%     line(ts,  h(i,:), 'color', 'r', 'parent', ax((i*2)-1));
%     
%     ax(i*2) = axes('Position', [.05 y .9 dy-.01]);
%     y = y + dy;
%     
%     line(ts,  c(i,:), 'color', 'b', 'parent', ax((i*2)));
%     
% end
% 
% %%
% figure('Position', [300 500 800 300]);
% ax(1) = axes('Position', [.1 .15 .8 .75]);
% ax(2) = axes('Position', [.1 .15 .8 .75], 'color', 'none','yaxislocation', 'right');
% 
% xlabel(ax(1),'Time(ms)');
% ylabel(ax(1), 'HPC Rate(Hz)');
% ylabel(ax(2), 'RSC Rate(Hz)');
% 
% yTmp = minmax( mean(hpcRateHC) );
% line([0 0], yTmp,  'color', [.7 .7 .7], 'linestyle', '--', 'parent', ax(1));
% line(thold * [1000 1000], yTmp,  'color', [.7 .7 .7], 'linestyle', '--', 'parent', ax(1));
% 
% 
% l(1) = line(ts*1000, mean(hpcRateHC,1), 'Color', 'r','Parent', ax(1));
% l(2) = line(ts2*1000, mean(hpcRateLC,1), 'Color', 'b','Parent', ax(2));
% 
% 
% legend(l(1:2), {'HPC', 'RSC'});
% 
% % line(xHPC, fHPC, 'Color', 'r', 'Parent', ax(2));
% % line(xCTX, fCTX, 'Color', 'b', 'Parent', ax(2));
% 
% 
% set(ax,'Xlim', win*1000, 'Xtick', [-250:250:500])
% 
% % set(ax(2),'Xlim', [0 .25]);
% 
% title(ax(1), sprintf('Thold %dms', thold * 1000), 'fontSize', 16);
% %%

