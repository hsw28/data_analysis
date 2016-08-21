function [center, radius] = getcircle(varargin)
%GETCIRCLE let's you define a new circle
%
%  [center,radius]=GETCIRCLE opens a new figure and axes in which you can
%  select a circle. Left mouse button will start the circle and dragging
%  the mouse will increase/decrease the radius. Releasing the mouse
%  button finishes the circle. Pressing 'Esc' will abort. The function
%  returns the center and the radius of the selected circle.
%
%  [center,radius]=GETCIRCLE('axes',hAx) specifies the handle of the
%  parent axes.
%
  
options = struct( 'axes', [] );
options = parseArgs(varargin,options);

del_fig = false;

if isempty(options.axes)
  hFig = figure;
  figure(hFig);
  options.axes = axes;
  del_fig = true;
elseif ~ishandle(options.axes) || ~strcmp(get(options.axes,'type'),'axes')
  error('uicircle:invalidAxes', 'Invalid axes');
end

axes(options.axes);
hFig = gcf;

old_motionfcn = get(hFig,'WindowButtonMotionFcn');
old_keypressfcn = get(hFig,'KeyPressFcn');
old_downfcn = get( hFig, 'WindowButtonDownFcn');
old_upfcn = get( hFig, 'WindowButtonUpFcn');

hRubberCircle = rectangle('Position', [0 0 eps eps], 'Curvature', [1 1], ...
                          'Visible', 'off', 'Parent', options.axes, ...
                          'LineStyle', '- -');
hRubberLine = line( [NaN NaN], [NaN NaN], 'Parent', options.axes, ...
                    'LineStyle', '- -');
hCenter = line( NaN, NaN, 'Marker', 'o', 'MarkerFaceColor', [0 0 1]);

set(hFig, 'WindowButtonDownFcn', @btndown);
set(hFig,'KeyPressFcn', @keypress);

center = [NaN NaN];
radius = eps;

set(hFig,'pointer', 'crosshair');

waitfor( hCenter );

set(hFig,'pointer', 'arrow');

delete( hRubberCircle(ishandle(hRubberCircle)) );
delete( hRubberLine(ishandle(hRubberLine)) );

if ishandle(hFig)
  set( hFig, 'WindowButtonMotionFcn', old_motionfcn );
  set( hFig, 'WindowButtonDownFcn', old_downfcn );
  set( hFig, 'WindowButtonUpFcn', old_upfcn );
  set( hFig, 'KeyPressFcn', old_keypressfcn );

  if del_fig
    delete(hFig)
  end
  
end


  function btndown(hObj,eventdata) %#ok
  
  cp = get(options.axes, 'CurrentPoint');
  center = cp(1,1:2);  
  
  set( hCenter, 'XData', center(1), 'YData', center(2) );
  set( hRubberLine, 'XData', [center(1) cp(1,1)], 'YData', [center(2) ...
                      cp(1,2)]);
  set( hRubberCircle, 'Position', [center(1)-radius center(2)-radius 2* ...
                      radius 2*radius], 'Visible', 'on');
  
  set( hFig, 'WindowButtonMotionFcn', @rubbercircle );
  set( hFig, 'WindowButtonUpFcn', @stopcircle );
  
  end

  function rubbercircle(hObj, eventdata) %#ok
  cp = get(options.axes, 'CurrentPoint');
  radius = sqrt( sum( (center - cp(1,1:2)).^2 ) );
  set( hRubberLine, 'XData', [center(1) cp(1,1)], 'YData', [center(2) ...
                      cp(1,2)]);
  set( hRubberCircle, 'Position', [center(1)-radius center(2)-radius 2* ...
                      radius 2*radius]);  
  end

  function stopcircle(hObj, eventdata) %#ok
  delete(hCenter);
  end

  function keypress(hObj, eventdata) %#ok
  key = get(hObj,'CurrentCharacter');
  if double(key) == 27 %ESC
    center = [];
    radius = [];
    delete(hCenter);
  end
  end

end
