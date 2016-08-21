
%% Ripple Triggered Spindle Peaks
% load data using ---> ctx_spindles_detect_hpc_mu.m
fig = figure('position',[372 448 940 402] );
ax = axes('Position', [0.0340 0.0970 0.9479 0.7836]);

tbins = -.5:.005:.5;

c = 'b';

[~, cTs, counts] = meanTriggeredEvent(ripplePeakTs, spindlePeaksAllTs, tbins);


%[p, l] = plot_mean_trigs(cTs, mc, sc, nBoot,c,ax);
cts = sum(counts);
cts = smoothn( cts, 2, 'correct', 1);

area(cTs, cts);

yLims = get(ax,'YLim');
zl = line([0 0], yLims, 'color', 'k', 'linestyle', '-', 'parent', ax);
uistack(zl,'bottom');


title( sprintf('%s %s %s Ripple Trigggered Spindle Peaks', animal, day, epoch));
set(ax,'YLim', yLims, 'Xlim', minmax(tbins));

% [p, l] = error_area_plot(ts, mc, sc * 1.96 / sqrt(nRip), 'parent', ax);
%set(p,'EdgeColor', c, 'FaceColor', c, 'FaceAlpha', .1);
%set(l,'Color', c);

%% Ripple Triggered Spindle Band
% load data using ---> ctx_spindles_detect_hpc_mu.m
close all;
fig = figure('position',[372 448 940 402] );
ax = axes('Position', [0.0340 0.0970 0.9479 0.7836]);

win = [-.5 .5];



faceCol = 'gr';
lineCol = {[0 .6 0], [.6 0 0]};

for i = fliplr(1:numel(rippleTrig))

    nRip = numel(rippleTrig{i});
    [mSpinBand, sSpinBand, winTs] = meanTriggeredSignal(ripplePeakTs, ctxTs, spindleBand, win);

    [p(i), l(i)] = error_area_plot(winTs, mSpinBand, 1.96 * sSpinBand / sqrt(nRip), 'parent', ax);

    set(p(i), 'FaceColor', faceCol(i), 'edgecolor', 'none', 'facealpha',.3);
    set(l(i), 'Color', lineCol{i}, 'linewidth', 2);

end


yLims = get(ax,'YLim');
zl = line([0 0], yLims, 'color', 'k', 'linestyle', '-', 'parent', ax);
uistack(zl,'top');

title( sprintf('%s %s %s Ripple Trigggered Spindle Peaks', animal, day, epoch));
set(ax,'YLim', yLims, 'Xlim', win);

%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('ripple_triggered_%s_SPIN_band_%s_%s_%s', ctxAnat, animal,day,epoch);
saveFigure(gcf, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');

% [p, l] = error_area_plot(ts, mc, sc * 1.96 / sqrt(nRip), 'parent', ax);
%set(p,'EdgeColor', c, 'FaceColor', c, 'FaceAlpha', .1);
%set(l,'Color', c);


% %%
% % load data using ---> ctx_spindles_detect_hpc_mu.m
% fig = figure('position',[372 448 940 402] );
% ax = axes('Position', [0.0340 0.0970 0.9479 0.7836]);
% 
% tbins = -1:.005:1;
% 
% c = 'b';
% 
% [meanCount, cTs, countsFiltered] = meanTriggeredEvent(ripplePeakTs(RipSpinCollisionIdx), spindlePeaksAllTs, tbins);
% 
% %bootMean = mean( bootstrp(@mean, 1000, countsFiltered);
% bootCi = bootci(1000, @mean, countsFiltered);
% 
% nBoot = size(bootCount,1);
% 
% mc = smoothn(bootMean,3, 'correct', 1);
% sc = smoothn(bootStd,3, 'correct', 1);
% 
% plot(cTs, ciCountSm);
% yLims = get(ax,'YLim');
% zl = line([0 0], yLims, 'color', 'k', 'linestyle', '-', 'parent', ax);
% uistack(zl,'bottom');
% 
% 
% title( sprintf('%s %s %s Ripple Trigggered Spindle Peaks', animal, day, epoch));
% set(ax,'YLim', yLims);
% % [p, l] = error_area_plot(ts, mc, sc * 1.96 / sqrt(nRip), 'parent', ax);
% set(p,'EdgeColor', c, 'FaceColor', c, 'FaceAlpha', .1);
% set(l,'Color', c);
% %% Ripple Triggered Spindle Peaks
% % load data using ---> ctx_spindles_detect_hpc_mu.m
% fig = figure('position',[372 448 940 402] );
% ax = axes('Position', [0.0340 0.0970 0.9479 0.7836]);
% 
% tbins = -1:.005:1;
% 
% c = 'b';
% 
% 
% [~, ~, ~, counts] = meanTriggeredEvent(ripplePeakTs, spindlePeaksAllTs, tbins);
% 
% sumCounts = smoothn(sum(counts),3);
% 
% [b] = fill([cTs(1) cTs cTs(end)], [0 sumCounts 0],'r');
% yLims = get(ax,'YLim');
% zl = line([0 0], yLims, 'color', 'k', 'linestyle', '-', 'parent', ax);
% uistack(zl,'bottom');
% 
% 
% title( sprintf('%s %s %s Ripple Trigggered Spindle Peaks', animal, day, epoch));
% set(ax,'YLim', yLims);
% % [p, l] = error_area_plot(ts, mc, sc * 1.96 / sqrt(nRip), 'parent', ax);
% set(b,'EdgeColor', c, 'FaceColor', c, 'FaceAlpha', .1);
% 
% 
% 



