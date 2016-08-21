function [p] = dset_analyze_bilateral_recon(dset)

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

nShuffle = 250;

[stats.pseudoScore, stats.shiftScore, stats.pfSwapScore, stats.pfShiftScore] = ...
    dset_calc_replay_shuffle_scores(dset, recon.U, nShuffle, stats.U.slope, stats.U.intercept, clIdx, [], smoothPdf);


[maxScore, bestIdx] = max(stats.B.score2,[],2);

for i = 1:size(dset.mu.bursts,1)
    p.pseudo(i) = 1 - sum( stats.B.score2(i,bestIdx(i)) > stats.pseudoScore(i,bestIdx(i),:) ) / nShuffle;
    p.shiftCol(i)  = 1 - sum( stats.B.score2(i,bestIdx(i)) > stats.shiftScore(i,bestIdx(i),:) ) / nShuffle;
    p.pfSwap(i) = 1 - sum( stats.B.score2(i,bestIdx(i)) > stats.pfSwapScore(i, bestIdx(i),:) ) / nShuffle;
    p.pfShift(i)= 1 - sum( stats.B.score2(i,bestIdx(i)) > stats.pfShiftScore(i, bestIdx(i),:) ) / nShuffle;
end

dir = '/data/franklab/bilateral/';
fileName = sprintf('recon_sig_test_%s_%d_%d.mat', dset.description.animal, dset.description.day, dset.description.epoch);
path = fullfile(dir, fileName);
save(path, 'dset', 'stats', 'recon', 'p');
fprintf('Saved file: %s', path);

end