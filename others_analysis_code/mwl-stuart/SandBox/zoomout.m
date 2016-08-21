function zoomout(ax, per)

if nargin==1
    per = ax;
    ax = gca;
end

if ~ishandle(ax)
    error('Invalid axes handle');
end

if ishandle(per)
    error('Invalid zoom value specified');
end

if isscalar(per)
    per = [per per];
end
if numel(per)>2
    error('Invalid zoom value specified');
end

xlim = get(ax,'Xlim');
ylim = get(ax,'Ylim');

dx = diff(xlim);
dy = diff(ylim);

mx = mean(xlim);
my = mean(ylim);

xlim(1) = mx - (dx/2) * per(1);
xlim(2) = mx + (dx/2) * per(1);

ylim(1) = my - (dy/2) * per(2);
ylim(2) = my + (dy/2) * per(2);

set(ax,'Xlim', xlim, 'Ylim', ylim);

end