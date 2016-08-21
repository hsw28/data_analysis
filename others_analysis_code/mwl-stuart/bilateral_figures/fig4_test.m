function generateFigure4
%% Load all the data required for plotting!
open_pool;
%%
clear;
%%
reconFiles = dset_get_recon_file_list('run');
epochs = dset_list_epochs('run');

for i = 2%:size(epochs,1)
    
    if ~isempty( strfind(epochs{i,1} , 'spl' ) )
        continue;
    end
    
    dset = dset_load_all(epochs{i,1}, epochs{i,2}, epochs{i,3});    
    
    %%
    lIdx = strcmp({dset.clusters.hemisphere}, 'left');
    rIdx = strcmp({dset.clusters.hemisphere}, 'right');
    
    if sum(lIdx) > sum(rIdx)
        [~, recon(1)] = dset_calc_replay_stats(dset, lIdx, [], [], 1, 'simple');
        [~, recon(2)] = dset_calc_replay_stats(dset, rIdx, [], [], 1, 'simple');
    else
        [~, recon(1)] = dset_calc_replay_stats(dset, rIdx, [], [], 1, 'simple');
        [~, recon(2)] = dset_calc_replay_stats(dset, lIdx, [], [], 1, 'simple');
    end
%     
%     score1 = stats(1).score2;
%     score2 = stats(2).score2;
%     [~, trajIdx] = max( max(score1, score2), [], 2);
    
