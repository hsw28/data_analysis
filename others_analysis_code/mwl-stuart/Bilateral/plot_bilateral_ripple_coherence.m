function f = plot_bilateral_ripple_coherence(data, correct_baseline, ax)

if nargin==1
    correct_baseline=0;
end

if nargin<2
    ax = [];
elseif ~ishandle(ax)
    ax = [];
end

nShuffle = numel(data.shuffleCoherence);
nRipple = size(data.rippleCoherence,1);

meanRipCo = mean( data.rippleCoherence );
stdRipCo = std( data.rippleCoherence);

nS = 3;
offset = 20;
[a, f, p, l] = deal([]);


baseRip = 0;
baseShf = 0;

if correct_baseline == 1
   baseIdx = data.F > 270 & data.F < 500;
   baseRip = mean( meanRipCo( baseIdx ));
end

for i = 1:nShuffle
    if isempty(ax)
        f(i) = figure('Position',  [500 + i*offset   460 - i*offset   560   420]);
        a(i) = axes();
    else
        a(i) = ax;
    end

    meanShfCo = mean( data.shuffleCoherence{i} );
    stdShfCo = std( data.shuffleCoherence{i} );
    
    if correct_baseline == 1
        baseShf = mean( meanShfCo( baseIdx) );
    end

    
    [p(end+1), l(end+1)] = error_area_plot(data.F, meanRipCo - baseRip, nS * stdRipCo/sqrt(nRipple) , 'Parent', a(i) );
    [p(end+1), l(end+1)] = error_area_plot(data.F, meanShfCo - baseShf, nS * stdShfCo/sqrt(nRipple) , 'Parent', a(i) );
    
    title(sprintf('Bilat Rip Coherence vs %s shuffle', data.shuffleType{i}));
    
    legend(l( [1:2] + (i-1)*2), {'Data','Shuffle'});
end

set(l([1:2:end]), 'Color', [1 0 0], 'LineWidth', 2);
set(l([2:2:end]), 'Color', [0 1 0], 'LineWidth', 2);
set(p([1:2:end]), 'FaceColor', [1 .7 .7], 'edgecolor', 'none');
set(p([2:2:end]), 'FaceColor', [.7 1 .7], 'edgeColor', 'none');

set(a, 'Xlim', [0 450], 'YLim', [-.04 .7]);




%
% figure('Position', [500 200 400 800], 'name', ['nfft/',num2str(nfft/noverlap)]);
% a = [ subplot(211); subplot(212)];
% p = zeros(4,1);
% l = zeros(4,1);
% 
% nS = 2;
% 
% 
% 
% 
% [p(1), l(1)] = error_area_plot(F, meanRipCo, nS * stdRipCo/sqrt(nRipple) , 'Parent', a(1) );
% [p(2), l(2)] = error_area_plot(F, meanRipCo, nS * stdRipCo/sqrt(nRipple) , 'Parent', a(2) );
% 
% [p(3), l(3)] = error_area_plot(F, meanShfCo, nS * stdShfCo/sqrt(nRipple) , 'Parent', a(1) );
% [p(4), l(4)] = error_area_plot(F, mRipShCo2, nS * sRipShCo2/sqrt(nRipple) , 'Parent', a(2) );
% 
% % set the limits on the axes
% set(a, 'XLim', [0 350], 'YLim', [.1 .75]);
% 
% % style the error patches
% set(p, 'LineStyle', 'none', 'FaceColor', [.4 .4 .4]);
% 
% %style the center lines
% set(l, 'Color', 'k', 'LineWidth', 2 );
% 
% 
% title(sprintf('%s %s ref-%d args:%s win:%d', EPOCH, DATA_SRC, USE_REF, cell2str(coherenceArgs), numel(winIdx)) ,'Parent', a(1), 'FontSize', 14);

end