clear;
d = dset_load_all('bon', 4,4);

%%
lIdx = strcmp({d.clusters.hemisphere}, 'left');
rIdx = strcmp({d.clusters.hemisphere}, 'right');
smoothPdf = 1;

[s.L r.L ] = dset_calc_replay_stats(d, lIdx, [],[],smoothPdf);
[s.R r.R ] = dset_calc_replay_stats(d, rIdx, [],[],smoothPdf);
%%
[maxL mIdxL] = max(s.L.score2, [], 2);
[maxR mIdxR] = max(s.R.score2, [], 2);
    
idx = mIdxL;
idx(maxR > maxL) = mIdxR(maxR > maxL);


for i = 1:size(d.mu.bursts,1)
    timeIdx = r.L.tbins >= d.mu.bursts(i,1) & r.L.tbins <= d.mu.bursts(i,2);
    
    nL(i) = sum(sum(r.L.spike_counts(:,timeIdx)));
    nR(i) = sum(sum(r.R.spike_counts(:,timeIdx)));
    sL(i) = s.L.score2(i, idx(i));
    sR(i) = s.R.score2(i, idx(i));
   
end
%%
idx = ~isnan(nL) & ~isnan(nR) & ~isnan(sL) & ~isnan(sR);

cRealL = corr2(nL(idx), sL(idx));
cRealR = corr2(nR(idx), sR(idx));
cReal  = corr2([nR(idx), nL(idx)], [sR(idx), sL(idx)]);


nShuffle = 500;
for n = 1:nShuffle
    sShuf1 = randsample(sR(idx), sum(idx), 1);
    cShuffR(n) = corr2(nR(idx), sShuf1);
    sShuf2 = randsample(sL(idx), sum(idx), 1);
    cShuffL(n) = corr2(nL(idx), sShuf2);
    cShuff(n) = corr2([nR(idx), nL(idx)], [sShuf1, sShuf2]);
end

%%
plot_shuffles({cShuffL, cShuffR, cShuff}, [cRealL, cRealR, cReal])


    