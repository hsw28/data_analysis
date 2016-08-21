function h = pointplot(points,varargin)
%POINTPLOT
%
%  h=POINTPLOT(points)
%
%  h=POINTPLOT(points,param1,val1,...)
%

%  Copyright 2008-2008 Fabian Kloosterman

[hParent,args,nargs] = axescheck(varargin{:}); %#ok
if isempty(hParent)
    hParent=gca;
end

%h = handle( hggroup('Parent', hAx) );
h = handle( image( 'CData', [], 'Parent', ancestor(hParent,'axes'), 'HandleVisibility', 'off' ) );

hAx = handle( ancestor(h, 'axes') );

%add properties
p = schema.prop(h, 'Listeners', 'handle vector');
p.Visible = 'off';

p = schema.prop(h, 'Points', 'MATLAB array');
p.SetFunction = @setPoints;
p = schema.prop(h, 'Color', 'MATLAB array');
p.SetFunction = @setColor;
p = schema.prop(h, 'BackgroundColor', 'MATLAB array');
p.SetFunction = @setColor;
p = schema.prop(h, 'Alpha', 'double');
p.SetFunction = @setAlpha;
p = schema.prop(h, 'BackgroundAlpha', 'double');
p.SetFunction = @setAlpha;
p = schema.prop(h, 'Offset', 'double');
%p = schema.prop(h, 'OffsetMode', 'string'); %bottom, middle, top
%p.SetFunction = @setOffsetMode;
p = schema.prop(h, 'Height', 'double');
p.SetFunction = @setHeight;
%p = schema.prop(h, 'Order', 'MATLAB array');
p = schema.prop(h, 'PixWidth', 'double');
p.Visible = 'off';
p = schema.prop(h, 'Refresh', 'MATLAB array');
p.Visible = 'off';

%p = schema.prop(h, 'hHandles', 'handle vector');
%p.Visible = 'off';

set(h, 'Color', [0 0 0], 'BackgroundColor', [1 1 1], 'Alpha', 1, 'BackgroundAlpha', 0, 'Offset', 0, 'Height', 1); %, 'OffsetMode', 'middle');
set(h, 'Points', points );
set(h, 'Refresh', @(varargin) refresh(h,varargin{:}) );

pixpos = getpixelposition(hAx);
set(h, 'PixWidth', pixpos(3) );

%h.hHandles = handle( image( 'CData', [], 'Parent', h, 'YData', [0 1] , 'HandleVisibility', 'off' ) );

%create listeners
L = handle.listener(hAx, findprop(hAx, 'TightInset'), 'PropertyPostSet', {@changedParent,h});
L(2) = handle.listener(hAx, findprop(hAx, 'XLim'), 'PropertyPostSet', {@changedXLim,h});

p = [findprop(h,'Points') findprop(h,'Color') findprop(h,'BackgroundColor') findprop(h,'Alpha') findprop(h,'BackgroundAlpha')];
L(3) = handle.listener(h, p, 'PropertyPostSet', @refreshPlot);

p = [findprop(h,'Height') findprop(h, 'Offset')]; % findprop(h, 'OffsetMode')];
L(4) = handle.listener(h, p, 'PropertyPostSet', @refreshPosition);

set(h, 'Listeners', L);

refresh(h);
refreshPosition([], struct('affectedObject', h));

set( h, 'Parent', hParent, args{:} );

function val=setPoints(h,val)

if ~isnumeric(val)
    error('setPoints:invalidValue', 'Invalid point data');
else
    val = val(:);
end

function val=setColor(h,val)

if ~isnumeric(val) || ndims(val)~=2 || size(val,2)~=3 || size(val,1)~=1 ...
        || any(val(:)<0 | val(:)>1)
    error('setColor:invalidValue', 'Invalid color data')
end

function val=setAlpha(h,val)

if ~isnumeric(val) || val<0 || val>1
    error('setAlpha:invalidValue', 'Invalid alpha data')
end

function val=setHeight(h,val)

if ~isnumeric(val) || val<=0
    error('setHeight:invalidValue', 'Invalid height')
end    

%function val=setOffsetMode(h,val)

%if ~ischar(val) || ~any(strcmpi(val, {'bottom', 'middle', 'top'}))
%    error('setOffsetMode:invalidValue', 'Invalid offset mode')
%else
%    val=lower(val);
%end


function changedXLim(hProp, eventdata, h)
%disp('xlim changed')
h.Refresh(eventdata.NewVal);

function changedParent(hProp, eventdata, h, refresh)
hAx = eventdata.affectedObject;
pixpos = getpixelposition(hAx);
if pixpos(3)~=h.PixWidth
    %disp('pixwidth changed')
    h.PixWidth = pixpos(3);
    h.Refresh();
end

function refreshPlot(hProp,eventdata,refresh)
eventdata.affectedObject.Refresh();

function refresh(h, xl)
%REFRESH refresh segment plot
%
%  REFRESH(h)
%

%  Copyright 2008-2008 Fabian Kloosterman

if isempty( h.Points )
    return
end

if nargin<2
hAx = handle(ancestor(h, 'axes'));
%get xlimits
xl = hAx.XLim;
end

b = seg2bin(xl, 'nbins', h.pixwidth, 'method', 'nbins');
mb = mean( b, 2);

col = permute([h.BackgroundColor;h.Color], [3 1 2]);

data = event2bin(h.Points,b,'method','binary');
alpha = data;
alpha(alpha==0) = h.BackgroundAlpha;
alpha(data~=0) = h.Alpha;

%data( ~data ) = NaN;

%tmp = bsxfun(@times, data, col );
tmp = col( :, data+1, : );

%tmp(:,~logical(alpha),:) =  bsxfun(@plus,tmp(:,~logical(alpha),:), permute([0.95 0.95 0.95], [1 3 2]) );
  
if size(tmp,1)==1
    tmp = [tmp;tmp];
    alpha = [alpha;alpha];
end
  
set( h, 'CData', tmp, 'AlphaData', alpha );

set( h, 'XData', xl(1)+[0.5 h.PixWidth-0.5]*diff(xl)./h.PixWidth);


function refreshPosition(hObj,eventdata)

h = eventdata.affectedObject;

% switch h.OffsetMode
%     case 'bottom'
%         extra_offset = 0;
%     case 'middle'
%         extra_offset = -0.5;
%     case 'top'
%         extra_offset = -1;
% end

%set( h, 'YData', extra_offset*h.Height + h.Offset + [0 h.Height] + [0.5 -0.5] .* h.Height./2);
set( h, 'YData', h.Offset + [0 h.Height] + [0.5 -0.5] .* h.Height./2);