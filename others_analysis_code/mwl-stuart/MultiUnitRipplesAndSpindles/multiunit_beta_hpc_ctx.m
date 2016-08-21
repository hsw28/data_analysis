% Looking to see if there is a correlation between spindles in RSC and
% beta?! modulated multi-unit bursts in the HPC


%%
clear;
animal = 'sg-rat2'; % 'gh-rsc1' or  'sg-rat2'
day = 'day01'; % 'day18' or 'day01'
epType = 'sleep2'; % 'sleep3 or sleep2'
CTX = 'PFC'; % 'RSC' or 'CTX'
eegFileName = ['EEG_',CTX,'_250HZ_', upper(epType), '.mat']; 

edir = fullfile('/data', animal, day);

if ~exist(fullfile(edir, eegFileName), 'file')
    disp('Loading raw eeg');
   
    e = load_exp_eeg(edir, epType);
    [~, anat] = load_exp_eeg_anatomy(edir);
    chanIdx = strcmp(anat, CTX);
    e.data = e.data(:, chanIdx);
    e.loc = e.loc(chanIdx);
    e.ch = e.ch(chanIdx);
    disp('Downsampling eeg');
    e = downsample_exp_eeg(e, 250);

    eegData = e.data;
    eegTs = e.ts;
    eegFs = e.fs;
    clear e;
    disp('Saving eeg');
    save(fullfile(edir, eegFileName), 'eegData', 'eegTs', 'eegFs')
else
    fprintf('Loading pre-downsampled eeg from:%s\n',fullfile(edir, eegFileName));
    load(fullfile(edir, eegFileName));
end
clear eegFileName
s1Filt = getfilter(eegFs, 'spindle', 'win');

fprintf('Filtering %s-CTX LFP for Spindles\n', CTX);
eegSpinBand = filtfilt(s1Filt, 1, eegData);
eegSpinEnv = abs(hilbert(eegSpinBand));
eegSpinPow = eegSpinBand.^2;

muFileName = 'MU_SLEEP3.mat';
muFileName = fullfile(edir, muFileName);

if ~exist('mu', 'var')
    if ~exist(muFileName, 'file')
        disp('Multiunit file not yet created, loading now')
        d = dset_load_all(animal, day, epType);
        mu = d.mu;
        clear d;
        disp('Saving multi-unit file!');
        save(muFileName, 'mu');
    else
        disp('Multiunit file already exists, loading!');
        load(muFileName);
    end

    muRate = mu.rate;
    muTs = mu.timestamps;
    muBursts = mu.bursts;
    muFs = 1/mean(diff(muTs));
    clear d;
    
end

burstLen = diff(muBursts,[],2);

%%
perBurst = .15;
burstIdx{1} = find( burstLen >= quantile(burstLen, 1 - perBurst) );
burstIdx{2} = find( burstLen <= quantile(burstLen, perBurst) ); 

trigIdx = {};

TRIG_TYPE = 'START'; % must be, START, STOP, MEAN, PEAK

for i = 1:numel(burstIdx)
    b = muBursts(burstIdx{i},:);
    switch TRIG_TYPE
        case 'MEAN'
            trigIdx{i} = mean(b,2);
        case 'START'
            trigIdx{i} = b(:,1);
        case 'STOP'
            trigIdx{i} = b(:,2);
        case 'PEAK'
            error('Peak not implemented');
        otherwise
            error('Invalid trigger type');
    end
       
end
        

% - Compute the mean triggered Rates
clear trigMuRate trigSpinLfp trigSpinEnv trigSpinPow
win = [-.5 1];
for i = 1:numel(burstIdx)
    [~, trigMuRate{i}, ts1] = meanTriggeredSignal(trigIdx{i}, muTs, muRate * muFs, win);
end

for i = 1:numel(burstIdx)
    [~, trigSpinLfp{i}, ts2] = meanTriggeredSignal(trigIdx{i}, eegTs, eegSpinBand, win);
    [~, trigSpinEnv{i}] = meanTriggeredSignal(trigIdx{i}, eegTs, eegSpinEnv, win);
    [~, trigSpinPow{i}] = meanTriggeredSignal(trigIdx{i}, eegTs, eegSpinPow, win);
end

nMulti = numel(trigIdx{1});
nSingle = numel(trigIdx{2});

close all;
figH = figure('Position', [350 700 900 800]);

axH(1) = subplot(211); xlabel('Time (ms)'); ylabel('HPC MU Rate (Hz)');
axH(2) = subplot(212); xlabel('Time (ms)'); ylabel('RS CTX Spindle Band Envelope');

nStd = 1.96;