%% get the indecies of the timebins with spikes in both hemispheres
    lSpikeIdx = logical( sum(recon(1).spike_counts) );
    rSpikeIdx = logical( sum(recon(2).spike_counts) );
    
    % get the indecies of the pdf that are within a multi-unit burst
    ts = recon(1).tbins;
    events = dset.mu.bursts;
    burstIdx = arrayfun(@(x,y) ( ts>= x & ts<=y ), events(:,1), events(:,2), 'UniformOutput', 0 );
    burstIdx = sum( cell2mat(burstIdx'), 2);
 
    replayIdx = burstIdx & logical( sum( recon(1).spike_counts ) )'  & logical( sum( recon(2).spike_counts) )';

    pdf1 = recon(1).pdf(:, replayIdx);
    pdf2 = recon(2).pdf(:, replayIdx);
    
%% Compute the distances between the peaks od the pdfs
    [~, idx1] = max(pdf1);
    [~, idx2] = max(pdf2);
    %binDist = abs(idx1 - idx2);
    binDist = calc_posidx_distance(idx1, idx2, dset.clusters(1).pf_edges);
    
    %compute the confusion matrix
    confMat = confmat(idx1, idx2);
    confMat(:, sum(confMat)==0) = 1;
    confMat = normalize(confMat);
    confMat(:,:,2) = confMat;
    confMat(:,:,3) = confMat(:,:,1);
    confMat = 1 - confMat;
    
    % Compute the correlations between the pdfs
    replayCorr = corr_col(pdf1, pdf2);  
    
%% Compute the shuffle distributions
    nShuffle = 100;    
    colCorrShuffle = [];
    binDistShuffle = [];
    for i = 1:nShuffle
        randIdx = randsample( size(pdf1,2), size(pdf1,2), 0);
        colCorrShuffle = [ colCorrShuffle, corr_col( pdf1, pdf2(:, randIdx) ) ];
        binDistShuffle = [ binDistShuffle, calc_posidx_distance(idx1, idx2(randIdx), dset.clusters(1).pf_edges);];
    end
        


%% Draw the figure

% if exist('f', 'var'), delete( f( ishandle(f) ) ); end
% if exist('ax', 'var'), delete( ax( ishandle(ax) ) ); end
f = [];
ax = [];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      A - Bilateral Replay Examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = figure('Position',  [190 75 550 529], 'Name', dset_get_description_string(dset) );
ax(1) = axes('Position', [.0766 .6093 .3663 .3318]);
title('Example Replay Events');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       B - Confusion Matrix   B2 - color bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(2) = axes('Position', [.52 .6093 .3663 .3318]);
imagesc(confMat)
title('Confusion Matrix');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Distribution of Column Correlations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(3) = axes('Position', [.0766 .0641 .3663 .322]);
bins = -1:.025:1;

[~, pCorr1] = kstest2(replayCorr, colCorrShuffle, .05, 'smaller');
[~, pCorr2] = cmtest2(replayCorr, colCorrShuffle);

[occRealCorr, cent] = hist(replayCorr, bins); 
[occShufCorr]       = hist(colCorrShuffle, bins);

occRealCorr = smoothn(occRealCorr, 3, 'correct', 1);
occShufCorr = smoothn(occShufCorr, 3, 'correct', 1);

occRealCorr  = occRealCorr./sum(occRealCorr);
occShufCorr  = occShufCorr./sum(occShufCorr);

line(cent, occRealCorr, 'color', 'r', 'parent', ax(3));
line(cent, occShufCorr, 'color', 'g', 'parent', ax(3));

set(ax(3),'XLim', [-1.05 1.1], 'XTick', [-1:.5:1]);
title( sprintf('PDF Correlation p<%0.2g %02.g ', pCorr1, pCorr2) ); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Distance between the modes of the two pdfs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(4) = axes('Position', [.5185 .0641 .3663 .322]);

[~, pDist1] = kstest2(binDist, binDistShuffle, .05, 'larger');
[~, pDist2] = cmtest2(binDist, binDistShuffle);

[occRealDist, cent] = hist(binDist, 0:31);
[occShufDist] = hist(binDistShuffle, 0:31);

occRealDist = interp1(cent, occRealDist, 0:.25:31);
occShufDist = interp1(cent, occShufDist, 0:.25:31);
cent = 0:.25:31;

occRealDist = smoothn(occRealDist, 2, 'correct', 1);
occShufDist = smoothn(occShufDist, 2, 'correct', 1);

occRealDist  = occRealDist./sum(occRealDist);
occShufDist  = occShufDist./sum(occShufDist);

line(cent/10, occRealDist, 'color', 'r', 'parent', ax(4));
line(cent/10, occShufDist, 'color', 'g', 'parent', ax(4));

set(ax(4), 'XLim', [-.1 3]);
title( sprintf('\\Delta pos p<%0.2g %02.g ', pDist1, pDist2) );

%%
if pDist1 > .05 | pDist2 > .05 | pCorr1 > .05 | pCorr2 > .05
    
    set(gcf, 'Position', get(gcf,'Position') + [200 0 0 0]);

end
%% Save the Figure
% save_bilat_figure('figure4', f);


%%end
end

%%



pdf1 = recon(1).pdf;
pdf2 = recon(2).pdf;
pdf = [];
pdf(:,:,1) = pdf1;
pdf(:,:,2) = pdf2;
pdf(:,:,3) = pdf1;

figure; imagesc(recon(1).pbins, [0 1 2 3], 1- pdf);




%%
clear;

epochs = dset_list_epochs('run');
i = 2;
dset = dset_load_all(epochs{i,1}, epochs{i,2}, epochs{i,3});    
    
    
lIdx = strcmp({dset.clusters.hemisphere}, 'left');
rIdx = strcmp({dset.clusters.hemisphere}, 'right');

clIdx = {};
if sum(lIdx) > sum(rIdx)
    clIdx{1} = lIdx;
    clIdx{2} = rIdx;
else
    clIdx{2} = lIdx;
    clIdx{1} = rIdx;
end

[stats(1), recon(1)] = dset_calc_replay_stats(dset, clIdx{1}, [], [], 1);
[stats(2), recon(2)] = dset_calc_replay_stats(dset, clIdx{2}, [], [], 1);
    
    
score = max(stats(1).score2, stats(2).score2);
[~, trajIdx] =  max(score');


%%
figure;
ax(1) = axes('Position', [.05 .5 .33 .475]);
ax(2) = axes('Position', [.34, .5 .33 .475]);
ax(3) = axes('Position', [.67, .5 .33 .475]);

ax(4) = axes('Position', [.05 .025 .33 .475]);
ax(5) = axes('Position', [.34, .025 .33 .475]);
ax(6) = axes('Position', [.67, .025 .33 .475]);

for i = 1:size(st(1).pdf,1)
    for j = 1:3
        imagesc(st(1).pdf{i,j}, 'Parent', ax(j));
        imagesc(st(2).pdf{i,j}, 'Parent', ax(j+3));
    end
    set(ax,'XTick',[], 'YTick', []);
    set(gcf,'Name', num2str(i));
    pause;
end
    
    
    
    
    %%
    % Bon3-2 Examples: 100, 111, 146, 147, 159, 172?!?, 209
    % Bon3-4 Examples: 66, 94, *124*, 147, 159L
    % Bon4-2 Examples: 096, 104, 115, 120, 126, 130
    % Bon5-2 Examples: 093, 102, 115
    
    
    
    
    
    135
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

