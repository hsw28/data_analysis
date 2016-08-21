function hPolyLine = ipolyline(nodes, varargin)
%IPOLYLINE draw an editable polyline
%
%  h=IPOLYLINE(nodes) draws the polyline defined by the nx2 matrix of
%  node coordinates and allows the user to interactively change the
%  polyline. The function returns a handle. Get(h,'polyline') will return
%  a structure with polyline data. Nodes can be dragged to new locations
%  by the left mouse button. New nodes can be created by a middle mouse
%  button click one of the edges. A right mouse button click will show a
%  popup menu in which the user will be able to set the 'closed' and
%  'spline' flags. 
%
%  h=IPOLYLINE(struct) draws the polyline defined by the structure with
%  required field 'nodes', which is a nx2 matrix. Optional fields are
%  'isclosed' and 'isspline'.
%
%  h=IPOLYLINE(...,parm1,val1,...) passes in extra parameter/value
%  pairs. Valid paramters are:
%   axes - handle of parent axes
%   need_selection - polyline can be edited only when it is selected
%   selected - 0/1 selected state of polyline
%

%check input arguments
if nargin<1
  help(mfilename)
  return
end

if isnumeric(nodes) && size(nodes,2)==2 && size(nodes,1)>0
  p = struct( 'nodes', nodes, 'isclosed', 0, 'isspline', 0);
elseif isstruct(nodes) && isfield(nodes, 'nodes') ...
      && isnumeric(nodes.nodes) && size(nodes.nodes,2)==2 && ...
      size(nodes.nodes,1)>0
  
  p=struct('nodes',nodes.nodes, 'isclosed',0,'isspline',0);
  
  if isfield(nodes,'isclosed') && nodes.isclosed
    p.isclosed=1;
  end
  
  if isfield(nodes,'isspline') && nodes.isspline
    p.isspline=1;
  end
else
  error('ipolyline:invalidArgument', 'Invalid polyline')
end

clear nodes;

options = struct( 'axes', [], 'need_selection', 0, 'selected', 0);
options = parseArgs( varargin, options );

if isempty( options.axes )
  options.axes = gca;
end

axes(options.axes);
hFig = gcf;

if p.isclosed
  terminal_node = 1;
else
  terminal_node = [];
end

%create lines
hPolyLine = line( p.nodes([1:end terminal_node],1), p.nodes([1:end terminal_node],2), ...
                  'parent', options.axes, 'selected', onoff(options.selected));
hNodes = line( p.nodes(:,1), p.nodes(:,2), 'LineStyle', 'none', ...
               'Marker', 'o', 'MarkerFaceColor', [0 0 1], 'parent', options.axes);
