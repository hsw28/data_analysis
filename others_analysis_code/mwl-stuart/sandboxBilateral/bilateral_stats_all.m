%% Complete script for calcualting the complete set of statistics for my bilateral ananlysis project
clear;
%%
eRun = dset_list_epochs('run');
eSleep = dset_list_epochs('sleep');
plotting = 1;
misc = [];

clear run sleep;

dset = dset_load_all(eRun{2,1}, eRun{2,2}, eRun{2,3});

% %% Compute the XCORR between the two ripple bands
% [run.ripBandXCorr sleep.ripBandXCorr] = dset_compute_bilateral_ripple_band_xcorr;
% [run.ripEventXCorr sleep.ripEventXCorr] = dset_compute_bilateral_ripple_event_xcorr;

% %% Compute the CORRELATIONS between ripple FREQUENCIES
% 
% for i = 1:size(eRun,1)
%     fprintf(' \n ------------ %d of %d ----------- \n', i, size(eRun,1));
%     dset = dset_load_all(eRun{i,1}, eRun{i,2}, eRun{i,3});
%     [run.ripFrSpCorrIpsi(i) run.ripFrSpCorrCont(i) run.ripFrSpCorrShuff{i} run.freqSp(i)] = dset_analyze_ripple_freq_correlations(dset);   
%     [run.ripFrMeanCorrIpsi(i) run.ripFrMeanCorrCont(i) run.rip!FrMeanCorrShuff{i} run.freqMean(i)] = dset_calculate_bilateral_mean_ripple_freq_corr(dset);   
% end
% %%
% 
% for i = 1:size(eSleep,1)
%     fprintf(' \n ------------ %d of %d ----------- \n', i, size(eSleep,1));
% 
%     dset = dset_load_all(eSleep{i,1}, eSleep{i,2}, eSleep{i,3});
%     [sleep.ripFrSpCorrIpsi(i) sleep.ripFrSpCorrCont(i) sleep.ripFrSpCorrShuff{i} sleep.freqSp(i)] = dset_analyze_ripple_freq_correlations(dset);   
%     [sleep.ripFrMeanCorrIpsi(i) sleep.ripFrMeanCorrCont(i) sleep.ripFrMeanCorrShuff{i} sleep.freqMean(i)] = dset_calculate_bilateral_mean_ripple_freq_corr(dset);   
% end
%%

% dset_compute_bilateral_ripple_corr_with_shuffl;

%% RUN DECODING -----------------------------------------------------------
%% RUN 
%% RUN

%% Compute the distribution of errors for both uni-lateral and bilateral decoding
[p e] = dset_calculate_bilateral_decoding_errors_run(dset);


%% compute the correlation between the number of spikes and replay score
dset_compute_corr_between_nspike_replay_score;


%% REPLAY DECODING --------------------------------------------------------
clearvars -except d dset
lIdx = strcmp({dset.clusters.hemisphere}, 'left');
rIdx = strcmp({dset.clusters.hemisphere}, 'right');

if sum(lIdx) > sum(rIdx)
    clIdx{1} = lIdx;
    clidx{2} = rIdx;
else
    clIdx{1} = rIdx;
    clIdx{2} = lIdx;
end

bIdx = lIdx | rIdx;

smoothPdf = 1;

%compte the UNILATERAL replay line estimates
for i = 1:2
    [stats.U(i) recon.U(i) ] = dset_calc_replay_stats(dset, clIdx{i}, [],[],smoothPdf);
    [stats.U(i) recon.U(i) ] = dset_calc_replay_stats(dset, clIdx{i}, [],[],smoothPdf);
end

%compute the BILATERAL replay line estimates
[stats.B recon.B ] = dset_calc_replay_stats(dset, bIdx, stats.U(1).slope, stats.U(1).intercept, smoothPdf);


%% Compute the significance of the unilateral replay events
nShuffle = 250;
for i = 1:2
    [uShuf(i).pseudoScore, uShuf(i).shiftScore, uShuf(i).pfSwapScore, uShuf(i).pfShiftScore] = ...
        dset_calc_replay_shuffle_scores(dset, recon.U(i), nShuffle, stats.U(i).slope, stats.U(1).intercept, clIdx{i}, [], smoothPdf, 0);
end
%% Compute pValues for each replay event
pValUni = {};
for i = 1:2
    [pValUni{i} colNames] = dset_calc_replay_significance(stats.U(i), uShuf(i), .05);
end

%% Calculate shuffle distributions

[bShuf.pseudoScore, bShuf.shiftScore, bShuf.pfSwapScore, bShuf.pfShiftScore] = ...
    dset_calc_replay_shuffle_scores(dset, recon.U(1), nShuffle, stats.U(1).slope, stats.U(1).intercept, clIdx{1}, [], smoothPdf, 1);
%% Calculate pValues relative to the shuffle distributions for each event 
clear p a;

nShuffle = size(bShuf.pseudoScore, 3);
[maxScore, bestIdx] = max(stats.B.score2,[],2);

