function varargout = event_dispatch( hFig, cmd )
%EVENT_DISPATCH setup figure to receive event notification
%
%  EVENT_DISPATCH sets up event notifications for the current figure. If
%  no figure exist a new one will be created.
%
%  EVENT_DISPATCH ON sets up the current figure for event notifications.
%
%  EVENT_DISPATCH OFF removes event notification framework from currrent
%  figure
%
%  EVENT_DISPATCH CLEAR disables mouse event notifications in all open
%  figures and removes all evidence of the framework
%
%  EVENT_DISPATCH(hFig) sets up event notifications for specified figure
%
%  EVENT_DISPATCH(hFig, command) runs command ('on', 'off', 'clear') for
%  specified figure 
%
%  hFig=EVENT_DISPATCH( ... ) returns figure handle.
%
%  This event notification framework runs parallel to the native Matlab
%  handle graphics object callbacks like 'Callback', 'ButtonDownFcn',
%  'KeyPressFcn'. The framework only works for graphical objects on the
%  figure canvas (so called canvas objects, i.e. the figure itself,
%  uipanels, axes and children of axes), but NOT on any object that has
%  an underlying Java component that handles the events (i.e. uicontrols,
%  uitree, etc.).
%
%  The following event callbacks exist:
%    MyButtonDownFcn - called when a mouse button is pressed
%    MyButtonUpFcn - called when a mouse button is released
%    MyWheelMovedFcn - called when mouse wheel moved
%    MyStartDragFcn - called when a drag operation starts
%    MyStopDragFcn - called when a drag operation ends
%    MyDragFcn - called when mouse is dragged
%    MyKeyPressFcn - called when a key is pressed
%    MyKeyreleaseFcn - called when key is released
%
%  Event handling can be turned on for a graphical object by calling
%  enable_events. For every canvas object event callbacks can be set and
%  retrieved using the Matlab SET and GET commands. Alternatively, these
%  properties can be set or removed using the helper functions
%  ADD_CALLBACK and REMOVE_CALLBACK.
%
%  A callback can be any of the following:
%  1. A string, which will evaluated in the base workspace. Since Matlab's
%  gcbo function to get the current callback object doesn't work properly
%  with this event framework, a temporary variable called gcbo is created
%  in the base workspace and it is assigned the callback object's handle.
%  2. A function handle or a cell array with the first cell either a
%  function name or a function handle. The remaining cells in the cell
%  array are optional user defined extra arguments that are passed on to
%  the callback function. The signature of a callback function is:
%    success = fcn( hObj, eventdata, ... extra arguments ...)
%  3. A nx2 cell array of multiple callbacks. The first column of cells
%  contains a string (as under 1.) or a callback function (as under 2.)
%  and the second column of cells contains a ID to indentify the callback
%  function. The ADD_CALLBACK and REMOVE_CALLBACK functions can be used
%  to add and remove callback from this cell array.
%
%  The first argument of a callback function is the handle of the object
%  that receives the event notification (i.e. the callback object). The
%  second argument is an event data structure, with information about the
%  event. The structure is translated from Java by Matlab with the
%  following fields (this is only a partial list and not all field are
%  present for each type of event):
%  AltDown - 'on'/'off' state of alt-key
%  Button - which mouse button was pressed/released or started dragging
%  ControlDown - 'on'/'off' state of control-key
%  KeyChar - character representation of key press
%  KeyCode - key code
%  MetaDown - 'on'/'off' state of meta-key
%  Modifiers - state of modifier keys and buttons that changed state
%  ModifiersEx - state of modifier keys and buttons
%  Point - x,y pixel coordinates of point clicked
%  ShiftDown - 'on'/'off' state of shift-key
%  WheelRotation - wheel rotation steps (positive or negative)
%  When - event timestamp
%  The framework adds the following extra fields to the event data
%  structure:
%  HitObject - handle of the object that was directly under the mouse
%              cursor when the event occurred and had its HitTest
%              property set to 1. During dragging, HitObject is set to
%              the object where dragging started
%  HitPoint - local x,y coordinates of mouse cursor location (in
%             HitObject coordinates)
%  ClickedPoint - local x,y coordinates of mouse cursor location at the
%                 time of mouse press/release. While dragging
%                 ClickedPoint contains the coordinates of the point
%                 where dragging started.
%  Dragging - 0/1 indicates if the mouse is being dragged or not
%  ActiveButtons - All pressed buttons
%
%  The event dispatcher finds the object under the mouse cursor using
%  Matlab's hittest function. This means that if an object has its
%  HitTest property set to 0, it will be unable to receive events. The
%  event dispatcher uses the following rules to determine which object
%  will receive the event notification (and thus which callback function
%  are being executed):
%  MyButtonDown, MyButtonUp, MyWheelMoved events are sent to the object
%  directly beneath the mouse cursor.
%  MyKeyPress, MyKeyRelease events are sent to the figure's current
%  object. If there is no current object, then it will be sent to the
%  current axes. If there is no current axes, the event will be sent to
%  the figure.
%  MyStartDrag, MyDrag, MyStopDrag events are all sent to the object
%  where dragging started
%
%  Note that while dragging, all MyButtonDown, MyButtonUp and
%  MyWheelMoved events are directed to the object where the drag
%  operation started. For example, when a drag operation was started in
%  the figure, but the mouse cursor was dragged over an axes, then still
%  the figure will receive all drag related events and any additional
%  MyButtonDown, MyButtonUp and MyWheelMoved events. For this example,
%  the extra eventdata structure fields will contain the following:
%  HitObject - figure handle
%  HitPoint - current mouse cursor location in figure coordinates
%  ClickedObject - figure handle
%  ClickedPoint - mouse cursor location at time of first mouse press in
%  figure (in figure coordinates)
%
%  For objects that are descendents of an axes (i.e. plotting objects),
%  the event notification will propagate up the hierarchy to the parent
%  axes until the event is succesfully processed. Thus if a plotting
%  object has no callbacks, then its parent will receive the event
%  next. If any callback is a string or a function with no output
%  arguments, then it is assumed that the event was successfully
%  processed and the event does not propagate any further. Callback
%  functions that do return an output argument have control over the
%  propagation: if they return false, the event wasn't processed and if
%  they return true the event was processed. For example if a patch
%  object responds to left button clicks, it could test for the button
%  pressed in its MyButtonUp callback and if any other button than the
%  left obe was pressed it would return false, so that it parent axes can
%  have a chance to process it (for example because the axes responds to
%  a right button click).
%
%  See also SCROLL_ZOOM, SCROLL_PAN, RULER, TAB_AXES, TEST_EVENTS,
%  DEMO_EVENTS, ENABLE_EVENTS
%