mMultiMu = mean(trigMuRate{1}); sMultiMu = std(trigMuRate{1});
mSingleMu = mean(trigMuRate{2}); sSingleMu = std(trigMuRate{2});

[p(1), l(1)] = error_area_plot(ts1*1000, mMultiMu, sMultiMu*nStd/sqrt(nMulti), 'Parent', axH(1));
[p(2), l(2)] = error_area_plot(ts1*1000, mSingleMu, sSingleMu*nStd/sqrt(nSingle), 'Parent', axH(1));


eegVar = trigSpinEnv;
mMultiLfp = mean(eegVar{1}); sMultiLfp=std(eegVar{1});
mSingleLfp = mean(eegVar{2}); sSingleLfp=std(eegVar{2});

[p(3), l(3)] = error_area_plot(ts2*1000, mMultiLfp, sMultiLfp*nStd/sqrt(nMulti), 'Parent', axH(2));
[p(4), l(4)] = error_area_plot(ts2*1000, mSingleLfp, sSingleLfp*nStd/sqrt(nSingle), 'Parent', axH(2));

title(axH(1), 'HPC Mu Burst Triggered MU Rate');
title(axH(2), 'HPC Mu Burst Triggered RS CTX Spindle Envelope');
legend(axH(1), [l(1), l(2)], 'Triplets', 'Singlets');

set(p,'EdgeColor', 'none');
set(p(1:2:3), 'FaceColor','r'); set(l(1:2:3), 'Color', 'r');
set(p(2:2:4), 'FaceColor','g'); set(l(2:2:4), 'Color', 'g');
set(p,'FaceAlpha', .4);

%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('%s_%s_mean_MUB_trig_%s_SPIN_ENV', animal,epType, CTX);
saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');


