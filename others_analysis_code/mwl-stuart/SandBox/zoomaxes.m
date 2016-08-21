function zoomaxes(ax, percent)

xlim = get(ax,'Xlim');
ylim = get(ax,'Ylim');

dx = diff(xlim);
dy = diff(ylim);

mx = mean(xlim);
my = mean(ylim);

xlim(1) = mx - (dx/2) * percent;
xlim(2) = mx + (dx/2) * percent;

ylim(1) = my - (dy/2) * percent;
ylim(2) = my + (dy/2) * percent;

set(ax,'Xlim', xlim, 'Ylim', ylim);


end