%  Copyright (C) 2006 Fabian Kloosterman
%
%  This program is free software; you can redistribute it and/or modify it
%  under the terms of the GNU General Public License as published by the
%  Free Software Foundation; either version 2 of the License, or (at your
%  option) any later version.
%
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
%  Public License for more details.
%
%  You should have received a copy of the GNU General Public License along
%  with this program; if not, write to the Free Software Foundation, Inc.,
%  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 


v = ver('Matlab');
v = regexp( v.Version, '(?<major>[0-9]+)\.(?<minor>[0-9]+).*', 'names');
v.major = str2num(v.major);
v.minor = str2num(v.minor);

if nargin<1
  cmd = 'on';
  hFig = [];
elseif ischar(hFig) && nargin==1
  cmd = lower(hFig);
  hFig = [];
elseif ~isempty(hFig) && ~isscalar(hFig) && ~ishandle(hFig) && ~strcmp(get(hFig,'Type'),'figure')
  error('event_dispatch:invalidHandle', 'Invalid handle')
elseif nargin<2
  cmd = 'on';
end

if nargin==2 && ischar(cmd) && ismember( lower(cmd), {'on', 'off', 'move', ...
                      'nomove'} )
  cmd = lower(cmd);
end

if ~strcmp( cmd, 'clear')
  if isempty(hFig)
    hFig = gcf;
  end

  dispatch_info = getappdata( hFig, 'EventDispatch' );
