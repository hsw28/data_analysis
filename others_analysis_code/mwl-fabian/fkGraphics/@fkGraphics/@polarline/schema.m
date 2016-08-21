function schema
%SCHEMA class definition for polarline
%
%  SCHEMA
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------DEFINE CLASS-------

%get fkGraphics package
pkg = findpackage('fkGraphics');
%get handle graphics package
pkgHG = findpackage('hg');

%define polarline class, use hggroup as baseclass
h = schema.class(pkg,'polarline',pkgHG.findclass('hggroup'));
h.Description = 'Polar line plot';

%initialize variables
l = []; %will hold listeners
markDirtyProp = []; %will hold properties


%-------DEFINE PROPERTIES-------

%angle units property
p = schema.prop(h,'AngleUnits','AngleUnitsType'); %#ok
p.Description='Angular units used (radians or degrees)';
p.FactoryValue='radians';

%angle data property
theta = (0:23)*2*pi/24;
p=schema.prop(h,'AngleData','MATLAB array');
p.Description='Angular data';
p.FactoryValue=theta;
markDirtyProp = Lappend(markDirtyProp,p);

%radius data property
kappa = 2;
mu = 0.75*pi;
p=schema.prop(h,'RadiusData', 'MATLAB array');
p.Description='Radial data';
p.FactoryValue=exp(kappa.*cos(theta-mu))./(2*pi*besseli(0,kappa));
markDirtyProp = Lappend(markDirtyProp,p);

%angle data clipping method property
p=schema.prop(h,'AngleClip', 'AngleClipType');
p.Description = 'Clipping mode for angles';
p.FactoryValue='nan';
markDirtyProp = Lappend(markDirtyProp,p);

%radius data clipping method property
p=schema.prop(h,'RadiusClip','RadiusClipType');
p.Description = 'Clipping mode for radii';
p.FactoryValue='nan';
markDirtyProp = Lappend(markDirtyProp,p);

%line color property
p=schema.prop(h,'Color','lineColorType'); %#ok
p.Description = 'Line color';
p.FactoryValue = [0 0 0];

%line style property
p=schema.prop(h,'LineStyle','patchLineStyleType'); %#ok
p.Description = 'Line style';
p.FactoryValue = '-';

%line width property
p=schema.prop(h,'LineWidth','double'); %#ok
p.Description = 'Linewidth';
p.FactoryValue = 1;

%marker type property
p=schema.prop(h,'Marker','lineMarkerType'); %#ok
p.Description = 'Marker style';
p.FactoryValue='none';

%marker size property
p=schema.prop(h,'MarkerSize','lineMarkerSizeType'); %#ok
p.Description = 'Marker size';
p.FactoryValue=6;

%marker edge color property
p=schema.prop(h,'MarkerEdgeColor','lineMarkerEdgeColorType'); %#ok
p.Description = 'Marker edge color';
p.FactoryValue='auto';

%marker face color property
p=schema.prop(h,'MarkerFaceColor','lineMarkerFaceColorType'); %#ok
p.Description = 'Marker face color';
p.FactoryValue='none';

%auto closing of area
p=schema.prop(h,'AutoClose','on/off'); %#ok
p.Description='Assume dataset spans full circle'; 
p.FactoryValue='on';
markDirtyProp = Lappend(markDirtyProp,p);

%handle of line object
p=schema.prop(h,'hLine', 'handle vector'); %#ok
p.Description='Handle of line object';
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

%dirty flag property
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
setappdata(0,'PolarLineListeners',l);


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
