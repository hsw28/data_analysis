function schema
%SCHEMA class definition for polaraxes
%
%  SCHEMA
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------DEFINE CLASS-------

%get fkGraphics package
pkg = findpackage('fkGraphics');
%get handle graphics package
pkgHG = findpackage('hg');

%define polaraxes class, use axes as baseclass
h = schema.class(pkg,'polaraxes',pkgHG.findclass('axes'));
h.Description = 'Polar axes';

%-------DEFINE TYPES-------

%define enumerated types specific for polar axes

if isempty(findtype('RadialDirType'))
  schema.EnumType('RadialDirType',{'normal','reverse'});
end

if isempty(findtype('AngleDirType'))
  schema.EnumType('AngleDirType',{'cw', 'ccw'});
end

if isempty(findtype('AngleTickUnitsType'))
  schema.EnumType('AngleTickUnitsType',{'radians','degrees','none'});
end

if isempty(findtype('AngleTickDirType'))
  schema.EnumType('AngleTickDirType',{'in','out','both'});
end

if isempty(findtype('RadialTickDirType'))
  schema.EnumType('RadialTickDirType',{'+','-','both'});
end

if isempty(findtype('AngleTickSignType'))
  schema.EnumType('AngleTickSignType',{'signed','unsigned'});
end

if isempty(findtype('PolarAxesStyleType'))
  schema.EnumType('PolarAxesStyleType',{'cartesian','compass','custom'});
end  

%initialize variables
l = []; %will hold listeners
markDirtyProp = []; %will hold properties


%-------DEFINE PROPERTIES-------

%dirty flag property
p = schema.prop(h, 'Dirty', 'DirtyEnum');
p.Description='Whether axes needs refresh';
p.FactoryValue = 'invalid';
p.Visible = 'off';

%refresh mode property
p2 = schema.prop(h, 'RefreshMode', 'axesXLimModeType');
p2.Description='Auto/manual refresh mode';
p2.FactoryValue = 'manual';
p2.Visible = 'off';

%create listeners for triggering a refresh
%always put dirty listener first in list
l = Lappend(l,handle.listener(h, [p p2], 'PropertyPostSet',@LdoDirtyAction));

%create properties for graphical object handles
p=schema.prop(h, 'BackgroundHandle', 'handle vector'); %#ok
p.Description='Handle for background patch';
p.Visible = 'off';
p=schema.prop(h, 'AngleAxisHandle', 'handle vector'); %#ok
p.Description='Handles for angular axis objects';
p.Visible = 'off';
p=schema.prop(h, 'AngleGridHandle', 'handle vector'); %#ok
p.Description='Handles for angular grid objects';
p.Visible = 'off';
p=schema.prop(h, 'AngleTicksHandle', 'handle vector'); %#ok
p.Description='Handles for angular tick mark objects';
p.Visible = 'off';
p=schema.prop(h, 'AngleLabelsHandle', 'handle vector'); %#ok
p.Description='Handles for angular tick label objects';
p.Visible = 'off';
p=schema.prop(h, 'RadialAxisHandle', 'handle vector'); %#ok
p.Description='Handles for radial axis objects';
p.Visible = 'off';
p=schema.prop(h, 'RadialGridHandle', 'handle vector'); %#ok
p.Description='Handles for radial grid objects';
p.Visible = 'off';
p=schema.prop(h, 'RadialTicksHandle', 'handle vector'); %#ok
p.Description='Handles for radial tick mark objects';
p.Visible = 'off';
p=schema.prop(h, 'RadialLabelsHandle', 'handle vector'); %#ok
p.Description='Handles for radial tick label objects';
p.Visible = 'off';
p=schema.prop(h, 'BackgroundLayer', 'handle'); %#ok
p.Description='Handle for background layer hggroup';
p.Visible='off';
p=schema.prop(h, 'AngleAxisLayer', 'handle'); %#ok
p.Description='Handle fot angular axis layer hggroup';
p.Visible='off';
p=schema.prop(h, 'RadialAxisLayer', 'handle'); %#ok
p.Description='Handle fot radial axis layer hggroup';
p.Visible='off';

%polar axes angle units
p = schema.prop(h,'AngleUnits', 'AngleUnitsType'); %#ok
p.Description='Angular units used (radians or degrees)';
p.FactoryValue='radians';

%limits for angular axis
p = schema.prop(h,'AngleLim', 'MATLAB array');
p.Description='Angular axes limits';
p.FactoryValue = [0 2*pi];
markDirtyProp = Lappend(markDirtyProp,p);