for i = 1:size(dset.mu.bursts,1)
    p.pseudo(i) = 1 - sum( stats.B.score2(i,bestIdx(i)) > bShuf.pseudoScore(i,bestIdx(i),:) ) / nShuffle;
    p.shiftCol(i)  = 1 - sum( stats.B.score2(i,bestIdx(i)) > bShuf.shiftScore(i,bestIdx(i),:) ) / nShuffle;
    p.pfSwap(i) = 1 - sum( stats.B.score2(i,bestIdx(i)) > bShuf.pfSwapScore(i, bestIdx(i),:) ) / nShuffle;
    p.pfShift(i)= 1 - sum( stats.B.score2(i,bestIdx(i)) > bShuf.pfShiftScore(i, bestIdx(i),:) ) / nShuffle;
end

%% Plot the distribution of pValues for a single experiment 
perSig = [];
perSig(end+1) = sum(p.pseudo  <= .05) / numel( p.pseudo) ;
perSig(end+1) = sum(p.shiftCol<= .05) / numel( p.shiftCol);
%perSig(end+1) = sum(p.shiftMat<= .05) / numel( p.shiftMat);
perSig(end+1) = sum(p.pfSwap  <= .05) / numel( p.pfSwap);
perSig(end+1) = sum(p.pfShift <= .05) / numel( p.pfShift);

bins = 0:.025:1;

h = {};
h{end+1} = histc(p.pseudo, bins);
h{end+1} = histc(p.shiftCol, bins);
%h{end+1} = histc(p.shiftMat, bins);
h{end+1} = histc(p.pfSwap, bins);
h{end+1} = histc(p.pfShift, bins); 

titles = {};
titles{end+1} = 'Pseudo Event Shuffle';
titles{end+1} = 'Event Col Shift Shuffle';
%titles{end+1} = 'Event Mat Shift Shuffle';
titles{end+1} = 'TC Swap Shuffle';
titles{end+1} = 'TC Shift Shuffle';

figure('Position', [2350 100 490 780]);

a = [];
for i = 1:numel(h)
    a(i) = subplot(numel(h),1,i);
    bar(bins, h{i});
    l = line([.05 .05], get(a(i), 'YLim'),  'color', 'r', 'linewidth', 2, 'Parent', a(i));
    title(sprintf('%s: Fraction Significant: %0.3g', titles{i}, perSig(i) ) );
    set(a(i), 'Ylim', get(l, 'YData'));
end

set(a,'Xlim', [-.025 .65]);

%% Plot the distribution of shuffled scores with the computed scores
plot_dset_recon_shuffle_dist(stats.B.score2, bShuf.pseudoScore, 'Pseudo Event');
plot_dset_recon_shuffle_dist(stats.B.score2, bShuf.shiftScore, 'Col Shift');
plot_dset_recon_shuffle_dist(stats.B.score2, bShuf.pfSwapScore, 'PF Swap');
plot_dset_recon_shuffle_dist(stats.B.score2, bShuf.pfShiftScore, 'PF Shift');

%% SLEEP DECODING -----------------------------------------------------------
%% SLEEP 
%% SLEEP
clear;
eSleep = dset_list_epochs('sleep');
dset = dset_load_all(eSleep{2,1}, eSleep{2,2}, eSleep{2,3}); 

lIdx = strcmp({dset.clusters.hemisphere}, 'left');
rIdx = strcmp({dset.clusters.hemisphere}, 'right');

if sum(lIdx) > sum(rIdx)
    clIdx = lIdx;
else
    clIdx = rIdx;
end

bIdx = lIdx | rIdx;

smoothPdf = 1;
%compute the replay estimates using only cells in the left hemisphere
[stats.U recon.U ] = dset_calc_replay_stats(dset, clIdx, [],[],smoothPdf);
%compute the replay esitimates using parameters from the left
[stats.B recon.B ] = dset_calc_replay_stats(dset, bIdx, stats.U.slope, stats.U.intercept, smoothPdf);

%%

%% Calculate shuffle distributions
nShuffle = 250;

[stats.pseudoScore, stats.shiftScore, stats.pfSwapScore, stats.pfShiftScore] = ...
    dset_calc_replay_shuffle_scores(dset, recon.U, nShuffle, stats.U.slope, stats.U.intercept, clIdx, [], smoothPdf);
%% Calculate pValues relative to the shuffle distributions for each event 
clear p a;

[maxScore, bestIdx] = max(stats.B.score2,[],2);

for i = 1:size(dset.mu.bursts,1)
    p.pseudo(i) = 1 - sum( stats.B.score2(i,bestIdx(i)) > stats.pseudoScore(i,bestIdx(i),:) ) / nShuffle;
    p.shiftCol(i)  = 1 - sum( stats.B.score2(i,bestIdx(i)) > stats.shiftScore(i,bestIdx(i),:) ) / nShuffle;
    p.pfSwap(i) = 1 - sum( stats.B.score2(i,bestIdx(i)) > stats.pfSwapScore(i, bestIdx(i),:) ) / nShuffle;
    p.pfShift(i)= 1 - sum( stats.B.score2(i,bestIdx(i)) > stats.pfShiftScore(i, bestIdx(i),:) ) / nShuffle;
end