function generateFigure5
%% Load all the data required for plotting!
open_pool;
%%
clear;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           LOAD THE DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% runEpochs = dset_list_epochs('run');

i = 1;
% for i = 1:numel(runReconFiles)
    
%     dset = dset_load_all(runEpochs{i,1}, runEpochs{i,2}, runEpochs{i,3});    
    dset = dset_exp_load('/data/spl11/day12', 'run');

    lIdx = strcmp({dset.clusters.hemisphere}, 'left');
    rIdx = strcmp({dset.clusters.hemisphere}, 'right');
    
    if sum(lIdx) > sum(rIdx)
        clIdx{1} = lIdx;
        clIdx{2} = rIdx;
    else
        clIdx{1} = rIdx;
        clIdx{2} = lIdx;
    end
    
%     [statSimp(1), reconSimp(1)] = dset_calc_replay_stats(dset, clIdx{1}, [], [], 1, 'simple');
%     [statSimp(2), reconSimp(2)] = dset_calc_replay_stats(dset, clIdx{2}, [], [], 1, 'simple');
  
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

    nSpike{1} = sum( reconSimp(1).spike_counts(:, replayIdx));
    nSpike{2} = sum( reconSimp(2).spike_counts(:, replayIdx));
   
    replayCorr = corr_col(pdf1, pdf2);  
    
% Compute the shuffle distributions
    nShuffle = 100;    
    colCorrShuffle = [];
%     binDistShuffle = [];
   
    for i = 1:nShuffle
        randIdx = randsample( size(pdf1,2), size(pdf1,2),0);
        colCorrShuffle = [ colCorrShuffle, corr_col( pdf1, pdf2(:, randIdx) ) ];
%         binDistShuffle = [ binDistShuffle, calc_posidx_distance(idx1, idx2(randIdx), dset.clusters(1).pf_edges);];
    end
    
% compute the bilateral multi-unit xcorr

xcWin = .25;
muTs = dset.mu.timestamps;
muDt = mean( diff( muTs ));

muBurstIdx = arrayfun(@(x,y) ( muTs >= x-xcWin & muTs <= y+xcWin ), events(:,1), events(:,2), 'UniformOutput', 0 );
muBurstIdx = logical( sum( cell2mat(muBurstIdx'), 2) );

[muXc, lags] = xcorr(dset.mu.rateL .* muBurstIdx, dset.mu.rateR .* muBurstIdx, ceil(xcWin/muDt), 'coeff');
lags = lags * mean( diff( muTs ) );

%%
[pdfComp, idxHigh, idxLow] = dset_compare_bilateral_pdf_by_percent_cell_active(dset, statSimp, reconSimp);
%pdfComp = dset_compare_bilateral_pdf_by_percent_cell_active_simple(reconSimp);
    
    
%% Draw the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Draw the figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;

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

eIdxList = [72, 94, 99]; %[59, 85,107,126];%[159 172 111];
trajList = [2 1 2];
tbins = linspace(-.1, .1, 11);
for ii = 1:3
    eIdx = eIdxList(ii);
    traj = trajList(ii);
    
    eTime = mean(dset.mu.bursts(eIdx,:));
    xcWin = .1;
    tIdx = reconSimp(1).tbins > (eTime - xcWin) & reconSimp(1).tbins < (eTime + xcWin);
    
    p1 = normc( reconSimp(1).pdf(:,tIdx) );
    p2 = normc( reconSimp(2).pdf(:,tIdx) );
    
    idx1 = all( p1 > .1768-.1 ) & all( p1  <.1768+.1);
    idx2 = all( p2 > .1768-.1 ) & all( p2  <.1768+.1);
    
    p1( :, idx1 ) = 0;
    p2( :, idx2 ) = 0;
    
    p1 = 1 - repmat( p1 ,[ 1 1 3]);
    p2 = 1 - repmat( p2 ,[ 1 1 3]);
    
    imagesc(tbins, reconSimp(1).pbins,  p1, 'Parent', axHandle((ii-1)*2 + 1) );
    imagesc(tbins, reconSimp(1).pbins,  p2, 'Parent', axHandle((ii-1)*2 + 2) );
end

set(axHandle(1:nAx), 'YTick', [])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Bilateral Multi-unit xcorr
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx + 1;
axHandle(nAx) = axes('Position', [.0395 .1226 .2685 .2767]);
area(lags, muXc, 0);
set(axHandle(nAx), 'XLim', [-.25 .25]);
title('Bilat MUA XCorr');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Distribution of Column Correlations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx+1;
axHandle(nAx) = axes('Position', [.3712 .1226 .2685 .2767]);
bins = -1:.025:1;

[~, pCorr1] = kstest2(replayCorr, colCorrShuffle, .05, 'smaller');

[occRealCorr, cent] = hist(replayCorr, bins); 
[occShufCorr]       = hist(colCorrShuffle, bins);


occRealCorrSm = smoothn(occRealCorr, 3, 'correct', 1);
occShufCorrSm = smoothn(occShufCorr, 3, 'correct', 1);


occRealCorrSm  = occRealCorrSm./sum(occRealCorrSm);
occShufCorrSm  = occShufCorrSm./sum(occShufCorrSm);

% fill( [-1 -1 1 1], [0 1 1 0],  'w', 'edgecolor', 'none', 'parent', axHandle(nAx));
p = [];
p(1) = patch( [cent 1], [occRealCorrSm 0], 'r', 'parent', axHandle(nAx)); hold on;
p(2) = patch( [cent 1], [occShufCorrSm 0], 'g', 'parent', axHandle(nAx));

set(axHandle(nAx),'XLim', [-1.0 1.0], 'XTick', [-1:.5:1]);
title( sprintf('PDF Corr, p<%0.2g', pCorr1) ); 
nAx = nAx+1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Distribution of Correlations by Percent Cells active
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axHandle(nAx) = axes('position', [.6972 .1226 .2685 .2767]);
distHigh = pdfComp.highPerCorr; 
distLow = pdfComp.lowPerCorr;
bins = [-5:.05:1];
[occHigh, cent] = hist(distHigh, bins);
[occLow, ~] = hist(distLow, bins);

occHigh = occHigh ./ sum(occHigh);
occLow = occLow ./ sum(occLow);

occHighSm = smoothn(occHigh, 2.5, 'correct', 1);
occLowSm = smoothn(occLow, 2.5, 'correct', 1);

p = [];
p(1) = patch( [cent 1], [occHighSm 0], 'b', 'Parent', axHandle(nAx));
p(2) = patch( [cent 1], [occLowSm 0],  'k', 'Parent', axHandle(nAx));


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