end

switch cmd
 case 'reset'
  setup_events(hFig);
 case 'on'
  if isempty(dispatch_info)
    setup_events(hFig);
  end
 case 'off'
  if ~isempty(dispatch_info)
    remove_events(hFig);
  end
 case 'clear'
  %get all figures and make recursive calls
  set(0, 'ShowHiddenHandles', 'on');
  hFig = findobj( 0, 'Type', 'figure' );
  set(0, 'ShowHiddenHandles', 'off');
  for k=1:numel(hFig)
    remove_events(hFig(k));
  end
 otherwise
  error('event_dispatch:invalidArguments', 'Invalid command' )
end

if nargout>0
  varargout{1} = hFig;
end


function remove_events( hFig )
%define valid event callbacks
props = {'MyButtonDownFcn', 'MyButtonUpFcn', 'MyKeyPressFcn', ...
         'MyKeyReleaseFcn', 'MyDragFcn', 'MyWheelMovedFcn', 'MyStartDragFcn', ...
         'MyStopDragFcn'};

dispatch_info = getappdata( hFig, 'EventDispatch' );

if isempty(dispatch_info)
  return
end

drawnow; %needed for new figures, otherwise hf below is empty

%get internal java objects
hf = get(hFig, 'javaframe');
canvas = getAxisComponent(hf);

%make callbacks non-interruptible
set(canvas, 'Interruptible', 'on');

%remove listeners
delete( dispatch_info.listener)

fcn = get( hFig, 'WindowButtonMotionFcn' );
if ischar(fcn) && strcmp(fcn, ';')
  set(hFig, 'WindowButtonMotionFcn', []);
end
fcn = get( hFig, 'KeyPressFcn' );
if ischar(fcn) && strcmp(fcn, ';')
  set(hFig, 'KeyPressFcn', []);
end
  
%delete callbacks properties from figure and its children
deleteprops( hFig );

set(canvas, 'MousePressedCallback', [], ...
            'MouseReleasedCallback',[], ...
            'MouseDraggedCallback', []);

% for R14SP3 and up
if v.major>=7 && v.minor>=1
  set(canvas, 'MouseWheelMovedCallback', [] );
else %for releases before R14SP3
  rootpane = hf.fTopLevelPanel.getRootPane;
  set(rootpane, 'MouseWheelMovedCallback', [] );
end


set(canvas, 'KeyPressedCallback', [], 'KeyReleasedCallback', []);


rmappdata( hFig, 'EventDispatch' );

  function deleteprops( h )
  %remove callbacks
  for k=1:numel(props)
    p = findprop( handle( h ), props{k}  );
    delete(p);
  end
  
  children = get(h, 'Children' );
  for c=1:numel(children)
    deleteprops( children(c) );
  end
  
  end

end


function setup_events( hFig )

%define valid event callbacks
props = {'MyButtonDownFcn', 'MyButtonUpFcn', 'MyKeyPressFcn', ...
         'MyKeyReleaseFcn', 'MyDragFcn', 'MyWheelMovedFcn', 'MyStartDragFcn', ...
         'MyStopDragFcn'};


drawnow; %needed for new figures, otherwise hf below is empty, but very slow

%get internal java objects
hf = get(hFig, 'javaframe');
canvas = getAxisComponent(hf);


%make callbacks non-interruptible and cancel events if a callback is
%executing
set(canvas, 'Interruptible', 'off');
set(canvas, 'BusyAction', 'cancel');

