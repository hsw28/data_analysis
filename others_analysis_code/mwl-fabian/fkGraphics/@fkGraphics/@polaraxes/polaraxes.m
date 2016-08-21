function h=polaraxes(varargin)
%POLARAXES polar axes constructor
%
%  h=POLARAXES(param1,val1,...) constructs a polar axes object with
%  properties set by the parameter/value pairs. Valid parameters are:
%   AngleUnits - radians/degrees, determines how angle values of
%                properties during set/get operations should be
%                interpreted
%   AngleLim - angle axis limits (default=[0 2*pi])
%   RadialLim - radial axis limits (default=[0 1])
%   AxesRotation - rotation of axes (default=0)
%   RadialDir - direction of radial axis (default='normal')
%   AngleDir - direction of angular axis (default='ccw')
%   FontColor - font color (default=[0 0 0])
%   FontAngle - font angle (default='normal')
%   FontName - font name (default='helvetica')
%   FontUnits - font units (default='points')
%   FontSize - font size (default=10)
%   FontWeight - font weight (default='normal')
%   RadialAxisRotation - rotation of radial axis (default=5*pi/12)
%   RadialAxisLineStyle - line style of radial axis (default='-')
%   RadialAxisColor - radial axis color (default=[0 0 0]);
%   RadialAxisLineWidth - radial axis line width (default=1)
%   RadialAxisVisible - show/hide radial axis (default='on')
%   RadialTickUnits - units of radial ticks (default='')
%   RadialTickValues - radial tick values (default='auto')
%   RadialTickLength - length of tick marks (0-1) (default=0.025)
%   RadialTickDir - radial tick direction ('+','-','both') (default='both')
%   RadialTickLabels - labels for radial ticks (default='auto')
%   RadialTickLabelsVisible - show/hide radial tick labels (default='on')
%   RadialTickLabelsOffset - normalized offset of radial tick labels
%                            (default=[0 0.03])
%   RadialTickLabelsAngle - rotation of radial tick labels
%                           (default='auto')
%   RadialGridLineStyle - line style of radial grid (default=':')
%   RadialGridColor - radial grid color (default=[0.5 0.5 0.5])
%   RadialGridLineWidth - radial grid line width (default=1)
%   RadialGridVisible - show/hide radial grid (default='on')
%   AngleAxisLineStyle - line style of angular axis (default='-')
%   AngleAxisColor - angular axis color (default=[0 0 0])
%   AngleAxisLineWidth - line width of angular axis (default=1)
%   AngleAxisVisible - show/hide angular axis (default='on')
%   AngleTickUnits - units of angular ticks (default='radians')
%   AngleTickValues - angular tick values (default='auto')
%   AngleTickLabels - angular tick labels (default='auto')
%   AngleTickLength - normalized angular tick length (default = 0.025)
%   AngleTickDir - angular tick direction (default='both')
%   AngleTickLabelsVisible - show/hide angular tick labels (default='on')
%   AngleTickLabelsOffset - normalized offset of angular tick labels
%                           (default=0.1)
%   AngleTickSign - signed/unsigned angular values (default='unsigned')
%   AngleGridLineStyle - angular grid line style (default='-')
%   AngleGridColor - angular grid color (default=[0.5 0.5 0.5])
%   AngleGridLineWidth - angular grid line width (default=1)
%   AngleGridVisible - show/hide angular grid (default='on')
%   Style - set polar axes style, this a convenience property that sets
%           AngleDir and AxesRotation properties to match a
%           'compass'/'watch' style or a 'cartesian' style
%           (default='cartesian')
%  Polar axes have an additional read-only property CurrentPolarPoint,
%  which contains the current point in polar coordinates.
%


%  Copyright 2008-2008 Fabian Kloosterman

%-------CONSTRUCTION-------

