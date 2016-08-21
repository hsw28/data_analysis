function h=circle(varargin)
%CIRCLE draw a circle
%
%  h=CIRCLE(center,radius) draws a circle with specified center and
%  radius in current axes
%
%  h=CIRCLE(hax,...) draws circle in specified axes
%
%  h=CIRCLE(...,param1,val1,...) draws circle with additional
%  parameter/value pairs, which should be valid parameters for
%  rectangle function.
%

%  Copyright 2008-2008 Fabian Kloosterman


%default values
center = [0 0];
radius = 1;

%check arguments
[hAx, args, nargs] = axescheck(varargin{:});

if isempty(hAx)
    hAx = gca;
end

if nargs>0 && isnumeric(args{1}) && isequal(size(args{1}), [1 2])
    center = args{1};
    args(1)=[];
    nargs=nargs-1;
end

if nargs>0 && isnumeric(args{1}) && isscalar(args{1})
    radius = args{1};
    args(1)=[];
    nargs=nargs-1;
end

%create position vector
pos = [-1 -1 2 2].*radius + [center 0 0];

%create circle
h = rectangle(args{:}, 'Position', pos, 'Parent', hAx, 'Curvature', [1 1] );
h = handle(h);

%add properties
p_center = schema.prop(h, 'Center', 'MATLAB array');
set(p_center, 'SetFunction', @setCenter);

p_radius = schema.prop(h, 'Radius', 'double');

%set properties
h.Radius = radius;
h.Center = center;

%create listeners
l = handle.listener(h, [p_radius p_center], 'PropertyPostSet', @changedCircle);

p = schema.prop(h, 'PropertyListeners', 'handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'off';
p.Visible='off';

h.PropertyListeners = l;
p.AccessFlags.PublicSet = 'off';

h = double(h);


%------------------
%CALLBACK FUNCTIONS
%------------------

function val = setCenter(h, val)
if ~isnumeric(val) || ~isequal(size(val), [1 2])
    error('setCenter:invalidValue', 'Incorrect value for center property')
end

function changedCircle(hProp, eventdata)
h = eventdata.AffectedObject;
pos = [-1 -1 2 2].*h.Radius + [h.Center 0 0];
set(h, 'Position', pos);