%WindowButtonMotionFcn has to contain something, otherwise matlab will
%not automatically update CurrentPoint when the mouse is moving
if isempty( get(hFig, 'WindowButtonMotionFcn') )
  set(hFig, 'WindowButtonMotionFcn', ';') 
end
%KeyPressFcn has to contain something, otherwise with every key press
%focus is shifted to the command window
if isempty( get(hFig, 'KeyPressFcn' ) )
  set( hFig, 'KeyPressFcn', ';')
end

%add callbacks as properties to figure and its children
addprops( hFig );

%childadded(hFig,[]);  


%listen for changes to WindowButtonMotionFcn, KeyPressFcn and make sure
%that they are never empty
hgpkg = findpackage('hg'); 
figclass = hgpkg.findclass('figure');
L(1) = handle.listener(hFig, figclass.findprop('WindowButtonMotionFcn'), ...
                       'PropertyPostSet', @changefcn1);
L(2) = handle.listener(hFig, figclass.findprop('KeyPressFcn'), ...
                       'PropertyPostSet', @changefcn2);
L(3) = handle.listener(hFig, figclass.findprop('Renderer'), ...
                       'PropertyPostSet', @changefcn3);
%listen for new child additions and add callbacks to new children
%L(3) = handle.listener(hFig, 'ObjectChildAdded', @childadded);



set(canvas, 'MousePressedCallback', {@buttondownfcn, hFig}, ...
            'MouseReleasedCallback', {@buttonupfcn,hFig}, 'MouseDraggedCallback', ...
            {@draggedfcn, hFig} );

% for R14SP3 and up
if v.major>=7 && v.minor>=1
  set(canvas, 'MouseWheelMovedCallback', {@wheelfcn, hFig} );
else %for releases before R14SP3
     %for reasons unknown to me wheel events are not picked up by the
     %canvas, but they are by the rootpane
  rootpane = hf.fTopLevelPanel.getRootPane;
  set(rootpane, 'MouseWheelMovedCallback', {@wheelfcn, hFig} );
end

set(canvas, 'KeyPressedCallback', {@keypressfcn, hFig}, 'KeyReleasedCallback', ...
            {@keyreleasefcn, hFig});

%save dispatcher info
appstruct = struct('canvas', canvas, ...
                   'listener', L, ...
                   'dragging', 0, ...
                   'clickedobject', [], ...
                   'clickedpoint', [] ...
                   );

if v.major>=7 && v.minor>=1
  %pass
else
  appstruct.rootpane=rootpane;
end

setappdata( hFig, 'EventDispatch', appstruct );


  function childadded( h, e) %#ok
  %add callback properties to children of object
  if isempty(e)
    children = get(h, 'Children');
  else
    children = get(e, 'Child');
  end
  for k=1:numel(children)
    if isprop(children(k),'Type') && ~all(strcmp( get( children(k), 'Type'), {'uicontrol', 'uicontainer', 'uipushtool'} ))
      addprops( children(k) );
      childadded( children(k), [] ); %recurse
      if any(strcmp( get(children(k),'Type'), {'figure', 'axes', 'uipanel', ...
                            'hggroup', 'hgtransform'} ) ) && ~isprop(children(k), ...
                                                          'ChildAddedListener')
        %add listener to containers
        L = handle.listener( handle(children(k)), 'ObjectChildAdded', ...
                             @childadded );
        schema.prop( children(k), 'ChildAddedListener', 'mxArray' );
        set(children(k), 'ChildAddedListener', L );
      end
      if strcmp( get(children(k), 'Type'), {'axes'} )
        %add props to labels and title objects as well
        addprops( get(children(k), 'title') );
        addprops( get(children(k), 'xlabel') );        
        addprops( get(children(k), 'zlabel') );
        addprops( get(children(k), 'ylabel') );        
      end
    end
  end
  end

  function addprops( h ) %#ok
  %add callback properties to object
    for k=1:numel(props)
      if isempty( findprop( handle( h ), props{k} ) )
        schema.prop( h, props{k}, 'mxArray' );
      end
    end    
  end