%find polar axes parameters in arguments
p = {'AngleUnits', 'AngleLim', 'RadialLim', 'AxesRotation', 'RadialDir', ...
     'AngleDir' 'FontColor', 'FontAngle', 'FontName', 'FontUnits', ...
     'FontSize', 'FontWeight', 'RadialAxisRotation', 'RadialAxisLineStyle', ...
     'RadialAxisColor','RadialAxisLineWidth', 'RadialAxisVisible', ...
     'RadialTickUnits', 'RadialTickValues', 'RadialTickLength', ...
     'RadialTickDir', 'RadialTickLabels', 'RadialTickLabelsVisible', ...
     'RadialTickLabelsOffset', 'RadialTickLabelsAngle', 'RadialGridLineStyle', ...
     'RadialGridColor', 'RadialGridLineWidth', 'RadialGridVisible', ...
     'AngleAxisLineStyle', 'AngleAxisColor', 'AngleAxisLineWidth', ...
     'AngleAxisVisible', 'AngleTickUnits', 'AngleTickValues', 'AngleTickLabels', ...
     'AngleTickLength', 'AngleTickDir', 'AngleTickLabelsVisible', ...
     'AngleTickLabelsOffset', 'AngleTickSign', 'AngleGridLineStyle', ...
     'AngleGridColor', 'AngleGridLineWidth', 'AngleGridVisible', 'Style'};

ind = find( ismember( lower(varargin(1:2:end)), lower(p) ) );
ind = [2*ind-1;2*ind];
args = varargin(ind(:));

%find remaining arguments and pass on to constructor
ind = setdiff(1:nargin,ind(:));

h=fkGraphics.polaraxes(varargin{ind});


%-------INITIALIZATION-------

%create layers for graphical objects
h.BackgroundLayer = hggroup('HandleVisibility', 'off', 'Serializable', 'off','Parent',double(h));
h.AngleAxisLayer = hggroup('HandleVisibility', 'off', 'Serializable', 'off','Parent',double(h));
h.RadialAxisLayer = hggroup('HandleVisibility', 'off', 'Serializable', 'off','Parent',double(h));

%setup axes
set(h, 'DataAspectRatio', [1 1 1], ...
       'PlotBoxAspectRatioMode', 'auto', ...
       'CameraViewAngle', 13.2, ... %always in degrees
       'XLim', [-1.1 1.1], 'YLim', [-1.1 1.1]);
axis(h,'off');

%no zoom/pan behavior for axes
b=hggetbehavior(double(h),'zoom');
set(b, 'Enable', false);
b=hggetbehavior(double(h),'pan');
set(b, 'Enable', false);
%no editing behavior for angle/radius axes
b=hggetbehavior(double(h.AngleAxisLayer), 'plotedit');
set(b, 'Enable', false);
b=hggetbehavior(double(h.RadialAxisLayer), 'plotedit');
set(b, 'Enable', false);

%force view update
changedView([],struct('affectedObject',h));

%-------LISTNENERS-------

%create listener for when background color changed
l = handle.listener(h,h.findprop('Color'),'PropertyPostSet',@changedColor);

%create listener for when view changed
p = [h.findprop('AxesRotation') h.findprop('AngleDir')];
l(end+1) = handle.listener(h,p,'PropertyPostSet',@changedView);

%create listener for when font properties changed
p = [h.findprop('FontColor') h.findprop('FontAngle')
     h.findprop('FontName')  h.findprop('FontSize')
     h.findprop('FontUnits') h.findprop('FontWeight')];
l(end+1) = handle.listener(h,p,'PropertyPostSet',@changedFont);

%create listener for when radial grid properties changed
p = [h.findprop('RadialGridLineStyle') h.findprop('RadialGridColor')
     h.findprop('RadialGridLineWidth') h.findprop('RadialGridVisible')];
l(end+1) = handle.listener(h,p,'PropertyPostSet',@changedRadialGrid);

%create listener for when angular grid properties changed
p = [h.findprop('AngleGridLineStyle') h.findprop('AngleGridColor')
     h.findprop('AngleGridLineWidth') h.findprop('AngleGridVisible')];
l(end+1) = handle.listener(h,p,'PropertyPostSet',@changedAngleGrid);

