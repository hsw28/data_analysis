function h = lineplot(x,y,varargin)
%LINEPLOT
%
%  h=LINEPLOT(x,y)
%
%  h=LINEPLOT(x,y,param1,val1,...)
%

%  Copyright 2008-2008 Fabian Kloosterman

[hParent,args,nargs] = axescheck(varargin{:}); %#ok
if isempty(hParent)
    hParent=gca;
end

h = handle( line( NaN, NaN, 'Parent', ancestor(hParent,'axes') ) );

hAx = handle( ancestor(h, 'axes') );

%add properties
p = schema.prop(h, 'Listeners', 'handle vector');
p.Visible = 'off';

p = schema.prop(h, 'DataX', 'MATLAB array');
%p.SetFunction = @setDataX;
p = schema.prop(h, 'DataY', 'MATLAB array');
%p.SetFunction = @setDataY;
p = schema.prop(h, 'DataIndex', 'MATLAB array');
p = schema.prop(h, 'Offset', 'double');
p = schema.prop(h, 'Height', 'double');
p.SetFunction = @setHeight;

p = schema.prop(h, 'Refresh', 'MATLAB array');
p.Visible = 'off';

set(h, 'Color', [0 0 0], 'Offset', 0, 'Height', 1);
set(h, 'DataX', x, 'DataY', y );
set(h, 'Refresh', @(varargin) refresh(h,varargin{:}) );

%create listeners
%L = handle.listener(hAx, findprop(hAx, 'TightInset'), 'PropertyPostSet', {@changedParent,h});
L = handle.listener(hAx, findprop(hAx, 'XLim'), 'PropertyPostSet', {@changedXLim,h});

p = [findprop(h,'Data')];
L(2) = handle.listener(h, p, 'PropertyPostSet', @refreshPlot);

p = [findprop(h,'Height') findprop(h, 'Offset')]; % findprop(h, 'OffsetMode')];
L(3) = handle.listener(h, p, 'PropertyPostSet', @refreshPosition_cb);

set(h, 'Listeners', L);

refresh(h);

set( h, 'Parent', hParent, args{:} );

function val=setData(h,val)

if ~isnumeric(val) || ndims(val)~=2 || size(val,2)~=2
    error('setPoints:invalidValue', 'Invalid data');
end

function val=setColor(h,val)

if ~isnumeric(val) || ndims(val)~=2 || size(val,2)~=3 || size(val,1)~=1 ...
        || any(val(:)<0 | val(:)>1)
    error('setColor:invalidValue', 'Invalid color data')
end

function val=setHeight(h,val)

if ~isnumeric(val) || val<=0
    error('setHeight:invalidValue', 'Invalid height')
end

function changedXLim(hProp, eventdata, h)
%disp('xlim changed')
h.Refresh(eventdata.NewVal);

function refreshPlot(hProp,eventdata,refresh)
eventdata.affectedObject.Refresh();

function refresh(h, xl)
%REFRESH refresh segment plot
%
%  REFRESH(h)
%

%  Copyright 2008-2008 Fabian Kloosterman

if isempty( h.DataX )
    return
end

if nargin<2
hAx = handle(ancestor(h, 'axes'));
%get xlimits
xl = hAx.XLim;
end

idxstart = binsearch( h.DataX, xl(1), 'nearest');
idxend = binsearch( h.DataX, xl(2), 'nearest');

%idxstart = find( h.Data(:,1)>=xl(1), 1, 'first' );
%idxend = find( h.Data(:,1)<=xl(2), 1, 'last');

set(h, 'DataIndex', [idxstart idxend]);

refreshPosition(h);

%n = idxend-idxstart + 1;

%if n>10000
    %idx = sort(randsample(idxstart:idxend,10000));
    
%    idx = sort( randsample( n, 10000 ) ) + (idxstart-1);
    
    %idx = randperm(n);
    %idx = sort( idx(1:10000) ) + (idxstart-1);
    
    %idx = idxstart:round(n/10000):idxend;
%else
    %idx = idxstart:idxend;
%end

%set(h, 'XData', h.DataX(idx), 'YData', h.DataY(idx) );

function refreshPosition_cb(hObj, eventdata)
refreshPosition( eventdata.affectedObject );

function refreshPosition(h)

h = handle(h);

idx = get(h, 'DataIndex');
n = diff(idx)+1;

if n>10000
    idx = sort( randsample( n, 10000 ) ) + (idx(1)-1);
else
    idx = idx(1):idx(2);
end

set(h, 'XData', h.DataX(idx), 'YData', h.DataY(idx) + h.Offset);