end

end

%define dispatch callbacks
%==========================================================================
function changefcn1( h, e) %#ok
%make sure WindowButtonMotionFcn callback is not empty

if isempty(e.NewValue)
  set( e.AffectedObject, 'WindowButtonMotionFcn', ';');
end

end
%==========================================================================

%==========================================================================
function changefcn2( h, e) %#ok
%make sure KeyPressFcn callback is not empty

if isempty(e.NewValue)
    set( e.AffectedObject, 'KeyPressFcn', ';');
end

end
%==========================================================================

%==========================================================================
function changefcn3( h, e) %#ok
%reset after renderer changed
h = double(e.affectedObject);
t = timer('TimerFcn', {@timerfcn, h}, ...
                   'StartDelay', 0.1, 'ExecutionMode', 'singleShot');
start(t);
setappdata(h, 'EventDispatchTimer', t);
               
               %event_dispatch(double(e.affectedObject),'reset');

end
%==========================================================================

function timerfcn(h,e,hF) %#ok

event_dispatch(hF,'reset');
t=getappdata(hF,'EventDispatchTimer');
if ~isempty(t)
    stop(t);
    delete(t);
    rmappdata(hF,'EventDispatchTimer');
end




end

%==========================================================================
function keypressfcn( dummy, eventdata, hObj ) %#ok
%axes canvas received a key press event

%create eventdata structure
eventdata = struct(get(eventdata));

%get object that will receive event notification
%first find the current object of the figure
h = get( hObj, 'CurrentObject' );
if isempty(h)
  %alternatively find the current axes
  h = get( hObj, 'CurrentAxes' );
end
if isempty( h )
  %as a last resort, the figure will receive the event
  h = hObj;
end

callback = 'MyKeyPressFcn';

process_event_callbacks( h, callback, eventdata );

end
%==========================================================================


%==========================================================================
function keyreleasefcn( dummy, eventdata, hObj ) %#ok
%axes canvas received a key release event

%create eventdata structure
eventdata = struct(get(eventdata));

%get object that will receive event notification
%first find the current object of the figure
h = get( hObj, 'CurrentObject' );
if isempty(h)
  %alternatively find the current axes
  h = get( hObj, 'CurrentAxes' );
end
if isempty(h)
  %as a last resort, the figure will receive the event
  h = hObj;
end

callback = 'MyKeyReleaseFcn';

process_event_callbacks( h, callback, eventdata );

end
%==========================================================================

%==========================================================================
function wheelfcn( dummy, eventdata, hObj ) %#ok
%rootpane/canvas received a wheel moved event

%create eventdata structure
eventdata = struct(get(eventdata));

cb = getappdata(hObj, 'EventDispatch');

 
if cb.dragging
 
  eventdata.Dragging = 1;
  
  %clicked object will receive event
  %get dragged point
  [eventdata.HitObject, eventdata.HitPoint] = get_pointer_object( cb.clickedobject, ...
                                                    eventdata.Point, 1 );
  %clicked point
  eventdata.ClickedPoint = cb.clickedpoint;
  
  
else
  
  eventdata.Dragging = 0;
  
  %get hit object and hit point
  [eventdata.HitObject, eventdata.HitPoint] = get_pointer_object( hObj, ...
                                                    eventdata.Point );  
   %clicked point
  eventdata.ClickedPoint = eventdata.HitPoint;
  
  
end
  
callback = 'MyWheelMovedFcn';

process_event_callbacks( eventdata.HitObject, callback, eventdata );

end
%==========================================================================

%==========================================================================
function draggedfcn( dummy, eventdata, hObj ) %#ok
%axes canvas received a mouse dragged event

%create eventdata structure
eventdata = struct(get(eventdata));

%get figure appdata
cb = getappdata(hObj, 'EventDispatch');

eventdata.ActiveButtons = find( bitget( eventdata.ModifiersEx, [11 12 13] ) );

