function hCircle = icircle(center, radius, varargin)
%ICIRCLE draw an editable circle
%
%  h=ICIRCLE(center,radius) draws a circle defined by center and radius
%  and allows the user to interactively change the circle. The function
%  returns a handle to the circle. Get(h,'circle') will return a
%  structure with circle data. Dragging the center point of the circle
%  will move the circle, dragging the circle itself will change its
%  radius.
%
%  h=ICIRCLE(...,parm1,val1,...) passes in extra parameter/value
%  pairs. Valid paramters are:
%   axes - handle of parent axes
%   need_selection - circle can be edited only when it is selected
%   selected - 0/1 selected state of circle
%


%check input arguments
if nargin<1
  help(mfilename)
  return
end

options = struct( 'axes', [], 'need_selection', 0, 'selected', 0);
options = parseArgs( varargin, options );

if isempty( options.axes )
  options.axes = gca;
end

axes(options.axes);
hFig = gcf;

%create lines
hCenter = line(center(1),center(2), 'Marker', 'o', 'MarkerFaceColor', [0 ...
                    0 1]);
s = rsmak('circle', radius, center );
pnts = fnplt( s );
hCircle = line( pnts(1,:), pnts(2,:) );

set( hCenter, 'ButtonDownFcn', @startdrag_center);
set( hCircle, 'ButtonDownFcn', @startdrag_radius);

set( hCircle, 'DeleteFcn', @delfcn)

schema.prop( hCircle, 'circle', 'mxArray' );
set( hCircle, 'circle', struct( 'center', center, 'radius', radius ) );

  function delfcn(hObj,eventdata) %#ok
  delete(hCenter(ishandle(hCenter)));
  end

  function startdrag_center(hObj, eventdata) %#ok
  if strcmp(get(hCircle,'Selected'),'off') && options.need_selection
    return
  end
  
  set( hFig, 'WindowButtonMotionFcn', @drag_center);
  set( hFig, 'WindowButtonUpFcn', @stopdrag );  
  
  end 

  function startdrag_radius(hObj, eventdata) %#ok
  if strcmp(get(hCircle,'Selected'),'off') && options.need_selection
    return
  end
  
  set( hFig, 'WindowButtonMotionFcn', @drag_radius);
  set( hFig, 'WindowButtonUpFcn', @stopdrag );  

  end

  function drag_center(hObj, eventdata) %#ok
  cp = get(options.axes, 'CurrentPoint');
  set(hCircle, 'XData', get(hCircle,'XData')-center(1)+cp(1,1) );
  set(hCircle, 'YData', get(hCircle,'YData')-center(2)+cp(1,2) );
  center = cp(1,1:2);
  set(hCenter, 'XData', center(1), 'YData', center(2));
  set(hCircle, 'circle', struct( 'center', center, 'radius', radius ) );
  end

  function drag_radius(hObj, eventdata) %#ok
  cp = get(options.axes, 'CurrentPoint');
  radius = sqrt( sum( (center - cp(1,1:2)).^2 ) );
  s = rsmak('circle', radius, center );
  pnts = fnplt( s );
  set(hCircle, 'XData', pnts(1,:), 'YData', pnts(2,:));
  set(hCircle, 'circle', struct( 'center', center, 'radius', radius ) );
  end

  function stopdrag(hObj, eventdata) %#ok
  set( hFig, 'WindowButtonMotionFcn', [] );
  set( hFig, 'WindowButtonUpFcn', [] );
  end

end
