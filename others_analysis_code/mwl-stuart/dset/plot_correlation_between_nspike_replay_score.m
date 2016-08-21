
function f = plot_correlation_between_nspike_replay_score(results, all)
f(1) = figure('Position', [ 683   612   588   391]);

subplot(211);
hist(results.scoreCorrShuf); 
y = get(gca,'YLim');
line([results.scoreCorr, results.scoreCorr], y, 'Color', 'r');
title('Replay Event Score');

subplot(212);
hist(results.perCorrShuf); 
y = get(gca,'YLim');
line([results.perCorr, results.perCorr], y, 'Color', 'r');
title('Percent Cells in Event');

f(2) = figure('Position', [219   209   460   792]);

subplot(211);
plot(all.perSpike{1}, all.perSpike{2}, '.'); title('Percent Spikes Active');
subplot(212);
plot(all.score{1}, all.score{2}, '.'); title('Replay Event Score');
    
end