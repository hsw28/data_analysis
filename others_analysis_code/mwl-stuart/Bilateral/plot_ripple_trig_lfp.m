
function [p, l] = plot_ripple_trig_lfp(data, a)

if nargin == 1 || isempty(a) || ~ishandle(a)
    figure();
    a = axes();
end


[p(1), l(1)] = error_area_plot(data.ts, data.meanLfp{1}, data.semLfp{1}, 'Parent', a);
[p(2), l(2)] = error_area_plot(data.ts, data.meanLfp{2}, data.semLfp{2}, 'Parent', a);

set(p(1), 'EdgeColor', 'none', 'FaceColor', [1 .7 .7]);
set(p(2), 'EdgeColor', 'none', 'FaceColor', [.7 1 .7]);

set(l(1), 'Color', [1 0 0 ], 'LineWidth', 2);
set(l(2), 'Color', [0 1 0 ], 'LineWidth', 2);

set(gca,'XLim', [-.21 .21]);

xlabel('Time');
ylabel('Amplitude');





