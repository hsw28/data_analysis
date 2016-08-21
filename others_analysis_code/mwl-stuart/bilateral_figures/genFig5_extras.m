function genFig5_extras
%% Load all the data required for plotting!
open_pool;
%%
clear;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           LOAD THE DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runEpochs = dset_list_epochs('run');

i = 1;
% for i = 1:numel(runReconFiles)
    
    dset = dset_load_all(runEpochs{i,1}, runEpochs{i,2}, runEpochs{i,3});    

    lIdx = strcmp({dset.clusters.hemisphere}, 'left');
    rIdx = strcmp({dset.clusters.hemisphere}, 'right');
    
    if sum(lIdx) > sum(rIdx)
        clIdx{1} = lIdx;
        clIdx{2} = rIdx;
    else
        clIdx{1} = rIdx;
        clIdx{2} = lIdx;
    end
    [statSimp(1), reconSimp(1)] = dset_calc_replay_stats(dset, clIdx{1}, [], [], 1, 'simple');
    [statSimp(2), reconSimp(2)] = dset_calc_replay_stats(dset, clIdx{2}, [], [], 1, 'simple');

 
    for iii = 1:2
        [st(iii), rp(iii)] = dset_calc_replay_stats(dset, clIdx{iii}, [], [],1);
    end          
    
    lSpikeIdx = logical( sum(reconSimp(1).spike_counts) );
    rSpikeIdx = logical( sum(reconSimp(2).spike_counts) );
    
    % get the indecies of the pdf that are within a multi-unit burst
    muTs = reconSimp(1).tbins;
    events = dset.mu.bursts;
    
    burstIdx = arrayfun(@(x,y) ( muTs >= x & muTs <= y ), events(:,1), events(:,2), 'UniformOutput', 0 );
    burstIdx = sum( cell2mat(burstIdx'), 2);
 
    replayIdx = burstIdx & logical( sum( reconSimp(1).spike_counts ) )'  & logical( sum( reconSimp(2).spike_counts) )';

    pdf1 = reconSimp(1).pdf(:, replayIdx);
    pdf2 = reconSimp(2).pdf(:, replayIdx);

    nSpike{1} = sum( rp(1).spike_counts(:, replayIdx));
    nSpike{2} = sum( rp(2).spike_counts(:, replayIdx));
    
    
    % Compute the correlations between the pdfs
    replayCorr = corr_col(pdf1, pdf2);  
    
    
    N_SHUFFLE = 250;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Tuning Curve Shuffles
    
    tcShuffCorr = nan(N_SHUFFLE, numel(replayCorr));
    nTC = sum(clIdx{2});
    
    
    parfor iShuffle = 1:N_SHUFFLE
      
        
        dShuf = dset;
        dShuf.clusters = dset.clusters(clIdx{2});
        tcList = {dShuf.clusters.pf};
        nTC = numel(tcList);

        tcList = randsample(tcList, nTC);
        [dShuf.clusters(1:16).pf] = tcList{:};
    
        [statShuf, reconShuf] = dset_calc_replay_stats(dShuf, [], [], [], 1, 'simple');
        pdfShuff = reconShuf.pdf(:,replayIdx);
        
        tcShuffCorr(iShuffle,:) = corr_col(pdf1, pdfShuff);
    end
    fprintf('DONE!!!!!!!!!!!!');
    fprintf('\n');
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PDF Time Bin Shuffle
    
    colCorrShuffle = [];
   
    for iShuffle = 1:N_SHUFFLE
        randIdx = randsample( size(pdf1,2), size(pdf1,2),0);
        colCorrShuffle = [ colCorrShuffle, corr_col( pdf1, pdf2(:, randIdx) ) ];
%         binDistShuffle = [ binDistShuffle, calc_posidx_distance(idx1, idx2(randIdx), dset.clusters(1).pf_edges);];
    end
    
    %%
% compute the bilateral multi-unit xcorr

xcWin = .25;
muTs = dset.mu.timestamps;
muDt = mean( diff( muTs ));

muBurstIdx = arrayfun(@(x,y) ( muTs >= x-xcWin & muTs <= y+xcWin ), events(:,1), events(:,2), 'UniformOutput', 0 );
muBurstIdx = logical( sum( cell2mat(muBurstIdx'), 2) );

[muXc, lags] = xcorr(dset.mu.rateL .* muBurstIdx, dset.mu.rateR .* muBurstIdx, ceil(xcWin/muDt), 'coeff');
lags = lags * mean( diff( muTs ) );

%%
[pdfComp, idxHigh, idxLow] = dset_compare_bilateral_pdf_by_percent_cell_active(dset, st, reconSimp);
   
%% Compute the distribution of correlations using shuffled trajectories

eventLen = cellfun(@(x) (size(x,2)), statSimp(1).pdf);

minLen = 2;
maxLen = 11;

noGoIdx = eventLen<minLen | eventLen> maxLen  | ~(statSimp(1).percentCells > 0)' | ~(statSimp(2).percentCells > 0)';

nPdf = numel(statSimp(1).pdf);
realEventCorr = nan(1, nPdf);


for i = 1:nPdf
    if noGoIdx(i)
        continue;
    end
    
    realEventCorr(i) = mean( corr_col( statSimp(1).pdf{i}, statSimp(2).pdf{i}) );
    
end



pdfShuf = statSimp(2).pdf;
shufEventCorr = nan(N_SHUFFLE, nPdf);

ind = 1;
for iShuf = 1:N_SHUFFLE
    
    for iLen = minLen:maxLen
        lenIdx = eventLen==iLen; 
        pdfShuf(lenIdx) = randsample(pdfShuf(lenIdx), nnz(lenIdx));
    
    end
    
    for iPdf = 1:nPdf
        
        if noGoIdx(iPdf)
            continue;
        end
        
        shufEventCorr(iShuf, iPdf) = mean(corr_col( statSimp(1).pdf{iPdf}, pdfShuf{iPdf}));
    end
end



%%

close all;

figure('Position', [200 700 990 275]);
b = [-1:.01:1];

subplot(131);
Y1 = ksdensity(realEventCorr, b, 'support', [-1 1]);
Y2 = ksdensity(shufEventCorr(:), b, 'support', [-1 1]);

line(b, Y1, 'color', 'r');
line(b, Y2, 'color', 'g');
title('All Events');

[h, p] = kstest2(realEventCorr, shufEventCorr(:), .05, 'smaller');

fprintf('\nAll Events\t- H:%d, p:%3.3g\n', h, p);

subplot(132);

X1 = realEventCorr(idxHigh);
X2 = shufEventCorr(:, idxHigh);

[h, p] = kstest2(X1, X2(:), .05, 'smaller');
fprintf('Popular Events\t- H:%d, p:%3.3g\n', h, p);

Y1 = ksdensity(X1, b, 'support', [-1 1]);
Y2 = ksdensity(X2(:), b, 'support', [-1 1]);

line(b, Y1, 'color', 'r');
line(b, Y2, 'color', 'g');
title('Popular Events');

subplot(133);

X1 = realEventCorr(idxLow);
X2 = shufEventCorr(:, idxLow);
[h, p] = kstest2(X1, X2(:), .05, 'smaller');
fprintf('Sparse Events\t- H:%d, p:%3.3g\n\n', h, p);
Y1 = ksdensity(X1, b, 'support', [-1 1]);
Y2 = ksdensity(X2(:), b, 'support', [-1 1]);

line(b, Y1, 'color', 'r');
line(b, Y2, 'color', 'g');
legend('Real', 'Shuffle', 'Location', 'northeast');
title('Sparse Events');

set(get(gcf,'Children'), 'XLim', [-.5, 1], 'YLim', [0 2.5]);
%%
b = -1:.01:1;
figure;
X1 = realEventCorr;
X2 = realEventCorr(idxHigh);
X3 = realEventCorr(idxLow);

Y1 = ksdensity(X1, b, 'support', [-1 1]);
Y2 = ksdensity(X2, b, 'support', [-1 1]);
Y3 = ksdensity(X3, b, 'support', [-1 1]);

line(b, Y1, 'color', 'k');
line(b, Y2, 'Color', 'r');
line(b, Y3, 'Color', 'm');
%%
eventPVal =  1 - sum( bsxfun( @gt, realEventCorr, shufEventCorr) ) / N_SHUFFLE  ;
eventPVal(isnan(realEventCorr)) = nan;

gIdx = nan * eventPVal;
gIdx(idxHigh) = 1;
gIdx(idxLow) = 2;



%%




%%
figure;
b = -1:.025:1;
ksdensity(realEventCorr, b); hold on;
ksdensity(shufEventCorr(:), b);

c = get(gca,'Children');
set(c(1), 'Color', 'r');

legend('Real', 'Shuffle');



    
%% Draw the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Draw the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% close all;

axHandle = [];
fHandle = figure('Position',  [350 250 650 620], 'Name', dset_get_description_string(dset) );
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      A,B,C - Replay Examples
% Bon3-2 Examples: [147 159*] 100, 111, 146, 147, 159, 172?!?, 209
% Bon3-4 Examples: 66, 94, *124*, 147, 159L
% Bon4-2 Examples: 096, 104-3, 115-1, 120-2, 126, 130
% Bon5-2 Examples: 093, 102, 115
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = 6;
axHandle(1) = axes('Position', [.0328 .53 .1311 .44]);
axHandle(2) = axes('Position', [.1639 .53 .1311 .44]);
axHandle(3) = axes('Position', [.3605 .53 .1311 .44]);
axHandle(4) = axes('Position', [.4916 .53 .1311 .44]);
axHandle(5) = axes('Position', [.6882 .53 .1311 .44]);
axHandle(6) = axes('Position', [.8193 .53 .1311 .44]);

%e = dset.mu.bursts(124,:);

eIdxList = [159 172 111];
trajList = [2 1 2];
tbins = linspace(-.1, .1, 11);
for ii = 1:3
    eIdx = eIdxList(ii);
    traj = trajList(ii);
    
    eTime = mean(dset.mu.bursts(eIdx,:));
    xcWin = .1;
    tIdx = rp(1).tbins > (eTime - xcWin) & rp(1).tbins < (eTime + xcWin);
    
    imagesc(tbins, rp(1).pbins{traj},  rp(1).pdf{traj}(:,tIdx), 'Parent', axHandle((ii-1)*2 + 1) );
    imagesc(tbins, rp(1).pbins{traj},  rp(2).pdf{traj}(:,tIdx), 'Parent', axHandle((ii-1)*2 + 2) );
end

set(axHandle(1:nAx), 'YTick', [])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Bilateral Multi-unit xcorr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx + 1;
axHandle(nAx) = axes('Position', [.0395 .1226 .2685 .2767]);
area(lags, muXc, 0);
set(axHandle(nAx), 'XLim', [-.25 .25], 'YLim', [.15 .75]);
title('Bilat MUA XCorr');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Distribution of TimeBin Shuffle Columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx+1;
axHandle(nAx) = axes('Position', [.3712 .2726 .2685 .1267]);
bins = -1:.025:1;

[~, pCorr1] = kstest2(replayCorr, colCorrShuffle, .05, 'smaller');

corrDistReal = ksdensity(replayCorr, bins);
corrDistShuf = ksdensity(colCorrShuffle, bins);

p = [];
p(1) = patch( [bins 1], [corrDistReal 0], 'r', 'parent', axHandle(nAx)); hold on;
p(2) = patch( [bins 1], [corrDistShuf 0], 'g', 'parent', axHandle(nAx));

set(axHandle(nAx),'XLim', [-1.0 1.0], 'XTick', [-1:.5:1]);
title( sprintf('PDF Corr, p<%0.2g', pCorr1) ); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Distribution of TC Shuffle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx+1;
axHandle(nAx) = axes('Position', [.3712 .12262 .2685 .1267]);
bins = -1:.025:1;

[~, pCorr1] = kstest2(replayCorr, tcShuffCorr(:), .05, 'smaller');

corrDistReal = ksdensity(replayCorr, bins);
corrDistShuf = ksdensity(colCorrShuffle, bins);

p = [];
p(1) = patch( [bins 1], [corrDistReal 0], 'r', 'parent', axHandle(nAx)); hold on;
p(2) = patch( [bins 1], [corrDistShuf 0], 'g', 'parent', axHandle(nAx));

set(axHandle(nAx),'XLim', [-1.0 1.0], 'XTick', [-1:.5:1]);
title( sprintf('PDF Corr, p<%0.2g', pCorr1) ); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Distribution of Correlations by Percent Cells active
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx+1;
axHandle(nAx) = axes('position', [.6972 .1226 .2685 .2767]);
bins = -1:.05:1;

distHigh = ksdensity(pdfComp.highPerCorr, bins);
distLow =  ksdensity(pdfComp.lowPerCorr, bins);

p = [];

p(1) = patch( [bins 1], [distHigh 0], 'b', 'Parent', axHandle(nAx));
p(2) = patch( [bins 1], [distLow 0],  'k', 'Parent', axHandle(nAx));


set(axHandle(nAx), 'XLim', [-1 1]);

title( sprintf('Mean Evt Corr, p<%0.2g', pdfComp.pVal) ); 

nAx = nAx+1;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Distribution of Distances by Percent Cells active
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axHandle(nAx) = axes('position', [.5622 .1478 .2685 .1837]);
% d1 = pdfComp.highPerDist; 
% d2 = pdfComp.lowPerDist;
% bins = [0:45];
% [h1, cent] = hist(d1, bins);
% [h2, ~] = hist(d2, bins);
% 
% line(cent, smoothn(h1 ./ sum(h1), 2, 'correct', 1), 'color', 'b', 'Parent', axHandle(nAx), 'linewidth', 2);
% line(cent, smoothn(h2 ./ sum(h2), 2, 'correct', 1), 'color', 'k', 'Parent', axHandle(nAx), 'linewidth', 2);
% 
% set(axHandle(nAx), 'XLim', [0 45]);
% title( sprintf('Corr Diff p<%0.2g %02.g ', pdfComp.kstest_dist, pdfComp.cmtest_dist) ); 
% nAx = nAx+1;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Correlation plots by percent cells  BOXPLOT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axHandle(nAx) = axes('position', [.0305 .208 .1931 .16]);
% d1 = pdfComp.highPerCorr; 
% d2 = pdfComp.lowPerCorr;
% vals = [d1; d2];
% cat = [ones(size(d1)); zeros(size(d2))];
% boxplot(vals, cat, 'Parent', axHandle(nAx));
% 
% nAx = nAx+1;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Correlation plots by percent cells  E-CDF
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axHandle(nAx) = axes('position', [.2855 .208 .1931 .16]);
% ecdf(axHandle(nAx), d1 ); set(get(axHandle(nAx),'Children'), 'Color', 'r'); hold on;
% ecdf(axHandle(nAx), d2 );
% 
% nAx = nAx+1;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Distance plots by percent cells  BOXPLOT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% axHandle(nAx) = axes('position', [.5405 .208 .1931 .16]);
% 
% d1 = pdfComp.highPerDist;
% d2 = pdfComp.lowPerDist;
% vals = [d1; d2];
% cat = [ones(size(d1)); zeros(size(d2))];
% boxplot(vals, cat, 'Parent', axHandle(nAx));
% 
% nAx = nAx+1;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %           Distance plots by percent cells  ECDF
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% axHandle(nAx) = axes('position', [.7685 .208 .1931 .16]);
% ecdf(axHandle(nAx), d1 ); set(get(axHandle(nAx),'Children'), 'Color', 'r'); hold on;
% ecdf(axHandle(nAx), d2 );


%% Save the Figure
 save_bilat_figure('figure4-v2', fHandle);


end