pnts = fnplt( cscvn( p.nodes([1:end terminal_node],:)' ) );
hSpline = line( pnts(1,:), pnts(2,:), 'Color', [1 0 0], 'LineStyle', ['- ' ...
                    '-'], 'HitTest', 'off', 'Visible', onoff(p.isspline), ...
                'parent', options.axes);

set(hNodes, 'ButtonDownFcn', @nodeclick );
set(hPolyLine, 'ButtonDownFcn', @addnode );

cmenu = uicontextmenu;
menu_close = uimenu(cmenu,'Label','closed','Checked',onoff(p.isclosed),'Callback',@closefcn);
menu_spline = uimenu(cmenu,'Label','spline','Checked',onoff(p.isspline),'Callback',@splinefcn);

set( hPolyLine, 'UIContextMenu', cmenu );
set( hNodes, 'UIContextMenu', cmenu );

set( hPolyLine, 'DeleteFcn', @delfcn)

prp = schema.prop( hPolyLine, 'polyline', 'mxArray' ); %#ok
set( hPolyLine, 'polyline', struct( 'nodes', p.nodes, 'isclosed', p.isclosed, ...
                                    'isspline', p.isspline ) );

  function delfcn(hObj,eventdata) %#ok
  delete(hNodes(ishandle(hNodes)));
  delete(hSpline(ishandle(hSpline)));
  end

  function nodeclick(hObj, eventdata) %#ok
  if strcmp(get(hPolyLine,'Selected'),'off') && options.need_selection
    return
  end
  btn = get(gcf,'SelectionType');
  switch btn
   case 'normal'
    cp = get(options.axes, 'CurrentPoint');
    [idx,idx] = min( sum([p.nodes(:,1)-cp(1,1) p.nodes(:,2)-cp(1,2)].^2,2) );  %#ok
    set( hFig, 'WindowButtonUpFcn', @drop_node )
    set( hFig, 'WindowButtonMotionFcn', {@move_node, idx} )
   case 'extend'
    cp = get(options.axes, 'CurrentPoint');    
    [idx,idx] = min( sum([p.nodes(:,1)-cp(1,1) p.nodes(:,2)-cp(1,2)].^2,2) ); %#ok
    p.nodes(idx,:)=[];
    set(hNodes, 'XData', p.nodes(:,1), 'YData', p.nodes(:,2) );
    set(hPolyLine, 'XData', p.nodes([1:end terminal_node],1), ...
                   'YData', p.nodes([1:end terminal_node],2) );
    set(hPolyLine, 'polyline', p );
    pnts = fnplt( cscvn( p.nodes([1:end terminal_node],:)' ) );
    set(hSpline, 'XData', pnts(1,:), 'YData', pnts(2,:) );
  end
  end

  function move_node(hObj, eventdata, idx) %#ok
  cp = get(options.axes, 'CurrentPoint');  
  p.nodes(idx,:) = cp(1,1:2);
  set(hNodes, 'XData', p.nodes(:,1), 'YData', p.nodes(:,2) );
  set(hPolyLine, 'XData', p.nodes([1:end terminal_node],1), ...
                 'YData', p.nodes([1:end terminal_node],2));
  set(hPolyLine, 'polyline', p );  
  pnts = fnplt( cscvn( p.nodes([1:end terminal_node],:)' ) );
  set(hSpline, 'XData', pnts(1,:), 'YData', pnts(2,:) );
  end

  function drop_node(hObj, eventdata) %#ok
  set( hFig, 'WindowButtonUpFcn', [] )
  set( hFig, 'WindowButtonMotionFcn', [] )
  end

  function addnode(hObj,eventdata) %#ok
  if strcmp(get(hPolyLine,'Selected'),'off') && options.need_selection
    return
  end
  btn = get(gcf,'SelectionType');
  switch btn
   case 'extend'
    cp = get(options.axes, 'CurrentPoint');
    [idx,idx,idx]=point2polyline( p.nodes, cp(1,1:2), 1, p.isclosed ); %#ok
    p.nodes = interlace( p.nodes, cp(1,1:2), idx );
    set(hNodes, 'XData', p.nodes(:,1), 'YData', p.nodes(:,2) );
    set(hPolyLine, 'XData', p.nodes([1:end terminal_node],1), ...
                   'YData', p.nodes([1:end terminal_node],2)); 
    set(hPolyLine, 'polyline', p );      
    pnts = fnplt( cscvn( p.nodes([1:end terminal_node],:)' ) );
    set(hSpline, 'XData', pnts(1,:), 'YData', pnts(2,:) );    
  end
  end


  function closefcn(hObj,eventdata) %#ok
  if strcmp(get(hPolyLine,'Selected'),'off') && options.need_selection
    return
  end
  p.isclosed=~p.isclosed;
  set(menu_close,'Checked',onoff(p.isclosed));
  if p.isclosed
    terminal_node = 1;
  else
    terminal_node = [];
  end  
  set(hPolyLine, 'XData', p.nodes([1:end terminal_node],1), ...
                 'YData', p.nodes([1:end terminal_node],2) );
  set(hPolyLine, 'polyline', p);      
  pnts = fnplt( cscvn( p.nodes([1:end terminal_node],:)' ) );
  set(hSpline, 'XData', pnts(1,:), 'YData', pnts(2,:) );   
  end

  function splinefcn(hObj,eventdata) %#ok
  if strcmp(get(hPolyLine,'Selected'),'off') && options.need_selection
    return
  end
  p.isspline=~p.isspline;
  set(menu_spline,'Checked',onoff(p.isspline));
  set(hSpline, 'Visible', onoff(p.isspline));
  set(hPolyLine, 'polyline', p);
  end

end
