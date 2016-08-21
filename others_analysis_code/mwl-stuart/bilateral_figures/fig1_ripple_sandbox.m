dset = dset_load_all('spl11', 'day11', 'sleep2');

rips = dset_calc_ripple_params(dset);
%%

data = ripPhaseSleep.dPhase;

edges = linspace(-pi, pi, 17);
ctrs = edges(1:end-1) + (edges(2)-edges(1))/2;

count = histc(data, edges);
count = count(1:end-1);

count = count / sum(count);

%%


[p, z] = circ_rtest(ctrs, count);

%%
rPhase = calc_bilateral_ripple_phase_diff(ripples.run);
rFreq = calc_bilateral_ripple_freq_distribution(ripples.run);


figure ('Position', [100 500 1300 225]); 
subplot(131);
plot(rPhase.phase(:,1), rPhase.phase(:,3), '.r', rPhase.phase(:,1), rPhase.phase(:,2), 'g.');

subplot(132);
bins = linspace(-pi, pi, 16);

ips = histc(rPhase.dPhaseIpsi, bins);
con = histc(rPhase.dPhaseCont, bins);
ips = ips ./ sum(ips);
con = con ./ sum(con);

plot(bins, con, 'r'); hold on; plot(bins, ips, 'g');

subplot(133); 
plot(rFreq.base, rFreq.cont, 'r.', rFreq.base, rFreq.ipsi, 'g.');


%%

plot(r.phase(:,1), r.phase(:,2), '.'); hold on;
plot(r.phase(:,1), r.phase(:,3), 'r.');

%%
meanRip = calc_ripple_triggered_mean_lfp(rips);

figure;
ts = meanRip.ts;

plot(ts, meanRip.meanLfp{1}, ts, meanRip.meanLfp{2}, ts, meanRip.meanLfp{3});
%%

close all;
bins = [];
h =[];
[h(1), ax] = polar_hist(ripPhaseRun.dPhaseIpsi, bins, 1);
[h(3)] = polar_hist(ax, ripPhaseRun.dPhaseCont, bins, 1);
[h(2)] = polar_hist(ax, ripPhaseRun.dPhaseIpsi, bins, 1);
set(h(1:2), 'EdgeColor', 'k');

set(h(3), 'EdgeColor', 'k','faceColor', 'r');

set(h(1:2), 'FaceColor', 'b');


