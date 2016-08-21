function schema
%SCHEMA class definition for rangecursor
%
%  SCHEMA
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------DEFINE CLASS-------

%get fkGraphics package
pkg = findpackage('fkGraphics');
%get handle graphics package
pkgHG = findpackage('hg');

%define rangecursor class, use hggroup as baseclass
h = schema.class(pkg,'rangecursor',pkgHG.findclass('hggroup'));
h.Description = 'Range cursor';


%-------PUBLIC PROPERTIES-------

%X limits
p=schema.prop(h,'XLim','MATLAB array'); %#ok
p.Description='X range of cursor';
p.FactoryValue=[0.25 0.75];

%Y limits
p=schema.prop(h,'YLim','MATLAB array'); %#ok
p.Description='Y range of cursor';
p.FactoryValue=[0.25 0.75];

%cursor style
p=schema.prop(h,'Style','CursorStyleType'); %#ok
p.Description='Cursor style (vertical, horizontal or cross)';
p.FactoryValue='cross';

%cursor color
p=schema.prop(h,'Color','lineColorType'); %#ok
p.Description='Cursor''s line color';
p.FactoryValue = [0 0 0];

%cursor line style
p=schema.prop(h,'LineStyle','lineLineStyleType'); %#ok
p.Description='Cursor''s line style';
p.FactoryValue = '-';

%cursor line width
p=schema.prop(h,'LineWidth','double'); %#ok
p.Description='Cursor''s line width';
p.FactoryValue = 2;

%snap x property
p=schema.prop(h,'SnapX','double'); %#ok
p.Description='Snap value for x coordinate';
p.FactoryValue=0;

%snap y property
p=schema.prop(h,'SnapY','double'); %#ok
p.Description='Snap value for y coordinate';
p.FactoryValue=0;

%cursor can move horizontally
p=schema.prop(h, 'MoveX', 'bool'); %#ok
p.Description='Whether cursor can be moved in x dimension';
p.FactoryValue = true;

%cursor can move vertically
p=schema.prop(h, 'MoveY', 'bool'); %#ok
p.Description='Whether cursor can be moved in y dimension';
p.FactoryValue = true;

%transparency
p=schema.prop(h,'Alpha','double'); %#ok
p.Description='Cursor'' face alpha (transparency)';
p.FactoryValue=0.2;

%cursor size  (scalar or 2 element vector)
p=schema.prop(h,'Size','MATLAB array'); %#ok
p.Description='Length of cursor lines in x and y dimensions';
p.FactoryValue=Inf;

%ruler
p=schema.prop(h,'ShowRuler', 'bool'); %#ok
p.Description='Show ruler while dragging cursor';
p.FactoryValue=false;

%ruler color
p=schema.prop(h,'RulerColor','lineColorType'); %#ok
p.Description='Ruler''s line color';
p.FactoryValue = [1 0 0];

%ruler line style property
p=schema.prop(h,'RulerLineStyle','lineLineStyleType'); %#ok
p.Description='Ruler''s line style';
p.FactoryValue = '- -';

%ruler line width property
p=schema.prop(h,'RulerLineWidth','double'); %#ok
p.Description='Ruler''s line width';
p.FactoryValue = 1;

%text offset
p=schema.prop(h,'TextOffset', 'MATLAB array'); %#ok
p.Description='X and y pixel offset for custom text';
p.FactoryValue=[0 0];

%text position x
p=schema.prop(h,'TextPosX', 'TextPosXType'); %#ok
p.Description='X position of custom text';
p.FactoryValue='C';

%text position y
p=schema.prop(h,'TextPosY', 'TextPosYType'); %#ok
p.Description='Y position of custom text';
p.FactoryValue='C';

%label position (axes, cursor, center)
p=schema.prop(h,'LabelPos','LabelPosType'); %#ok
p.Description='position of info labels';
p.FactoryValue='center';

%label offset
%p=schema.prop(h,'LabelOffset', 'double'); %#ok
%p.FactoryValue=0;

%label show mode
p=schema.prop(h,'LabelShowMode', 'LabelShowModeType'); %#ok
p.Description='When to show info label (show, hide, drag, nodrag)';
p.FactoryValue='show';



%-------DUMMY PROPERTIES-------

p = schema.prop(h,'Text', 'handle'); %#ok
p.Description='Handle of custom text object';
p.AccessFlags.PublicSet='off';
p = schema.prop(h,'Label', 'handle vector'); %#ok
p.Description='Handle of info label object';
p.AccessFlags.PublicSet='off';

p = schema.prop(h, 'X', 'double'); %#ok
p.Description='X center of cursor range';
p = schema.prop(h, 'Y', 'double'); %#ok
p.Description='Y center of cursor range';

%-------HIDDEN PROPERTIES-------

%dragging flag
p=schema.prop(h, 'isDragging', 'bool'); %#ok
p.Description='True when in dragging operation';
p.FactoryValue = false;
p.Visible='off';

%dragging start position
p=schema.prop(h, 'DragStartX', 'double'); %#ok
p.Description='Starting x coordinate of dragging operation';
p.Visible='off';
p=schema.prop(h, 'DragStartY', 'double'); %#ok
p.Description='Starting y coordinate of dragging operation';
p.Visible='off';

%dragging index
p=schema.prop(h, 'DragIndex', 'double'); %#ok
p.Description='Index of object being dragged';
p.Visible='off';

%graphical handles
p=schema.prop(h,'hHandles', 'handle vector'); %#ok
p.Description='Handles of line and patch objects';
p.AccessFlags.Serialize = 'off';
p.Visible='off';

%property to store listeners
p = schema.prop(h, 'PropertyListeners', 'handle vector'); %#ok
p.Description='Handles of property listeners';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';


%-------EVENTS-------

%create a CursorChanged event which is sent whenever the position of the
%cursor changes
p = schema.event(h,'CursorChanged'); %#ok
p.EventDataDescription='Position changed event';


