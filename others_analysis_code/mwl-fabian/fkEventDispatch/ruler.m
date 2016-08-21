function [state, props] = ruler( hAx, varargin )
%RULER add ruler capabilities to axes
%
%  RULER toggles ruler functionality for current axes. Dragging the
%  left mouse button will display the ruler and its basic measures
%  (i.e. delta x, delta y, length and slope). Pressing the shift-key while
%  dragging, restricts the ruler to a vertical line. Pressing the
%  control-key while dragging restricts the ruler to a horizontal line.
%
%  RULER TOGGLE toggles ruler for current axes
%
%  RULER ON turns on ruler for current axes
%
%  RULER OFF turns off ruler for current axis
%
%  RULER(hAx) turn on ruler for the axes with handle hAx.
%
%  RULER(hAx, command) runs ruler command ('toggle', 'on', 'off) for axes
%  with handle hAx
%
%  RULER(hAx, parameter1, value1, ...) turns on ruler for axis hAx with
%  additional properties as specified by parameter/value pairs. Valid
%  parameters are:
%    Button - mouse button used to access ruler (left = 1, middle = 2,
%    right = 3)
%    TextProps - cell array of parameter/value pairs that customize the
%    text display
%    LineProps - cell array of parameter/value pairs that customize ruler
%    line display
%
%  [state, props]=RULER(...) returns the ruler state of an axes and the
%  ruler properties
%
%  The ruler functionality provided by RULER depends on the extended
%  event dispatching framework. The parent figure of the axes will be set
%  up for this by a call to EVENT_DISPATCH.
%
%  See also EVENT_DISPATCH
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


cmd = '';

%check first argument
if nargin<1
  cmd = 'toggle';
  hAx = [];
elseif ischar(hAx) && nargin==1
  cmd = lower(hAx);
  hAx = [];
elseif ~isempty(hAx) && ~all(ishandle(hAx(:))) && ~all( strcmp( get(hAx(:),'Type'), 'axes' ) )
  error('ruler:invalidHandle', 'Invalid axes handle')
end

%get axes
if isempty(hAx)
  hAx = localGCA();
  if isempty(hAx)
    if nargout>0
      state = 0;
    end
    if nargout>1
      props = [];
    end
    return
  end
end

%for multiple axes recurse
if numel(hAx)>1
  for k=1:numel(hAx)
    ruler( hAx(k), varargin{:} )
  end
  return
end

%check second argument
if nargin==2 && ischar(varargin{1}) && ismember(lower(varargin{1}), {'toggle', 'on', 'off'})
  cmd = lower(varargin{1});
end
  
%get ruler data
ruler_info = getappdata( hAx, 'Ruler' );

state = 1;


%process command
switch cmd
 case 'toggle'
  if isempty(ruler_info)
    ruler_info = setup_ruler(hAx);
  else
    clear_ruler(hAx);
    state = 0;
  end
 case 'on'
  if isempty(ruler_info)
    ruler_info = setup_ruler(hAx);
  end
 case 'off'
  if ~isempty(ruler_info)
    clear_ruler(hAx);
    state = 0;
  end
 otherwise
  if isempty(ruler_info)
    ruler_info = setup_ruler(hAx);
  end

  %parse parameter/value pairs
  if mod(numel(varargin),2)~=0
    error('ruler:invalidParameter', 'Odd number of parameters and values')
  end
  for p=1:2:numel(varargin)
    switch lower(varargin{p})
     case 'button'
      btn = varargin{p+1};
      if ~isnumeric(btn) || ~isscalar(btn) || btn<1 || btn>3
        error('ruler:invalidParameter', 'Button should be 1,2 or 3')
      end
      ruler_info.button = btn;
     case 'textprops'
      textprops = varargin{p+1};
      if ~iscell(textprops)
        error('ruler:invalidParameter', ['Text properties should be a cell array ' ...
                      'of propery name/value pairs'] )
      end
      ruler_info.textprops = textprops;
     case 'lineprops'
      lineprops = varargin{p+1};
      if ~iscell(lineprops)
        error('ruler:invalidParameter', ['Line properties should be a cell array ' ...
                      'of propery name/value pairs'] )
      end
      ruler_info.lineprops = lineprops;
     otherwise
      error('ruler:invalidParameter', 'Invalid parameter')
    end
  end
  setappdata(hAx, 'Ruler', ruler_info);
end

if nargout<1
  clear state
elseif nargout>1
  if state
    props.button = ruler_info.button;
    props.textprops = ruler_info.textprops;
    props.lineprops = ruler_info.lineprops;    
  else
    props = [];
  end
end

end


function retval = ruler_startdrag( hObj, eventdata )
%RULER_STARTDRAG start drag callback

I = getappdata( hObj, 'Ruler' );

%dragging with correct mouse button?
if ismember(  I.button, eventdata.Button )
  
  retval = true; %event is processed
  
  %create ruler measurement text
  txt = { sprintf('    dx: %f    ',0) ; sprintf('    dy: %f    ',0) ; sprintf('    slope: %f    ', Inf ) ; sprintf('    L: %f    ', 0) };
  I.info_text = text( eventdata.ClickedPoint(1), eventdata.ClickedPoint(2), txt, 'BackgroundColor', ...
                    'none', 'VerticalAlignment', 'Middle', 'HitTest', 'off', 'Color', ...
                    [1 0.5 0.5], I.textprops{:});
  %create ruler
  I.info_line = line( [1 1].*eventdata.ClickedPoint(1), [1 1].*eventdata.ClickedPoint(2), 'Parent', ...
                    hObj, 'Marker', '.', 'LineStyle', '- -', 'HitTest', 'off', 'Color', ...
                    [1 0 0], I.lineprops{:});
  
  setappdata( hObj, 'Ruler',I );
  
  %add callbacks
  add_callback( hObj, 'MyDragFcn', @ruler_drag, 'ruler_drag' );
  add_callback( hObj, 'MyStopDragFcn', @ruler_stopdrag, 'ruler_stopdrag');
  
else
  retval = false; %event was not processed
end

end

function retval = ruler_drag( hObj, eventdata ) %#ok
%RULER_DRAG drag callback

I = getappdata( hObj, 'Ruler');

%dragging with correct mouse button?  
if any( I.button==eventdata.ActiveButtons )
  
  retval = true; %event is processed 
  
  %get coordinates of ruler
  xd = get(I.info_line, 'XData');
  yd = get(I.info_line, 'YData');
  
  %check if shift or control is pressed to restrict ruler to vertical
  %or horizontal line
  if bitand(eventdata.Modifiers, 1)
    new_xd = [xd(1) xd(1)];
    new_yd = [yd(1) eventdata.HitPoint(2)];
  elseif bitand(eventdata.Modifiers,2)
    new_xd = [xd(1) eventdata.HitPoint(1)];
    new_yd = [yd(1) yd(1)];
  else
    new_xd = [xd(1) eventdata.HitPoint(1)];
    new_yd = [yd(1) eventdata.HitPoint(2)];
  end
  
  %calculate ruler measures
  dx = diff(new_xd);
  dy = diff(new_yd);
  
  %calculate slope of line
  if dx==0
    slope = Inf;
  else
    slope = dy./dx;
  end
  
  %calculate length of line
  L = sqrt(dy.^2 + dx.^2);
  
  %create text to display
  %txt = { sprintf('    dx: %f    ',dx) ; sprintf('    dy: %f    ',dy) ; sprintf('    slope: %f    ', slope ) ; sprintf('    L: %f    ', L) };
  txt = sprintf('    dx: %f    \n    dy: %f    \n    slope: %f    \n    L: %f    ',dx,dy,slope,L);
  
  %determine proper alignment of text
  if dx>0
    a = 'Left';
  else
    a = 'Right';
  end
  
  %set end point of ruler to current cursor location
  set( I.info_line, 'XData', new_xd, 'YData', new_yd);
  
  %display text
  set( I.info_text, 'Position', [new_xd(2) new_yd(2)], 'String', txt, ...
                    'HorizontalAlignment', a );
else
  retval = false; %event was not processed
end

end


function retval = ruler_stopdrag(hObj, eventdata)
%RULER_STOPDRAG stop drag callback

I = getappdata( hObj, 'Ruler');

%correct mouse button?
if ismember( I.button, eventdata.Button )
  
  retval = true; %event is processed
  
  %remove ruler and text
  if ishandle(I.info_line)
    delete(I.info_line);
    I.info_line = [];
  end
  if ishandle(I.info_text)
    delete(I.info_text);
    I.info_text = [];
  end
  
  setappdata( hObj, 'Ruler', I);
  
  %remove callbacks
  remove_callback( hObj, 'MyStopDragFcn', 'ruler_stopdrag' );
  remove_callback( hObj, 'MyDragFcn', 'ruler_drag');
  
else
  retval=false; %event was not processed
end

end


function clear_ruler( hAx )
%CLEAR_RULER remove ruler from axes

try
  remove_callback( hAx, 'MyStartDragFcn', 'ruler_startdrag' );  
  rmappdata( hAx, 'Ruler');
catch
end  
  
end


function ruler_info = setup_ruler( hAx )

ruler_info = struct( 'button', 1, ...
                     'textprops', {{}}, ...
                     'lineprops', {{}}, ...
                     'info_text', [], ...
                     'info_line', [] );

event_dispatch( ancestor( hAx, 'figure') );
enable_events( hAx );

%add callbacks
add_callback( hAx, 'MyStartDragFcn', @ruler_startdrag, 'ruler_startdrag' );

setappdata( hAx, 'Ruler', ruler_info);

end

function hAx = localGCA()
%LOCALGCA get current axes, but do not create one

hAx = [];

hFig = get(0, 'CurrentFigure');
if isempty(hFig)
  return %no figure
end
hAx = get(hFig, 'CurrentAxes');
if isempty(hAx)
  return %no axes found in current figure
end

end  