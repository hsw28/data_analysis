function nodes = getpolyline(varargin)
%GETPOLYLINE let's you define a new polyline
%
%  p=GETPOLYLINE opens a new figure and axes in which you can select
%  a polyline using the mouse. Left mouse button will add a point, middle
%  mouse button will remove the last point. The right mouse button or
%  hitting 'Enter' will end the polyline selection. Pressing 'Esc' will
%  abort the polyline selection. Pressing 'c' will toggle the closed
%  state of the polyline. Pressing 's' will toggle the spline state of
%  the polyline. The function returns a structure with the nodes of the
%  polyline and the closed and spline flags.
%
%  p=GETPOLYLINE(param1,val1,...) additional options. Valid options are:
%   closed - 0/1 initial closed state
%   axes - handle of parent axes
%   maxnodes - maximum number of nodes
%   minnodes - minimum number of nodes
%   spline - 0/1 initial spline state
%


args = struct('closed', false, ...
              'axes', [], ...
              'maxnodes', Inf, ...
              'minnodes', 0, ...
              'spline', 0);

args = parseArgs(varargin, args);

del_fig = false;

if isempty(args.axes)
  hFig = figure;
  figure(hFig);
  args.axes = axes;
  del_fig = true;
elseif ~ishandle(args.axes) || ~strcmp(get(args.axes,'type'),'axes')
  error('getpolyline:invalidAxes', 'Invalid axes');
end
  
axes(args.axes);
hFig = gcf;

old_motionfcn = get(hFig,'WindowButtonMotionFcn');
old_keypressfcn = get(hFig,'KeyPressFcn');
old_downfcn = get( hFig, 'WindowButtonDownFcn');

hRubberLine = line( [NaN NaN NaN], [NaN NaN NaN], 'parent', args.axes, 'linestyle', ...
                    '- -');
hPolyLine = line( NaN, NaN, 'parent', args.axes );
hSpline = line( NaN, NaN, 'parent', args.axes, 'Color', [1 0 0], 'LineStyle', ...
                '- -', 'Visible', onoff(args.spline));

set(hFig,'WindowButtonMotionFcn', @rubberline );
set(hFig,'WindowButtonDownFcn', @btndown);
set(hFig,'KeyPressFcn', @keypress);

nodes = zeros(0,2);
nnodes = 0;
rbnodes = NaN(3,2);

set(hFig,'pointer', 'crosshair');

waitfor( hPolyLine );

set(hFig,'pointer', 'arrow');

delete( hSpline(ishandle(hSpline)) );
delete( hRubberLine(ishandle(hRubberLine)) );

if ishandle(hFig)
  set( hFig, 'WindowButtonMotionFcn', old_motionfcn );
  set( hFig, 'WindowButtonDownFcn', old_downfcn );
  set( hFig, 'KeyPressFcn', old_keypressfcn );
  
  if del_fig
    delete( hFig );
  end
  
end

if ~isempty(nodes)
  nodes = struct( 'nodes', nodes, 'isclosed', args.closed, 'isspline', ...
                  args.spline);
end


  function rubberline(hObj,eventdata) %#ok
  %drawnow;
  cp = get(args.axes, 'CurrentPoint');
  rbnodes(2,:) = cp(1,1:2);
  if args.spline && nnodes>1
    tmp = fnplt( cscvn([nodes; rbnodes(2:3,:)]') );
    set(hSpline, 'XData', tmp(1,:), 'YData', tmp(2,:));
  end  
  set( hRubberLine, 'XData', rbnodes(:,1), 'YData', rbnodes(:,2) );
  end

  function btndown(hObj,eventdata) %#ok
  
  seltype = get(hObj, 'SelectionType');
  cp = get(args.axes, 'CurrentPoint');
  cp = cp(1,1:2);   
    
  switch seltype
   case 'normal' %left mouse button
                 %add point
    if nnodes<args.maxnodes
      nnodes = nnodes+1;
      nodes(nnodes,:) = cp;
      rbnodes(1,:) = cp(1,1:2);
      rbnodes(2,:) = cp(1,1:2);
      if nnodes==1 && args.closed
        rbnodes(3,:) = cp(1,1:2);
      end
      set(hRubberLine, 'XData', rbnodes(:,1), 'YData', rbnodes(:,2));
      set(hPolyLine, 'XData', nodes(:,1), 'YData', nodes(:,2));
      if nnodes>1
        tmp = fnplt( cscvn([nodes; rbnodes(2:3,:)]') );
        set(hSpline, 'XData', tmp(1,:), 'YData', tmp(2,:));
      end
    end
   case 'extend' %middle mouse button
                 %delete last point
    if nnodes>0
      nodes(nnodes,:)=[];
      nnodes=nnodes-1;
      rbnodes(1,:) = nodes(end,:);
      set( hRubberLine, 'XData', rbnodes(:,1), 'YData', rbnodes(:,2));
      set(hPolyLine, 'XData', nodes(:,1), 'YData', nodes(:,2)); 
      if nnodes>1
        tmp = fnplt( cscvn([nodes; rbnodes(2:3,:)]') );
        set(hSpline, 'XData', tmp(1,:), 'YData', tmp(2,:));
      else
        set(hSpline, 'XData', NaN, 'YData', NaN);
      end        
    end
   case 'alt' %right mouse button
    if nnodes>=args.minnodes
      delete(hPolyLine);
    end
    
  end    
  
  end

  function keypress(hObj,eventdata) %#ok
  key = get(hObj,'CurrentCharacter');  
  if double(key) == 13 %enter
    if nnodes>=args.minnodes
      delete(hPolyLine);
    end
  elseif double(key) == 27 %ESC
    nodes = [];
    delete(hPolyLine);
  elseif key=='c'
    args.closed=~args.closed;
    if args.closed
      rbnodes(3,:)=nodes(1,1:2);
    else
      rbnodes(3,:) = NaN(1,2);
    end
    set(hRubberLine, 'XData', rbnodes(:,1), 'YData', rbnodes(:,2));
    if nnodes>1
      tmp = fnplt( cscvn([nodes; rbnodes(2:3,:)]') );
      set(hSpline, 'XData', tmp(1,:), 'YData', tmp(2,:));
    else
      set(hSpline, 'XData', NaN, 'YData', NaN);
    end     
  elseif key=='s'
    args.spline=~args.spline;
    if nnodes>1
      tmp = fnplt( cscvn([nodes; rbnodes(2:3,:)]') );
      set(hSpline, 'XData', tmp(1,:), 'YData', tmp(2,:));
    else
      set(hSpline, 'XData', NaN, 'YData', NaN);
    end 
    set(hSpline,'Visible',onoff(args.spline));
  end  
  end

end
