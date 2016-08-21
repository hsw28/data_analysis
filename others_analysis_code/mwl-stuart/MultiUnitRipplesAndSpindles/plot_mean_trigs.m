function [p, l] = plot_mean_trigs(ts, m, s, n, c, a)

if ~iscell(m) 
    m = {m};
    s = {s};
    n = {n};

end

if isempty(a) || ~ishandle(a) 
    a = gca;
end

N_STD = 1.96;

p = [];
l = [];

maxY = -Inf;
minY = Inf;
for i = fliplr( 1:numel(m) )
    
    [p(i),  l(i)] = ...
        error_area_plot(ts, m{i}, s{i} .* N_STD ./ sqrt(n{i}), 'Parent', a);
    
    set(p(i),'FaceColor', c(i), 'EdgeColor', c(i), 'facealpha', .1);
    set(l(i),'Color',c(i), 'linewidth', 1);
    
    minY = min(minY, min(get(p(i), 'YData')));
    maxY = max(maxY, max(get(p(i), 'YData')));
    
end

set(l,'Visible', 'off');
set(a,'YLim', [minY maxY]);
zoomout(a, [1 1.1]);



end