%%
% 
% 
% %% - Filter RSC channels in the spindle band (10-20 hz)
% rscChan = 1;
% rscEeg = eegData(:,rscChan);
% s1Filt = getfilter(eegFs, 'spindle1', 'win');
% % s2Filt = getfilter(fs, 'spindle2', 'win');
% 
% disp('Filtering RSC EEG for Spindles');
% rscSpinBand = filtfilt(s1Filt, 1, rscEeg);
% %rscSpin2 = filtfilt(s2Filt, 1, data);
% 
% rscEnv = abs(hilbert(rscSpinBand));
% rscPow = rscSpinBand .^2;
% 
% tholdEnv = 3 * std(rscEnv);
% tholdPow = 3 * std(rscPow);
% 
% isSpindlePow = bsxfun(@gt, rscEnv, tholdEnv);
% isSpindleEnv = bsxfun(@gt, rscPow, tholdPow);
% %%
% 
% % plot the ee
% close all;
% figure; a = axes;
% line_browser(eegTs, 5 * isSpindlePow + 5, 'parent', a, 'color', 'k');
% line_browser(eegTs, 5 * isSpindleEnv, 'parent', a, 'color', 'g');
% line_browser(eegTs, rscPow./std(rscPow), 'parent', a, 'color','r');
% line_browser(eegTs, rscEnv./std(rscEnv), 'parent', a, 'color', 'b'); 
% 
% %% 
% close all;
% figure; a = axes;
% line_browser(muTs, muRate, 'parent', a);
% line_browser(eegTs, 5*isSpindlePow, 'parent', a, 'color', 'r');
% 
% 
% 
% %% - Load the multi-unit data
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %                   CHANGE THESE VALUES            
% BURST_LEN = 'SHORT'; % must be SHORT or LONG
% TRIG_ON = 'MEAN'; % must be START END MEAN PEAK
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% muFileName = 'MU_SLEEP3.mat';
% muFileName = fullfile(edir, muFileName);
% 
% if ~exist('mu', 'var')
%     if ~exist(muFileName, 'file')
%         disp('Multiunit file not yet created, loading now')
%         d = dset_load_all('gh-rsc1', 'day18', epType);
%         mu = d.mu;
%         clear d;
%         disp('Saving multi-unit file!');
%         save(muFileName, 'mu');
%     else
%         disp('Multiunit file already exists, loading!');
%         load(muFileName);
%     end
% 
%     muRate = mu.rate;
%     muTs = mu.timestamps;
%     muBursts = mu.bursts;
%     clear d;
%     
% end
% 
% burstLen = diff(muBursts,[],2);
% 
% switch BURST_LEN
%     
%     case 'LONG'
%         burstIdx = find( burstLen >= quantile(burstLen, .85) );
%     case 'SHORT'
%         burstIdx = find( burstLen <= quantile(burstLen, .15) );
%         
% end
% 
% nBurst = nnz(burstIdx);
% 
% fprintf('Found %d bursts\n', numel(burstIdx));
% 
% % find the Multi-unit rate for the bursts
% eventIdx = zeros(size(burstIdx));
% 
% for j = 1:numel(burstIdx)
%     
%     startIdx = find( muTs == muBursts( burstIdx(j), 1), 1, 'first');
%     endIdx = find( muTs == muBursts( burstIdx(j),2), 1, 'first');
%     
%     switch TRIG_ON
%         case 'MEAN'
%             eventIdx(j) = round( mean( [startIdx endIdx] ) );% - 1 + mIdx;
%         case 'START'
%             eventIdx(j) = startIdx;
%         case 'END'
%             eventIdx(j) = endIdx;
%         case 'PEAK'
%             [~, mIdx] = max( muRate(startIdx:endIdx) );
%             eventIdx(j) = startIdx + mIdx - 1;
%         otherwise
%             eventIdx(j) = startIdx;
%     end    
% end
% 
% burstTs = muTs(eventIdx);
% 
% burstEegIdx = interp1(eegTs, 1:numel(eegTs), burstTs, 'nearest');
% 
% winLenTime = 1;
% winLenSamp = winLenTime * eegFs;
% winSamp = -winLenSamp:winLenSamp;
% 
% trigWin = floor( bsxfun(@plus, burstEegIdx', winSamp) );
% winTs = winSamp * 1000 / eegFs;
% 
% muTrigMeanWave.pow = rscPow(trigWin);
% muTrigMeanSpin.pow = isSpindleEnv(trigWin);
% 
% muTrigMeanWave.env = rscEnv(trigWin);
% muTrigMeanSpin.env = isSpindlePow(trigWin);
% 
% meanWave = mean( muTrigMeanWave.env );
% meanSpin = mean( muTrigMeanSpin.env );
% meanSpin = smoothn(meanSpin, 2);
% 
% 
% results.(BURST_LEN).meanWave = meanWave;
% results.(BURST_LEN).meanSpin = meanSpin;
% 
% % Plot the results - Mean Detected Spindle Event/Envelope on Bursts
% if exist('figH', 'var')
%     if ishandle(figH)
%         close(figH)
%     end
% end
% figH = figure('Position', [200 500 1150 420]);
% l = [];
% [ax, l(1), l(2)] = plotyy(winTs, meanSpin, winTs, meanWave);
% set(l,'LineWidth', 2);
% set(l(1), 'color','r');
% set(l(2), 'Color', 'g');
% set(ax,'YColor','k');
% ylabel(ax(1), 'nEvents');
% ylabel(ax(2), 'Amplitude');
% 
% legend({'Events', 'Envelope'});
% title(sprintf('RSC Spindles, triggered on %s MUB %ss', BURST_LEN, TRIG_ON));
% 
% %% - Save the Figure;
% tmpAnimal = animal;
% tmpAnimal(tmpAnimal~='-') = '_';
% strName = sprintf('%s_%s_mean_SPIN_trig_%s_%s', animal,epType, BURST_LEN, TRIG_ON );
% saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');
% 
% 
% %%
% 
% imagesc(spindEnv(trigWin));
% plot( mean( spindEnv(trigWin) ) )
% 
% %% Plot the Results
% spinAve = sum( burstTrigSpin );
% spinAve = smoothn( spinAve, 2);
% winTs = winSamp * 1000 / eegFs;
% plot(winTs, spinAve )
% 
% % Compute the peaks
% [~, pkIdx] = findpeaks( spinAve );
% dPeaks = [nan diff(pkIdx)];
% dPeakTime = dPeaks / eegFs;
% peakFreq = dPeakTime .^ -1;
% pkTs = winSamp(pkIdx) * 1000/eegFs;
% 
% 
% figure();
% axes('Position', [.05 .1 .9 .75]);
% 
% for j = 1:numel(pkIdx)
%     if j>1
%         text(mean(pkTs([j-1 j])), 10, sprintf('%s:%2.1f', '\Deltat', 1000*dPeakTime(j)), 'horizontalalignment', 'center');    
%     end
%     line([pkTs(j) pkTs(j)], [0 10], 'color', [.4 .4 .4], 'linestyle', '--');
% end
% line(winTime, 10 * spinAve/ max(spinAve), 'color', 'r', 'linewidth', 2);
% 
% set(gca,'YLim', [0 11]);
% title(sprintf('%s N Events:%d Trigger on:%s ', dset_get_description_string(dset), nnz(burstIdx), TRIG_ON));
% 
% 
% 



