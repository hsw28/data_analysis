function f = plot_bilateral_ripple_freq_correlations(data)

nShuffle = numel(data.spec.shuffleFreqCorr);
a = [];
bins = -1:.01:1;
offset = 20;


for i = 1:nShuffle
    f(i) = figure('Position',  [500 + i*offset   460 - i*offset   560   420]);

    % SPEC   
    a(end+1) = subplot (211);
    
    st = data.spec.rippleFreqCorr;
    sh = data.spec.shuffleFreqCorr{i};
    
    h = smoothn(histc(sh, bins));
    bar(bins, h, 1);
    line([st, st], [0, max(h)], 'color', 'r', 'lineWidth', 2)
    
    binsWithMass = bins(h>0);    
    lims = [min( min( binsWithMass), st) - .05 max( max( binsWithMass), st) + .05];
    set(a(end), 'XLim', lims);
    
    p = sum( sh > st) / numel(sh);
    title( sprintf( 'spec %s animal %2.2f', upper(data.spec.shuffleTypes{i}), p) )
    
    % MEAN
    a(end+1) = subplot (212);
    
    st = data.mean.rippleFreqCorr;
    sh = data.mean.shuffleFreqCorr{i};
    
    h = smoothn(histc(sh, bins));
    bar(bins, h, 1);
    line([st, st], [0, max(h)], 'color', 'r', 'lineWidth', 2)
    
    binsWithMass = bins(h>0);   
    lims = [min( min( binsWithMass), st) - .05 max( max( binsWithMass), st) + .05];
    set(a(end), 'XLim', lims);
    
    p = sum( sh > st) / numel(sh);
    title( sprintf( 'mean %s animal %2.2f',  upper(data.spec.shuffleTypes{i}), p) )    
end