%limits for radial axis
p = schema.prop(h,'RadialLim', 'MATLAB array');
p.Description='Radial axis limits';
p.FactoryValue = [0 1];
markDirtyProp = Lappend(markDirtyProp,p);

%rotation of axes
p = schema.prop(h,'AxesRotation', 'double'); %#ok
p.Description='Polar axes rotation';
p.FactoryValue = 0;

%direction of radial axis
p = schema.prop(h,'RadialDir', 'RadialDirType');
p.Description='Direction of radial axis (normal or reverse)';
p.FactoryValue = 'normal';
markDirtyProp = Lappend(markDirtyProp,p);

%direction of angular axis
p = schema.prop(h,'AngleDir', 'AngleDirType'); %#ok
p.Description='Direction of angular axis (cw or ccw)';
p.FactoryValue = 'ccw';

%font color
p = schema.prop(h,'FontColor', 'color'); %#ok
p.Description='Font color';
p.FactoryValue = [0 0 0];

%rotation of radial axis
p = schema.prop(h,'RadialAxisRotation', 'double'); %#ok
p.Description='Rotation of radial axis';
p.FactoryValue = 5*pi/12;

%radial axis line style
p = schema.prop(h,'RadialAxisLineStyle', 'lineLineStyleType'); %#ok
p.Description='Radial axis line style';
p.FactoryValue = '-';

%radial axis color
p = schema.prop(h,'RadialAxisColor', 'color'); %#ok
p.Description='Radial axis line color';
p.FactoryValue = [0 0 0];

%radial axis line width
p = schema.prop(h,'RadialAxisLineWidth', 'double'); %#ok
p.Description='Radial axis line width';
p.FactoryValue = 1;

%visibility of radial axis
p = schema.prop(h,'RadialAxisVisible', 'on/off'); %#ok
p.Description='Whether radial axis is visible';
p.FactoryValue = 'on';

%units of radial axis ticks
p = schema.prop(h,'RadialTickUnits', 'string'); %#ok
p.Description='Tick units of radial axis';
p.FactoryValue = '';

%values of radial axis ticks
p = schema.prop(h,'RadialTickValues', 'MATLAB array'); %#ok
p.Description='Tick mark values for radial axis';
p.FactoryValue = 'auto';

%labels for radial axis ticks
p = schema.prop(h,'RadialTickLabels', 'MATLAB array'); %#ok
p.Description='Tick mark labels for radial axis';
p.FactoryValue = 'auto';

%visibility of radial axis tick labels
p = schema.prop(h,'RadialTickLabelsVisible', 'on/off'); %#ok
p.Description='Whether radial tick mark labels are visible';
p.FactoryValue = 'on';

%offsets for radial axis tick labels
p = schema.prop(h,'RadialTickLabelsOffset', 'MATLAB array'); %#ok
p.Description='Radial and tangential offsets of radial axis tick mark labels';
p.FactoryValue = [0.01 0.03];

%rotation of radial axis tick labels
p = schema.prop(h,'RadialTickLabelsAngle', 'MATLAB array'); %#ok
p.Description='Rotation of radial axis tick mark labels';
p.FactoryValue = 'auto';

%line style radial grid
p = schema.prop(h,'RadialGridLineStyle', 'lineLineStyleType'); %#ok
p.Description='Radial grid line style';
p.FactoryValue = ':';

%color of radial grid
p = schema.prop(h,'RadialGridColor', 'color'); %#ok
p.Description='Radial grid line color';
p.FactoryValue = [0.5 0.5 0.5];

%line width of radial grid
p = schema.prop(h,'RadialGridLineWidth', 'double'); %#ok
p.Description='Radial grid linw width';
p.FactoryValue = 1;

%visibility of radial grid
p = schema.prop(h,'RadialGridVisible', 'on/off'); %#ok
p.Description='Radial grid visibility';
p.FactoryValue = 'on';

%line style for angular axis
p = schema.prop(h,'AngleAxisLineStyle', 'lineLineStyleType'); %#ok
p.Description='Angular axis line style';
p.FactoryValue = '-';

%color of angular axis
p = schema.prop(h,'AngleAxisColor', 'color'); %#ok
p.Description='Angular axis line color';
p.FactoryValue = [0 0 0];

%line width of angular axis
p = schema.prop(h,'AngleAxisLineWidth', 'double'); %#ok
p.Description='Angular axis line width';
p.FactoryValue = 1;