if ~cb.dragging

  %find the buttons that are currently pressed
  btns = find( bitget( eventdata.Modifiers, [5 4 3] ) );
  eventdata.Button = btns;  
  
  cb.dragging = 1;
  setappdata( hObj, 'EventDispatch', cb );
  
  eventdata.Dragging = 0;

  eventdata.ClickedPoint = cb.clickedpoint;
  eventdata.HitPoint = eventdata.ClickedPoint;
  eventdata.HitObject = cb.clickedobject;
  
  callback = 'MyStartDragFcn';
  
  process_event_callbacks( cb.clickedobject, callback, eventdata );
  
end

[eventdata.HitObject, eventdata.HitPoint] = get_pointer_object( ...
    cb.clickedobject, eventdata.Point, 1);

eventdata.ClickedPoint = cb.clickedpoint;
eventdata.Dragging = 1;
eventdata.Button = [];

callback = 'MyDragFcn';
  
process_event_callbacks( eventdata.HitObject, callback, eventdata);
  


end
%==========================================================================

%==========================================================================
function buttonupfcn( dummy, eventdata, hObj ) %#ok
%axes canvas received a button up event

%create eventdata structure
eventdata = struct(get(eventdata));

%get figure appdata
cb = getappdata(hObj, 'EventDispatch');


eventdata.ActiveButtons = find( bitget( eventdata.ModifiersEx, [11 12 13] ) );

if cb.dragging

  [eventdata.HitObject, eventdata.HitPoint] = get_pointer_object( ...
      cb.clickedobject, eventdata.Point, 1);
    
  eventdata.Dragging = 1;
  eventdata.ClickedPoint = cb.clickedpoint;  
  
  callback = 'MyButtonUpFcn';
  
  process_event_callbacks( eventdata.HitObject, callback, eventdata );
  
  if isempty(eventdata.ActiveButtons)
    
    eventdata.Dragging = 0;
    
    cb.dragging = 0;
    cb.clickedobject = [];
    cb.clickedpoint = [];
   
    setappdata( hObj, 'EventDispatch', cb );
    
    callback = 'MyStopDragFcn';
    
    process_event_callbacks( eventdata.HitObject, callback, eventdata );
    
  end
  
else
  %get hit object and hit point
  [eventdata.HitObject, eventdata.HitPoint] = get_pointer_object( hObj, ...
                                                    eventdata.Point );
  
  
  callback = 'MyButtonUpFcn';
  
  eventdata.ClickedPoint = eventdata.HitPoint;
  
  process_event_callbacks( eventdata.HitObject, callback, eventdata );
  
end



end
%==========================================================================

%==========================================================================
function buttondownfcn( dummy, eventdata, hObj ) %#ok
%axes canvas received a button down event

%create eventdata structure
eventdata = struct(get(eventdata));

%get figure appdata
cb = getappdata(hObj, 'EventDispatch');

eventdata.ActiveButtons = find( bitget( eventdata.ModifiersEx, [11 12 13] ) );

if cb.dragging

  eventdata.Dragging = 1;
  
  %clicked object will receive event
  [eventdata.HitObject, eventdata.HitPoint] = get_pointer_object( cb.clickedobject, ...
                                                    eventdata.Point, 1 );
  %clicked point
  eventdata.ClickedPoint = cb.clickedpoint;
  
else

  %get hit object and hit point
  [eventdata.HitObject, eventdata.HitPoint] = get_pointer_object( hObj, ...
                                                    eventdata.Point );  
  
  eventdata.Dragging = 0;
  eventdata.ClickedPoint = eventdata.HitPoint;
  
  cb.clickedobject = eventdata.HitObject;
  cb.clickedpoint = eventdata.HitPoint;
  
  setappdata( hObj, 'EventDispatch', cb);
  
end

callback = 'MyButtonDownFcn';

process_event_callbacks( eventdata.HitObject, callback, eventdata );

end
%==========================================================================
