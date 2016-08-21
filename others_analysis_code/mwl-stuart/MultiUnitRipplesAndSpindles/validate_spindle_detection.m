
figure('Position', [1700 585 1736 410]);
a = axes('Position', [.0253 .0756 .9712 .8902]);
line_browser(ctxTs, ctxLfp, 'parent', a);

line_browser(ctxTs, spindleBand * 3, 'color', 'g', 'parent', a);

spinVar = spindlePeaksAllTs;

x = nan(3 * numel(spinVar), 1);

x(1:3:end) = spinVar;
x(2:3:end) = spinVar;
x(3:3:end) = spinVar;

y = nan(size(x));

y(1:3:end) = -500;
y(2:3:end) = 500;

line(x,y,'Color', 'r','Parent', gca);

    