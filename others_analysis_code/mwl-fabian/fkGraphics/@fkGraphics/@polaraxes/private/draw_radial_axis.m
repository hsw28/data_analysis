function draw_radial_axis(h)
%DRAW_RADIAL_AXIS draw the radial axis in polar axes
%
%  DRAW_RADIAL_AXIS(h) draws a radial axis in polar axes h.
%

%  Copyright 2008-2008 Fabian Kloosterman

%make sure all angular axes properties are in radians
anglelim = fkGraphics.getradians(h, 'AngleLim');
radialaxisrotation = fkGraphics.getradians(h, 'RadialAxisRotation');
radialticklabelsangle = fkGraphics.getradians(h, 'RadialTickLabelsAngle');
axesrotation = fkGraphics.getradians(h, 'AxesRotation');

%create angular subdivisions for radial grid
ndiv = 50; %number of divisions
if anglelim(1)>=anglelim(2)
    th = (anglelim(1):pi/ndiv:(anglelim(2)+2*pi))';
else
    th = (anglelim(1):pi/ndiv:anglelim(2))';
end

%convert to unit circle
xunit = cos(th);
yunit = sin(th);

%if automatic tick values, create fixed number of subdivisions that span
%the radial limits
ndiv = 6;
if ischar(h.RadialTickValues)
  tickvals = linspace(h.RadialLim(1), h.RadialLim(2), ndiv);
else
  tickvals = h.RadialTickValues;
end

%check tick values
ticks = check_radius( tickvals(:), h.RadialLim, h.RadialDir, 'nan');

%draw grid
h.RadialGridHandle = line(  xunit * ticks(:)', yunit * ticks(:)', 'Color', ...
                            h.RadialGridColor, 'LineStyle', ...
                            h.RadialGridLineStyle, 'LineWidth', ...
                            h.RadialGridLineWidth, 'Parent', h.RadialAxisLayer, ...
                            'HitTest', 'off', 'Visible', h.RadialGridVisible );

%check rotation angle of radial axis
th = check_angle(radialaxisrotation, anglelim, 'clip');

%draw rho axis
h.RadialAxisHandle = line( [0 1].*cos(th), [0 1].*sin(th), 'Color', ...
                           h.RadialAxisColor, 'LineStyle', h.RadialAxisLineStyle, ...
                           'LineWidth', h.RadialAxisLineWidth, 'Visible', ...
                           h.RadialAxisVisible, 'Parent', h.RadialAxisLayer, ...
                           'HitTest', 'off');

%do not draw tick mark in center
valid_ticks = ticks( ticks~=0 );

%compute tick half angles, maximum half angle is 0.5*pi
tickangle = asin( min(h.RadialTickLength./(2.*valid_ticks(:)'), 1) ); 

% create angular subdivisions for tick lines
ndiv=10;
switch h.RadialTickDir
 case '+'
  v=linspace(0,1,ndiv)';
 case '-'
  v=linspace(-1,0,ndiv)';
 otherwise
  v=linspace(-1,1,ndiv)';
end

%darw radial tick marks
h.RadialTicksHandle = line( cos( th + v * tickangle) .* repmat(valid_ticks(:)',ndiv,1), ...
                            sin( th + v * tickangle) .* repmat(valid_ticks(:)',ndiv,1), ...
                            'Color', h.RadialAxisColor, 'LineStyle', h.RadialAxisLineStyle, ...
                            'LineWidth', h.RadialAxisLineWidth, 'Visible', h.RadialAxisVisible, ...
                            'Parent', h.RadialAxisLayer, 'HitTest', 'off');

%prepare tick mark labels
if ischar(h.RadialTickLabels) && strcmp(h.RadialTickLabels, 'auto')
    labels = cellstr(num2str(tickvals(:), '%.1f'));
elseif ischar(h.RadialTickLabels)
    labels = {h.RadialTickLabels};
else
    labels = h.RadialTickLabels;
end

%append radial units string
if strcmp(h.RadialDir, 'reverse')
  labels{1} = [labels{1} h.RadialTickUnits];
else
  labels{end} = [labels{end} h.RadialTickUnits];
end

%determine rotation of labels
if ischar(radialticklabelsangle)
  %labels are written perpendicular to radial axis
  %but always right side up
  tickrot = limit2pi(th+axesrotation+0.5*pi,[-0.5 0.5]*pi);
else
  tickrot = radialticklabelsangle;
end

%determine label offsets
rx = ticks(:) + h.RadialTickLabelsOffset(1); % offset along the radial axis
ry = h.RadialTickLabelsOffset(end); %offset perpendicular to the radial axis

%determine horizontal alignment based on the sign of the offset
%perpendicular to the radial axis
if ry<0
  ha = 'right';
else
  ha = 'left';
end

%correctly deal with axes rotation and angular axis direction
if sin(th+axesrotation-tickrot)<0
  ry = -ry;
end
if strcmp(h.AngleDir,'cw')
  tickrot=-tickrot;
end

%draw radial tick labels
h.RadialLabelsHandle = text( rx.*cos(th)+ry.*sin(th), rx.*sin(th)-ry.*cos(th), labels, ...
                             'HorizontalAlignment', ha, 'VerticalAlignment', ...
                             'middle', 'Color', h.FontColor, 'FontSize', ...
                             h.FontSize, 'FontName', h.FontName, 'Parent', ...
                             h.RadialAxisLayer, 'Rotation', 180*tickrot/pi, ...
                             'HitTest', 'off', 'Visible', h.RadialTickLabelsVisible);

