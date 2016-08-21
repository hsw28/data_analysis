function draw_angle_axis(h)
%DRAW_ANGLE_AXIS draw the angular axis in polar axes
%
%  DRAW_ANGLE_AXIS(h) draws a angular axis in polar axes h
%

%  Copyright 2008-2008 Fabian Kloosterman

%make sure all angular axes properties are returned in radians
anglelim = fkGraphics.getradians(h, 'AngleLim');
angletickvalues = fkGraphics.getradians(h, 'AngleTickValues');

%create angular subdivisions for background
th = linspace(anglelim(1),anglelim(2),100)';

%convert to unit circle
xunit = cos(th);
yunit = sin(th);

%draw polar axis background
h.BackgroundHandle = patch( [xunit; 0], [yunit; 0], h.Color, 'EdgeColor', ...
                            'none', 'Parent', h.BackgroundLayer, 'HitTest','off' );


%if automatic tick values, create fixed number of subdivisions that span
%angular limits
ndiv=9;
if ischar(angletickvalues)
  tv = linspace(anglelim(1),anglelim(2),ndiv);
else
  tv = angletickvalues;
end

%remove last one, if already exists
if tv(1)==tv(end) && numel(tv)>1
  tv(end)=[];
end

%check tick values
ticks = check_angle( tv(:), anglelim, 'nan');

%draw theta grid
nticks = numel(ticks);
h.AngleGridHandle = line( [zeros(nticks,1) cos( ticks )]', [zeros(nticks,1) ...
                    sin(ticks)]', 'Color', h.AngleGridColor, 'LineStyle', ...
                          h.AngleGridLineStyle, 'LineWidth', ...
                          h.AngleGridLineWidth, 'Parent', h.AngleAxisLayer, ...
                          'HitTest', 'off', 'Visible', h.AngleGridVisible );

%draw theta axis
h.AngleAxisHandle = line( xunit, yunit, 'Color', h.AngleAxisColor, ...
                          'LineStyle', h.AngleAxisLineStyle, 'LineWidth', ...
                          h.AngleAxisLineWidth, 'Visible', h.AngleAxisVisible, ...
                          'Parent', h.AngleAxisLayer, 'HitTest', 'off');

%create tick marks
L = h.AngleTickLength;
switch h.AngleTickDir
    case 'both'
        tmp = [1-L 1+L]';
    case 'out'
        tmp = [1 1+L]';
    case 'in'
        tmp = [1-L 1]';        
end

%draw tick marks
h.AngleTicksHandle = line( tmp * cos(ticks'), tmp * sin(ticks'), 'Color', ...
                           h.AngleAxisColor, 'LineStyle', h.AngleAxisLineStyle, ...
                           'LineWidth', h.AngleAxisLineWidth, 'Visible', ...
                           h.AngleAxisVisible, 'Parent', h.AngleAxisLayer);

%prepare labels
interpreter = 'tex'; %default interpreter for labels
if ischar(h.AngleTickLabels) && strcmp(h.AngleTickLabels, 'auto')
  %labels are automatically created based on tick values
  interpreter = 'latex'; %switch to latex interpreter 
  switch h.AngleTickUnits
   case 'degrees'            
    switch h.AngleTickSign
     case 'signed'
      tmp = 180*limit2pi(ticks,-pi)/pi;
      labels=cell(1,numel(tmp));
      for k=1:numel(tmp)
        if abs(tmp(k))~=180
          labels{k} = horzcat( '$$', num2str( tmp(k) , '%.0f' ), '^o$$');
        else
          labels{k} = horzcat( '$$\pm ', num2str( abs(tmp(k)) , '%.0f' ), '^o$$');
        end
      end 
     case 'unsigned'
      labels = cellstr( horzcat( repmat('$$',nticks,1), num2str( 180*ticks/pi, '%.0f' ),repmat('^o$$',nticks,1)) );                    
    end
   case 'radians'
    switch h.AngleTickSign
     case 'signed'
      tmp = limit2pi(ticks, -pi)./pi;
     case 'unsigned'
      tmp = ticks./pi;
    end
    for k=1:numel(tmp)
      labels{k} = ['$$' tofrac(tmp(k), h.AngleTickSign) '$$'];
    end
   otherwise
    labels = cellstr( num2str( ticks, '%.2f' ) );            
  end
elseif ischar(h.AngleTickLabels)
  labels = {h.AngleTickLabels};
else
  labels = h.AngleTickLabels;
end

%draw angular tick labels
offset = 1 + h.AngleTickLabelsOffset;
h.AngleLabelsHandle = text(  offset*cos(ticks), offset*sin(ticks), labels, ...
                             'HorizontalAlignment', 'center', 'Color', ...
                             h.FontColor, 'FontSize', h.FontSize, 'FontName', ...
                             h.FontName, 'Parent', h.AngleAxisLayer, ...
                             'Interpreter', interpreter, 'HitTest', 'off', ...
                             'Visible', h.AngleTickLabelsVisible);



%-------SUBFUNCTIONS-------

function t = tofrac( x, sgn )
%TOFRAC helper function
%
%  t=TOFRAC(val,option) returns a text string with the latex notation of
%  val as fractional radians. Option argument is either 'signed' or
%  'unsigned' and indicated whether plus/minus sign or not.
%

switch sgn
    case 'signed'
        sgn = 1;
    case 'unsigned'
        sgn = 0;
end

[p,q] = rat( x );
if q==1 && abs(p)>1
    t = [num2str(p) 'pi'];
elseif q==1 && abs(p)==1
    if sgn
        t = '\pm pi';
    else
        if p<0
            t = '-pi';
        else
            t = 'pi';
        end
    end
elseif p==0
    t = '\textsl{0}';
else
    t = ['\frac{' num2str(p) '}{' num2str(q) '}pi'];
end
