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

%define polarcursor class, use hggroup as baseclass
h = schema.class(pkg,'polarcursor',pkgHG.findclass('hggroup'));
h.Description = 'Polar range cursor';

%initialize variables
l = []; %will hold listeners
markDirtyProp = []; %will hold properties


%-------DEFINE PROPERTIES-------

%angle units property
p = schema.prop(h,'AngleUnits','AngleUnitsType'); %#ok
p.Description='Angular units used (radians or degrees)';
p.FactoryValue='radians';

%angle limits
p=schema.prop(h,'AngleLim','MATLAB array');
p.Description='Angular limits';
p.FactoryValue=[0 0.5*pi];
markDirtyProp = Lappend(markDirtyProp,p);

%radius limits
p=schema.prop(h,'RadialLim', 'MATLAB array');
p.Description='Radial limits';
p.FactoryValue=[-Inf Inf]; %will be clipped to axes radial limits
markDirtyProp = Lappend(markDirtyProp,p);

%cursor color property
p=schema.prop(h,'Color','lineColorType'); %#ok
p.Description='Cursor''s line color';
p.FactoryValue = [0 0 0];

%cursor line style property
p=schema.prop(h,'LineStyle','lineLineStyleType'); %#ok
p.Description='Cursor''s line style';
p.FactoryValue = '-';

%cursor line width property
p=schema.prop(h,'LineWidth','double'); %#ok
p.Description='Cursor''s line width';
p.FactoryValue = 2;

%cursor alpha property
p=schema.prop(h,'Alpha', 'double'); %#ok
p.Description='Cursor''s face alpha (transparency)';
p.FactoryValue=0.2;

%snap angle property
p=schema.prop(h, 'SnapAngle', 'double'); %#ok
p.Description='Snapping angle';
p.FactoryValue = 0;
markDirtyProp = Lappend(markDirtyProp,p);

%handles for graphical objects
p=schema.prop(h,'hHandles', 'handle vector'); %#ok
p.Description='Handles for cursor line and patch objects';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';

%property to store listeners
p = schema.prop(h, 'PropertyListeners', 'handle vector'); %#ok
p.Description='Handles for property listeners';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'on';
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
setappdata(0,'PolarCursorListeners',l);


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