%create listeners for tick label visibility
l(end+1) = handle.listener(h,findprop(h,'AngleTickLabelsVisible'),...
                           'PropertyPostSet', @changedAngleTickLabelsVisible);
l(end+1) = handle.listener(h,findprop(h,'RadialTickLabelsVisible'),...
                           'PropertyPostSet', @changedRadialTickLabelsVisible);

%create listener for radial axis properties
p = [h.findprop('RadialAxisLineStyle') h.findprop('RadialAxisColor')
     h.findprop('RadialAxisLineWidth') h.findprop('RadialAxisVisible')];
l(end+1) = handle.listener(h,p,'PropertyPostSet',@changedRadialAxis);

%create listener for angular axis properties
p = [h.findprop('AngleAxisLineStyle') h.findprop('AngleAxisColor')
     h.findprop('AngleAxisLineWidth') h.findprop('AngleAxisVisible')];
l(end+1) = handle.listener(h,p,'PropertyPostSet',@changedAngleAxis);

%create listener for changed properties that require a redraw of the
%angular axis
p = [h.findprop('AngleLim') h.findprop('AngleTickUnits') ...
     h.findprop('AngleTickValues') h.findprop('AngleTickLabels') ...
     h.findprop('AngleTickDir') h.findprop('AngleTickSign') ...
     h.findprop('AngleTickLength') h.findprop('AngleTickLabelsOffset')];
l(end+1) = handle.listener(h,p,'PropertyPostSet',@redrawAngleAxis);

%create listener for changed properties that require a redraw of the
%radial axis
p = [h.findprop('AngleLim') h.findprop('RadialLim') ...
     h.findprop('RadialDir') h.findprop('RadialAxisRotation') ...
     h.findprop('RadialTickUnits') h.findprop('RadialTickValues') ...
     h.findprop('RadialTickLabels') h.findprop('RadialTickLabelsOffset') ...
     h.findprop('RadialTickLabelsAngle') h.findprop('AxesRotation') ...
     h.findprop('AngleDir') h.findprop('RadialTickDir') ...
     h.findprop('RadialTickLength')];
l(end+1) = handle.listener(h,p,'PropertyPostSet',@redrawRadialAxis);

%define listeners for changing stacking order
p = [h.findprop('Layer')]; %#ok
l(end+1) = handle.listener(h,p,'PropertyPostSet', {@changeZOrder,h});
l(end+1) = handle.listener(h,'ObjectChildAdded', {@changeZOrder,h});

%if behavior property is being reset that means a 'cla reset' has been
%executed and we should reset to a proper polar axes. This was the best
%property I could find for this trick. 
p = h.findprop('Behavior');
l(end+1) = handle.listener(h,p,'PropertyPostSet', @resetAxes);

%if the user deleted the background layer, than we kill the axes
%note that both angleaxis and radialaxis groups do not support plotedit
%behavior and so shouldn't be deleted by user
l(end+1) = handle.listener(h.BackgroundLayer,'ObjectBeingDestroyed', @killAxes);


%-------GETTERS/SETTERS-------

%define get function for current polar point property
p = h.findprop('CurrentPolarPoint'); %#ok
p.GetFunction = @updateCurrentPoint;

%define get/set function for angular properties
p = [h.findprop('AxesRotation') ...
     h.findprop('RadialAxisRotation') h.findprop('RadialTickLabelsAngle') ...
     h.findprop('AngleTickValues')];
set(p, 'GetFunction', @fkGraphics.getAngleData);
set(p, 'SetFunction', @fkGraphics.setAngleData);

%define set/get function angular limits
p = h.findprop('AngleLim');
set(p, 'GetFunction', @fkGraphics.getAngleData);
set(p, 'SetFunction', @setAngleLim);

%define set function for radial limits
p = h.findprop('RadialLim');
set(p, 'SetFunction', @setRadialLim);

%define set/get function for polar axes style
p = h.findprop('Style');
set(p,'GetFunction', @getStyle);
set(p,'SetFunction', @setStyle);