%visibility of angular axis
p = schema.prop(h,'AngleAxisVisible', 'on/off'); %#ok
p.Description='Angular axis visibility';
p.FactoryValue = 'on';

%angular axis tick units
p = schema.prop(h,'AngleTickUnits', 'AngleTickUnitsType'); %#ok
p.Description='Angular axis tick units (radians, degrees or none)';
p.FactoryValue = 'radians';

%angular axis tick values
p = schema.prop(h,'AngleTickValues', 'MATLAB array'); %#ok
p.Description='Tick mark values for angular axis';
p.FactoryValue = 'auto';

%angular axis tick labels
p = schema.prop(h,'AngleTickLabels', 'MATLAB array'); %#ok
p.Description='Tick mark labels for angular axis';
p.FactoryValue = 'auto';

%angular axis tick direction
p = schema.prop(h,'AngleTickDir', 'AngleTickDirType'); %#ok
p.Description='Direction of angular axis tick marks (in, out, both)';
p.FactoryValue = 'both';

%visibility of angular axis tick labels
p = schema.prop(h,'AngleTickLabelsVisible', 'on/off'); %#ok
p.Description='Angular axis tick mark label visibility';
p.FactoryValue = 'on';

%angular tick labels offset
p = schema.prop(h,'AngleTickLabelsOffset', 'double'); %#ok
p.Description='Radial offset of angular axis axis tick mark labels';
p.FactoryValue=0.15;

%angular axis tick sign
p = schema.prop(h,'AngleTickSign', 'AngleTickSignType'); %#ok
p.Description='Signed or unsigned angular axis tick mark values';
p.FactoryValue = 'unsigned';

%angular axis grid line style
p = schema.prop(h,'AngleGridLineStyle', 'lineLineStyleType'); %#ok
p.Description='Angular grid line style';
p.FactoryValue = '-';

%angular axis grid color
p = schema.prop(h,'AngleGridColor', 'color'); %#ok
p.Description='Angular grid line color';
p.FactoryValue = [0.5 0.5 0.5];

%angular axis line width
p = schema.prop(h,'AngleGridLineWidth', 'double'); %#ok
p.Description='Angular grid line width';
p.FactoryValue = 1;

%visibility of angular axis grid
p = schema.prop(h,'AngleGridVisible', 'on/off'); %#ok
p.Description='Angular grid visibility';
p.FactoryValue = 'on';

%radial axis tick length
p = schema.prop(h,'RadialTickLength','NReals'); %#ok
p.Description='Radial axis tick mark length';
p.FactoryValue = 0.025;

%radial axis tick direction
p = schema.prop(h, 'RadialTickDir', 'RadialTickDirType'); %#ok
p.Description='Radial axis tick mark direction (+, - or both)';
p.FactoryValue = 'both';

%angular tick length
p = schema.prop(h, 'AngleTickLength', 'NReals'); %#ok
p.Description='Angular axis tick mark length';
p.FactoryValue = 0.025;

%polar axes style
p = schema.prop(h,'Style','PolarAxesStyleType'); %#ok
p.Description='Polar axes style (cartesian, compass)';
p.FactoryValue = 'cartesian';

%current point in polar coordinates
p = schema.prop(h,'CurrentPolarPoint','MATLAB array'); %#ok
p.Description='Mouse cursor polar coordinates';
p.FactoryValue = [NaN NaN];
p.AccessFlags.PublicSet = 'off';

%property to store listeners
p = schema.prop(h, 'PropertyListeners', 'handle vector'); %#ok
p.Description='Handles of propertiy listeners';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';


%create listeners for the properties that should set the dirty flag
l = Lappend(l,handle.listener(h,markDirtyProp,'PropertyPostSet',@LdoMarkDirtyAction));

%store listeners in the root object application data
setappdata(0,'PolarAxesListeners',l);


%-------SUBFUNCTIONS-------

function out = Lappend(in,data)
%LAPPEND help function
if isempty(in)
  out = data;
else
  out = [in data];
end


function LdoMarkDirtyAction(hSrc, eventData) %#ok
%LDOMARKDIRTYACTION set dirty flag
h = eventData.affectedObject;
h.Dirty = 'invalid';


function LdoDirtyAction(hSrc, eventData) %#ok
%LDODIRTYACTION trigger refres
h = eventData.affectedObject;
if strcmp(h.refreshmode,'auto')
  refresh(h);
end
