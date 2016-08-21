function h = plotgroup(varargin)
%PLOTGROUP
%
%  h=PLOTGROUP(plot1,plot2,...)
%
%  h=PLOTGROUP(plot1,plot2,...,param1,val1,...)
%

%  Copyright 2008-2008 Fabian Kloosterman

%check for axes in input arguments
[hParent,args,nargs] = axescheck(varargin{:}); %#ok
if isempty(hParent)
    hParent=gca;
end

%find idx of first option
option_idx = find( cellfun('isclass', args, 'char'), 1, 'first' );
if isempty(option_idx)
    nplots = nargs;
else
    nplots = option_idx-1;
end


%create hgtransform object
h = handle( hgtransform('Parent', ancestor(hParent, 'axes') ) );

%get handle of parent axes
hAx = handle( ancestor(h, 'axes') );

%add properties
p = schema.prop(h, 'Height', 'double'); % height of plotgroup
p.SetFunction = @setHeight;
p.GetFunction = @getHeight;
p = schema.prop(h, 'HeightMode', 'string'); % 'manual' height is determined by Height property
p.SetFunction = @setHeightMode;             % 'auto' height of plotgroup is determined by the plots
p = schema.prop(h, 'Offset', 'double'); % offset of plotgroup
p = schema.prop(h, 'Spacing', 'MATLAB array'); % absolute spacing between plots
p.SetFunction = @setSpacing;                   % if HeightMode='manual', the spacing is applied
                                               % before the plotgroup is scaled to fit the desired
                                               % height
p = schema.prop(h, 'Order', 'MATLAB array'); % Display order of plots (top to bottom)
p.SetFunction = @setOrder;
p = schema.prop(h, 'Refresh', 'MATLAB array'); % refresh function

p = schema.prop(h, 'Listeners', 'handle vector'); % listeners
p.Visible ='off';
p = schema.prop(h, 'PlotListeners', 'handle vector'); % plot listeners
p.Visible ='off';

set(h, 'Height', 1, 'HeightMode', 'auto', 'Offset', 0, 'Order', [], 'Spacing', 0);
set(h, 'Refresh', @() refresh(h));

%L = handle([]);

% for k=1:nargs
%     if isprop(args{k}, 'Offset') && isprop(args{k}, 'Height') && isequal( hAx, handle( ancestor(args{k},'axes') ) )
%         h.Plots(end+1) = handle(args{k});
%         p = [findprop(h.Plots(end), 'Offset') findprop(h.Plots(end), 'Height')];
%         L(end+1) = handle.listener(h.Plots(end), p, 'PropertyPostSet', {@refreshGroup,h} );
%         set(args{k}, 'Parent', h );
%     else
%         warning('plotgroup:invalidPlot', 'Invalid plot')
%     end
% end

