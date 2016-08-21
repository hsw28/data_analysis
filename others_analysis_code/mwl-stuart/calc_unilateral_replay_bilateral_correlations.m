function [result] = calc_unilateral_replay_bilateral_correlations(d, r, s)

[maxL, mIdxL] = max(s.L.score2, [], 2);
[maxR, mIdxR] = max(s.R.score2, [], 2);
    
idx = mIdxL;
idx(maxR > maxL) = mIdxR(maxR > maxL);

nBurst = size(d.mu.bursts,1);
for i = 1:nBurst
    timeIdx = r.L.tbins >= d.mu.bursts(i,1) & r.L.tbins <= d.mu.bursts(i,2);
    
    nL(i) = sum(sum(r.L.spike_counts(:,timeIdx)));
    nR(i) = sum(sum(r.R.spike_counts(:,timeIdx)));
    sL(i) = s.L.score2(i, idx(i));
    sR(i) = s.R.score2(i, idx(i));
   
end

validIdx = (nL ~= 0 & nR ~= 0);

nL = nL(validIdx);
nR = nR(validIdx);
sL = sL(validIdx);
sR = sR(validIdx);
nBurst = sum(validIdx);


result.scoreCorr = corr2(sL, sR);
result.spikeNumCorr = corr2(nL, nR);

nShuffle = 500;

for i = 1:nShuffle
    shuffledIdx = randsample(nBurst, nBurst, 1);
    result.scoreShufCorr(i) = corr2(sL, sR(shuffledIdx));
    result.spikeNumShuffCorr(i) = corr2(nL, nR(shuffledIdx));
       
end

figure;


subplot(211);
plot(nL, nR,'.');
title('Number of Spikes')
xlabel('left');
ylabel('right');

subplot(212); 
plot(sL, sR, '.');
title('Replay Score');
xlabel('left');
ylabel('right');

a = plot_shuffles({result.spikeNumShuffCorr, result.scoreShufCorr}, [result.spikeNumCorr, result.scoreCorr ]);


xlabel(a(1), 'NSpike Correlation');
xlabel(a(2), 'ReplayScore Correlation');
ylabel(a(1), 'nEvents');
ylabel(a(2), 'nEvents');
title(a(1), 'NSpike');
title(a(2), 'Replay Score');



end