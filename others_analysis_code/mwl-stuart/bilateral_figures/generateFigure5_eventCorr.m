function stats = generateFigure5_eventCorr(ep)
%%

clear stats;

eList = dset_list_epochs(ep);
nEpoch = size(eList,1);

stats = struct('quantiles', [], 'realCorrQuantiles', [], 'shufCorrQuantiles', [], 'pVal', [], 'eventCorrVals', [], 'eventCorrValsShuf', []);
stats = repmat(stats, 10, 1);

parfor i = 1:nEpoch
    
    d = dset_load_all( eList{i,:} );
    
    stats(i) = calc_bilateral_replay_corr(d, 1);
   
end

return;
%%
q = stats(1).quantiles;
qReal = cell2mat( {stats.realCorrQuantiles}');
qShuf = cell2mat( {stats.shufCorrQuantiles}');

f = figure; 
axes('NextPlot', 'add');

r = qReal(:, q == .5 );
s = qShuf(:, q == .5 );

line(1:2, [r,s], 'color', [.8 .8 .8]);
boxplot([r,s]); 

p = ranksum( r, s, 'tail', 'right');
title( sprintf('Median Event Corr') )

fprintf('p:%3.4g\tp:%3.4g\n', [ranksum(r,s, 'tail', 'right') signrank(r,s, 'tail', 'right')]);


set( get(gcf,'children'), 'YLim', [-.5 1], 'XTick', [1 2], 'XTickLabel', {'Real', 'Shuf'});

figName = sprintf('Figure5-EventCorrVsShuff-boxplot-%s',ep);
save_bilat_figure(figName, f);


%%
end