%-------FINALIZE------

%save listeners
h.PropertyListeners = l;

%draw axes
draw_angle_axis(h)
draw_radial_axis(h)

%process parameter/value arguments
if ~isempty(args)
  set(h,args{:});
end




%-------LISTENER CALLBACK FUNCTIONS-------

function killAxes(hObj,eventdata) %#ok
delete(hObj.Parent);


function resetAxes(hProp,eventdata) %#ok
h = eventdata.affectedObject;
if isstruct( h.Behavior ) && isempty(fieldnames(h.Behavior))
  reset(handle(h));
end


function changeZOrder(hProp,eventdata,h) %#ok
%change stacking order
%disable listeners
set(h.PropertyListeners,'Enabled','off');
%show hidden handles
set(0,'ShowHiddenHandles','on');
%find axes handles and other children
child = h.Children;
angleax_idx = find( child==h.AngleAxisLayer );
radialax_idx = find( child == h.RadialAxisLayer );
bgax_idx = find( child == h.BackgroundLayer );
other_idx = setdiff( 1:numel(child), [angleax_idx radialax_idx bgax_idx] );
%change stacking order
if strcmp(h.Layer, 'top')
  set(h,'Children', child([radialax_idx;angleax_idx;other_idx(:);bgax_idx]));
else
  set(h,'Children', child([other_idx(:);radialax_idx;angleax_idx;bgax_idx]));
end
%hiden hidden handles
set(0,'ShowHiddenHandles','off');
%enable listeners
set(h.PropertyListeners,'Enabled','on');


function val=setStyle(h,val)
switch val
 case 'cartesian'
  h.AngleDir='ccw';
  h.AxesRotation=0;
 case 'compass'
  h.AngleDir='cw';
  fkGraphics.setdegrees(h, 'AxesRotation', -90);
 otherwise
end


function val=getStyle(h,val) %#ok
%get axes rotation in degrees
axrot = fkGraphics.getdegrees(h, 'AxesRotation');

if strcmp(h.AngleDir,'ccw') && abs(axrot)<eps
  val = 'cartesian';
elseif strcmp(h.AngleDir, 'cw') && abs(mod(axrot+90,360))<eps
  val = 'compass';
else
  val = 'custom';
end


function val = setRadialLim(h,val) %#ok
if isempty(val)
  %catch empty value
  val = [0 1];
else
  %make sure radial limits are increasing
  val = sort( val([1 end]) );
  %and not equal
  if val(1)==val(2)
    val(2) = val(1) + 0.001;
    %error('polaraxes:set:invalidRadialLim', 'Invalid radial limits');
  end
end


function val = setAngleLim(h,val)
if isempty(val)
  %catch empty value
  val = [0 2*pi];
else
  if strcmp(h.AngleUnits,'degrees')
    %convert to radians
    val = val*pi/180;
  end
  %make sure 0<=val<2*pi
  val = mod( mod(val([1 end]), 2*pi) + 2*pi, 2*pi );
  if val(1)>=val(2)
    %make sure values are in order
    val(2)=val(2)+2*pi;
  end
end


function val = updateCurrentPoint(h, val) %#ok
%get angle and radius of current point
[theta, rho] = cart2pol(h.CurrentPoint(1,1), h.CurrentPoint(1,2));

%convert normalized radius to real radius
if strcmp(h.RadialDir,'reverse')
  val = [theta interp1([0 1], h.RadialLim([end 1]), rho, 'linear','extrap')];
else
  val = [theta interp1([0 1], h.RadialLim, rho, 'linear','extrap')];
end

if strcmp(h.AngleUnits,'degrees')
  %convert angle to degrees
  val(1) = val(1)*180/pi;
end


function redrawAngleAxis(hProp,eventdata) %#ok
h = eventdata.affectedObject;
%delete objects
delete(get(h.BackgroundLayer,'Children'));
delete(get(h.AngleAxisLayer,'Children'));
%and redraw angular axis
draw_angle_axis(h);


