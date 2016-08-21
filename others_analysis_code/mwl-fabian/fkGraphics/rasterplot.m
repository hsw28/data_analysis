function h = rasterplot( events, varargin )
%RASTERPLOT
%
%  h=RASTERPLOT(events)
%

[hAx,args,nargs]=axescheck(varargin{:});
if isempty(hAx)
    hAx = gca;
end


tmp = handle([]);

for k=1:numel(events)
    tmp(k) = pointplot( events{k}, 'Height', 0.9, 'BackgroundAlpha', 0);
end

h = plotgroup(tmp(:), 'Parent', hAx, 'Spacing', 0.1);