%set(h, 'Order', (1:numel(h.Plots))');

%create listeners
set(h, 'PlotListeners', handle([]));

p = [findprop(h,'Height') findprop(h,'Offset') findprop(h,'Spacing') findprop(h,'Order') findprop(h,'HeightMode')];
L = handle.listener(h, p, 'PropertyPostSet', @changedProp);
L(end+1) = handle.listener(h, 'ObjectChildAdded', @addedChild );
L(end+1) = handle.listener(h, 'ObjectChildRemoved', @removedChild );

set(h, 'Listeners', L);


if nplots>0

    for k=1:nplots
        set( args{k}, 'Parent', h );
    end
    
end

refresh(h);

set( h, 'Parent', hParent, args{option_idx:end} );

function addedChild(hObj,eventdata)
%check new child
if ~isprop(eventdata.Child, 'Offset') || ~isprop(eventdata.Child, 'Height') || ~isequal( ancestor(hObj,'axes'), ancestor(eventdata.Child,'axes') )
    warning('addChild:invalidChild', 'Not a valid plot. Reparented to axes');
    set( eventdata.Child, 'parent', ancestor( hObj, 'axes') );
else
    hObj.Order(end+1) = numel(hObj.Order)+1;
    p = [findprop(eventdata.Child, 'Offset') findprop(eventdata.Child, 'Height') findprop(eventdata.Child, 'HeightMode') findprop(eventdata.Child, 'Visible')];
    %if isprop(eventdata.Child, 'Spacing')
    %    p(end+1) = findprop(eventdata.Child, 'Spacing');
    %end
    tmp = double(hObj);
    L = handle.listener(eventdata.Child, p, 'PropertyPostSet', {@refreshGroup, tmp} );
    if isempty(hObj.PlotListeners)
        hObj.PlotListeners = L;
    else
        hObj.PlotListeners(end+1) = L;
    end
end

function removedChild(hObj,eventdata)
order = hObj.order;
children = allchild( double(hObj) );
idx = find(children == eventdata.Child);
order( idx ) = [];
[order, order] = sort(order);
set(hObj.Listeners, 'Enabled', 'off'); 
hObj.Order = order;
set(hObj.Listeners, 'Enabled', 'on'); 
hObj.PlotListeners(idx) = [];

function refreshGroup(hObj, eventdata, h)
%fprintf('fire! %f %f\n', double(eventdata.affectedObject), double(h));
h = handle(h);
h.Refresh();

function val=setHeight(h,val)

if ~isnumeric(val) || val<0
    error('setHeight:invalidValue', 'Invalid height')
else
    %h.HeightMode = 'manual';
end    

function val=setHeightMode(h,val)
if ~any(strcmpi(val, {'auto','manual'}))
    error('setHeightMode:invalidValue', 'Invalid height mode');
else
    val = lower(val);
end

function val=setSpacing(h,val)
if isscalar(val) || numel(val)==numel(allchild(double(h)))
    val = val(:);
else
    error('setSpacing:invalidValue', 'Invalid spacing');
end
    

function val=setOrder(h,val)
children = allchild(double(h));
n = numel(children) - numel( find( strcmp( get( children, 'BeingDeleted'), 'on' ) ) );

if (n==0 && isempty(val)) || (numel(val)==n && all(ismember(1:n, val)))
    val = val(:);
else
    error('setOrder:invalidValue', 'Invalid order');
end

function val=getHeight(h,val)

%if strcmp(h.HeightMode, 'auto')
    %compute total height based on height of plots and spacing
%    [height, offset]=computeLayout(h);
%    val = max(height+offset);
%end

function changedProp(hObj,eventdata)

h = eventdata.affectedObject;
if strcmpi(eventdata.Source.Name, 'Height')
    set(h, 'HeightMode', 'manual');
end

h.Refresh();

function [height, offset] = computeLayout(children, spacing)

nplots = numel(children);
if nplots==0
    height = 0;
    offset = 0;
    return
elseif nplots==1
    height = get(children,'Height');
else
    height = cell2mat(get(children, 'Height'));
end

%spacing = h.Spacing;
if isscalar(spacing)
    spacing = zeros(nplots-1,1)+spacing;
end

%switch h.SpacingMode
%    case 'absolute'
offset = cumsum( [0;height(1:end-1)] + [0;spacing] );
%    case 'relative'
%        offset = cumsum( [0;height(1:end-1)] + [0;spacing.*height(1:end-1)] );
%end

%offset = offset - min(offset);

%totalheight = max( offset + height );

%if strcmp(h.HeightMode, 'manual')
%    sf = h.Height ./ totalheight;
%    height = height.*sf;
%    offset = offset.*sf;
%end
    


function refresh(h)

children = allchild(double(h));

if numel(children)==0
    return
end

visible = find( strcmp( get(children, 'Visible' ), 'on' ) );

idx = ismember( h.Order, visible );

[height, offset] = computeLayout(children(h.Order(idx)), h.Spacing);

%offset = offset + h.Offset;
set(h.PlotListeners,  'Enabled', 'off');
set(children(visible), {'Height', 'Offset'}, mat2cell([height(h.Order(idx)) offset(h.Order(idx))], ones(numel(visible),1), [1 1]) );
set(h.PlotListeners,  'Enabled', 'on');

totalheight = max( offset + height ) - min(offset); 

if strcmp(h.HeightMode, 'auto')
    set(h.Listeners,  'Enabled', 'off');
    set(h, 'Height', totalheight);
    set(h.Listeners,  'Enabled', 'on');    
end

if totalheight==0
    T = makehgtform('translate', [0 h.Offset 0], 'scale', [1 1 1], 'translate', [0 -min(offset) 0]);
else
    T = makehgtform('translate', [0 h.Offset 0], 'scale', [1 h.Height./totalheight 1], 'translate', [0 -min(offset) 0]);
end
set(h, 'Matrix', T);