function redrawRadialAxis(hProp, eventdata) %#ok
h = eventdata.affectedObject;
%delete objects
delete(get(h.RadialAxisLayer,'Children'));
%and redraw radial axis
draw_radial_axis(h);


function changedAngleAxis(hProp,eventdata) %#ok
h=eventdata.AffectedObject;
%set angular axis properties
set(h.AngleAxisHandle, 'LineStyle', h.AngleAxisLineStyle,...
                  'LineWidth', h.AngleAxisLineWidth, ...
                  'Color', h.AngleAxisColor, ...
                  'Visible', h.AngleAxisVisible);
set(h.AngleTicksHandle, 'LineStyle', h.AngleAxisLineStyle,...
                  'LineWidth', h.AngleAxisLineWidth, ...
                  'Color', h.AngleAxisColor, ...
                  'Visible', h.AngleAxisVisible);


function changedRadialAxis(hProp,eventdata) %#ok
h=eventdata.AffectedObject;
%set radial axis properties
set(h.RadialAxisHandle, 'LineStyle', h.RadialAxisLineStyle,...
                  'LineWidth', h.RadialAxisLineWidth, ...
                  'Color', h.RadialAxisColor, ...
                  'Visible', h.RadialAxisVisible);
set(h.RadialTicksHandle, 'LineStyle', h.RadialAxisLineStyle,...
                  'LineWidth', h.RadialAxisLineWidth, ...
                  'Color', h.RadialAxisColor, ...
                  'Visible', h.RadialAxisVisible);


function changedRadialTickLabelsVisible(hProp,eventdata) %#ok
h=eventdata.affectedObject;
set(h.RadialLabelsHandle,'Visible',h.RadialTickLabelsVisible);


function changedAngleTickLabelsVisible(hProp,eventdata) %#ok
h=eventdata.affectedObject;
set(h.AngleLabelsHandle,'Visible',h.AngleTickLabelsVisible);


function changedAngleGrid(hProp,eventdata) %#ok
h=eventdata.AffectedObject;
%set angular grid properties
set(h.AngleGridHandle, 'LineStyle', h.AngleGridLineStyle,...
                  'LineWidth', h.AngleGridLineWidth, ...
                  'Color', h.AngleGridColor, ...
                  'Visible', h.AngleGridVisible);


function changedRadialGrid(hProp,eventdata) %#ok
h=eventdata.AffectedObject;
%set radial grid properties
set(h.RadialGridHandle, 'LineStyle', h.RadialGridLineStyle,...
                  'LineWidth', h.RadialGridLineWidth, ...
                  'Color', h.RadialGridColor, ...
                  'Visible', h.RadialGridVisible);


function changedFont(hProp,eventdata) %#ok
h=eventdata.affectedObject;
%set font properties
set(h.AngleLabelsHandle,'Color',h.FontColor, ...
                  'FontAngle', h.FontAngle, ...
                  'FontName', h.FontName, ...
                  'FontUnits', h.FontUnits, ...
                  'FontSize', h.FontSize, ...
                  'FontWeight', h.FontWeight);
set(h.RadialLabelsHandle,'Color',h.FontColor, ...
                  'FontAngle', h.FontAngle, ...
                  'FontName', h.FontName, ...
                  'FontUnits', h.FontUnits, ...
                  'FontSize', h.FontSize, ...
                  'FontWeight', h.FontWeight);


function changedColor(hProp,eventdata) %#ok
h=eventdata.affectedObject;
set(h.BackgroundHandle, 'FaceColor', h.Color);


function changedView(hProp,eventdata) %#ok
h=eventdata.affectedObject;
%deal correctly with direction of angular axis
if strcmp(h.AngleDir, 'cw')
  direction=-1;
else
  direction=1;
end

axrot = fkGraphics.getradians(h, 'AxesRotation');
r = direction*axrot;

%set camera properties
set(h, 'CameraPosition', [0 0 10*direction], ...
       'CameraTarget', [0 0 0.5*direction], ...
       'CameraUpVector', [sin(r) direction*cos(r) 0]);

    