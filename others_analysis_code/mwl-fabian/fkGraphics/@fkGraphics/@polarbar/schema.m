function schema
%SCHEMA class definition for polarbar
%
%  SCHEMA
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------DEFINE CLASS-------

%get fkGraphics package
pkg = findpackage('fkGraphics');
%get handle graphics package
pkgHG = findpackage('hg');

%define polarbar class, use hggroup as baseclass
h = schema.class(pkg,'polarbar',pkgHG.findclass('hggroup'));
h.Description = 'Polar bar plot';

%initialize variables
l = []; %will hold listeners
markDirtyProp = []; %will hold properties


%-------DEFINE PROPERTIES-------

%angle units property
p = schema.prop(h,'AngleUnits','AngleUnitsType'); %#ok
p.Description='Angular units used (radians or degrees)';
p.FactoryValue='radians';

%angle data property
p=schema.prop(h,'AngleData','MATLAB array');
p.Description='Angular data';
p.FactoryValue=(0.5+(0:11))*2*pi/12;
markDirtyProp = Lappend(markDirtyProp,p);

%radius data property
p=schema.prop(h,'RadiusData', 'MATLAB array');
p.Description='Radial data';
p.FactoryValue=0.5+0.25*sin(2*(0.5+(0:11))*2*pi/12);
markDirtyProp = Lappend(markDirtyProp,p);

%bar width data property
p=schema.prop(h,'WidthData', 'MATLAB array');
p.Description='Bar width data';
p.FactoryValue=[]; %determine automatically
markDirtyProp = Lappend(markDirtyProp,p);

%angle data clipping method property
p=schema.prop(h,'AngleClip', 'AngleClipType');
p.Description = 'Clipping mode for angles';
p.FactoryValue='nan';
markDirtyProp = Lappend(markDirtyProp,p);

%radius data clipping method property
p=schema.prop(h,'RadiusClip','RadiusClipType');
p.Description = 'Clipping mode for radii';
p.FactoryValue='clip';
markDirtyProp = Lappend(markDirtyProp,p);

%baseline property
p=schema.prop(h, 'Baseline', 'double' );
p.Description='Baseline value';
p.FactoryValue = -Inf;
markDirtyProp = Lappend(markDirtyProp,p);

%edge color property
p=schema.prop(h,'EdgeColor','lineColorType'); %#ok
p.Description='Bar edge color';
p.FactoryValue = [0 0 0];

%bar face color property
p=schema.prop(h,'FaceColor','lineColorType'); %#ok
p.Description='Bar face color';
p.FactoryValue = [0 0 0];

%edge line style property
p=schema.prop(h,'LineStyle','lineLineStyleType'); %#o
p.Description='Bar edge style';
p.FactoryValue = '-';

%edge line width property
p=schema.prop(h,'LineWidth','double'); %#ok
p.Description='Bar edge width';
p.FactoryValue = 1;

%bar alpha (transparency) property
p=schema.prop(h,'Alpha', 'double'); %#ok
p.Description='Bar face alpha (transparency)';
p.FactoryValue=0.2;

%property to handles of line and patch objects
p=schema.prop(h,'hHandles', 'handle vector'); %#ok
p.Description='Handles of line and patch objects';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';

%property to store listeners
p = schema.prop(h, 'PropertyListeners', 'handle vector'); %#ok
p.Description='Handles of property listeners';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';

%initialization flag property
p = schema.prop(h, 'Initialized', 'double'); %#ok
p.Description='Initialization flag';
p.FactoryValue = 0;
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

%dirty flag property
p = schema.prop(h, 'Dirty', 'DirtyEnum');
p.Description='Whether polar area needs refresh';
p.FactoryValue = 'invalid';
p.Visible = 'off';
 
%refresh mode property
p2 = schema.prop(h, 'RefreshMode', 'axesXLimModeType');
p2.Description='Auto/manual refresh mode';
p2.FactoryValue = 'manual';
p2.Visible = 'off';

%create listeners for triggering a refresh
%always put dirty listener first in list
l = Lappend(l,handle.listener(h, [p p2], 'PropertyPostSet', @LdoDirtyAction));

%create listeners for the properties that should set the dirty flag
l = Lappend(l,handle.listener(h,markDirtyProp,'PropertyPostSet',@LdoMarkDirtyAction));

%store listeners in the root object application data
setappdata(0,'PolarBarListeners',l);


%-------SUBFUNCTIONS-------

function out = Lappend(in,data)
%LAPPEND helper function
if isempty(in)
  out = data;
else
  out = [in data];
end


function LdoMarkDirtyAction(hSrc, eventData) %#ok
%LDOMARKDIRTYACTION set dirty flag
h = eventData.affectedObject;
if h.initialized
  h.dirty = 'invalid';
end

 
function LdoDirtyAction(hSrc, eventData) %#ok
%LDODIRTYACTION trigger refresh
h = eventData.affectedObject;
if h.initialized && strcmp(h.refreshmode,'auto')
  refresh(h);
end
