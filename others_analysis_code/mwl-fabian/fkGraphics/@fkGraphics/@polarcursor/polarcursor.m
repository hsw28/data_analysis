function h=polarcursor(varargin)
%POLARCURSOR polar cursor constructor
%
%  h=POLARCURSOR(param1,var1,...) constructs a polar cursor object with
%  properties set by the parameter/value pairs. Valid parameters are:
%   Parent - handle of parent axes (normal or polar axes)
%   AngleUnits - units for angular data ('radians' or 'degrees')
%   AngleLim - angle limits (default=[0 0.5*pi])
%   RadialLim - radial limits (default=[-Inf Inf])
%   Color - color of cursor (default=[0 0 0])
%   LineStyle - line style of cursor (default='-')
%   LineWidth - line width of cursor (default=2)
%   Alpha - alpha value for cursor (default=0.2)
%   SnapAngle - snap angle (default=0, no snapping)
%

%  Copyright 2008-2008 Fabian Kloosterman


%-------CONSTRUCTION-------

%find polar area parameters in arguments
p = {'AngleLim', 'RadiusLim', 'Color', 'LineStyle', 'LineWidth', ...
     'Alpha','AngleUnits', 'SnapAngle'};

ind = find( ismember( lower(varargin(1:2:end)), lower(p) ) );
ind = [2*ind-1;2*ind];
args = varargin(ind(:));

%find parent parameter if any
parent_ind = find( strncmpi( varargin(1:2:end), 'parent',6 ) );
if ~isempty(parent_ind)
  parent = varargin{parent_ind*2};
else
  parent = gca;
end

%find remaining arguments and pass on to constructor
ind = setdiff(1:nargin,ind(:));
h=fkGraphics.polarcursor(varargin{ind}, 'Parent', double(parent));


%-------INITIALIZATION-------

%set remaining arguments
if ~isempty(args)
  set(h,args{:});
end

%create cursor
hL(1) = line(NaN,NaN,'Parent',double(h),'Color',h.Color,'LineStyle', ...
            h.LineStyle,'LineWidth',h.LineWidth);
hL(2) = line(NaN,NaN,'Parent',double(h),'Color',h.Color,'LineStyle', ...
            h.LineStyle,'LineWidth',h.LineWidth);
hL(3) = patch(NaN,NaN,h.Color,'Parent',double(h),'LineStyle', 'none', ...
             'FaceAlpha', h.Alpha);

%set buttondown callbacks
set(hL(1),'ButtonDownFcn', {@startDrag,h,1});
set(hL(2),'ButtonDownFcn', {@startDrag,h,2});

%store the handles
h.hHandles = hL;

%we're done initializing
h.Initialized=1;


%-------LISTENERS-------

%create listener for when the cursor properties change
p = [h.findprop('Color') h.findprop('LineStyle') ...
     h.findprop('LineWidth') h.findprop('Alpha') ];
l = handle.listener(h, p,'PropertyPostSet', @changedCursorProps);


%-------SETTERS/GETTERS-------

%define set/get function angle data
p = [h.findprop('AngleLim') h.findprop('SnapAngle')];
set(p, 'GetFunction', @fkGraphics.getAngleData);
set(p, 'SetFunction', @fkGraphics.setAngleData);


%-------FINALIZE-------

%store listeners
h.PropertyListeners = l;

%set refreshmode to auto, which forces a refresh
h.RefreshMode = 'auto';


%-------LISTENER CALLBACK FUNCTIONS-------


function changedCursorProps(hProp,eventdata) %#ok
%CHANGEDCURSORPROPS set cursor properties
h=eventdata.affectedObject;
set(h.hHandles(1), 'Color', h.Color, 'LineStyle', h.LineStyle, 'LineWidth', h.LineWidth);
set(h.hHandles(2), 'Color', h.Color, 'LineStyle', h.LineStyle, 'LineWidth', h.LineWidth);
set(h.hHandles(3), 'FaceColor', h.Color, 'FaceAlpha', h.Alpha, 'HitTest','off');


function startDrag(hObj,eventdata, hCursor, c) %#ok
%STARTDRAG initiate cursor dragging
hFig = ancestor(hObj,'figure');
set(hFig,'WindowButtonUpFcn', @stopDrag);
set(hFig,'WindowButtonMotionFcn', {@doDrag, hCursor, c});


function stopDrag(hFig,eventdata) %#ok
%STOPDRAG finalize dragging
set(hFig,'WindowButtonUpFcn', '');
set(hFig,'WindowButtonMotionFcn', '');


function doDrag(hFig,eventdata, h, c) %#ok
%DODRAG update cursor while dragging
hAx = ancestor(h, 'axes');

%get old cursor limits and snap angle in radians
old_lim = fkGraphics.getradians(h, 'AngleLim');
snapangle = fkGraphics.getradians(h,'SnapAngle');

%get current point in cartesian coordinates
new_point = get( hAx, 'CurrentPoint');

%set new angle
%old_lim(c) = cart2pol(new_point(1,1), new_point(1,2));


if isa( handle(hAx), 'fkGraphics.polaraxes') %polaraxes
  
  hAx = handle(hAx);
  
  %get axes angle limits in radians
  anglelim = fkGraphics.getradians(hAx, 'AngleLim');
  
  %define valid angle range
  tlim = [0 2*pi];
  if abs(mod(diff(anglelim),2*pi))==0
    %pass
  elseif c==1
    tlim = [anglelim(1) old_lim(2)];
  else
    tlim = [old_lim(1) anglelim(2)];
  end
  
  %compute new angle
  theta = limit2pi( cart2pol( new_point(1,1), new_point(1,2) ) );
  
  %apply snapping
  if snapangle~=0
    theta=round(theta./snapangle).*snapangle;
  end
  
  %clip angle to valid range
  theta = clip_angle(hAx,theta,'clip',tlim);
  
else
  
  %compute new angle
  theta = limit2pi( atan2( new_point(1,1), new_point(1,2) ) );
  
  %apply snapping
  if snapangle~=0
    theta=round(theta./snapangle).*snapangle;
  end  
  
end

%set new theta
old_lim(c) = theta;
fkGraphics.setradians(h, 'AngleLim', old_lim);

