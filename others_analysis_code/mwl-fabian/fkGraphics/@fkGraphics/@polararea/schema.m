function schema
%SCHEMA class definition for polararea
%
%  SCHEMA
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------DEFINE CLASS-------

%get fkGrapichs package
pkg = findpackage('fkGraphics');
%get handle graphics package
pkgHG = findpackage('hg');

%define polararea class, use hggroup as baseclass
h = schema.class(pkg,'polararea',pkgHG.findclass('hggroup'));
h.Description = 'Polar area plot';

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
p.FactoryValue=(0:0.05:2)*pi;
markDirtyProp = Lappend(markDirtyProp,p);

%radius data property
p=schema.prop(h,'RadiusData', 'MATLAB array');
p.Description='Radial data';
p.FactoryValue=abs( sin( 2*(0:0.05:2)*pi ) );
markDirtyProp = Lappend(markDirtyProp,p);

%angle data clipping method property
p=schema.prop(h,'AngleClip', 'AngleClipType');
p.Description = 'Clipping mode for angles';
p.FactoryValue='clip';
markDirtyProp = Lappend(markDirtyProp,p);

%radius data clipping mode
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
p.Description='Area edge color';
p.FactoryValue = [0 0 0];

%area face color property
p=schema.prop(h,'FaceColor','patchFaceColorType'); %#ok
p.Description='Area face color';
p.FactoryValue = [0 0 0];

%edge line style property
p=schema.prop(h,'LineStyle','lineLineStyleType'); %#ok
p.Description='Area edge style';
p.FactoryValue = '-';

%edge line width property
p=schema.prop(h,'LineWidth','double'); %#ok
p.Description='Area edge width';
p.FactoryValue = 1;

%area alpha (transparency) property
p=schema.prop(h,'Alpha', 'double'); %#ok
p.Description='Area face alpha (transparency)';
p.FactoryValue=0.2;

%edge marker style property
p=schema.prop(h,'Marker','lineMarkerType'); %#ok
p.Description='Marker style';
p.FactoryValue='o';

%marker size property
p=schema.prop(h,'MarkerSize','double'); %#ok
p.Description='Marker size';
p.FactoryValue=6;

%marker edge color property
p=schema.prop(h,'MarkerEdgeColor','lineMarkerEdgeColorType'); %#ok
p.Description='Marker edge color';
p.FactoryValue=[0 0 0];

%marker face color property
p=schema.prop(h,'MarkerFaceColor','lineMarkerFaceColorType'); %#ok
p.Description='Marker face color';
p.FactoryValue='none';

%auto closing of area
p=schema.prop(h,'AutoClose','on/off'); %#ok
p.Description='Assume dataset spans full circle'; 
p.FactoryValue='on';
markDirtyProp = Lappend(markDirtyProp,p);

%handles of line and patch objects
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
setappdata(0,'PolarAreaListeners',l);


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
