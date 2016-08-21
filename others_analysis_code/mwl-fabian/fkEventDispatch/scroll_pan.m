function [state, props] = scroll_pan( hAx, varargin)
%SCROLL_PAN adds panning capabilities to axes
%
%  SCROLL_PAN toggles panning functionality for current axes. Scrolling the
%  mouse wheel over the x-axis or y-axis pans that axis by 50% of its
%  extent. Alternatively, the cursor keys can be used for
%  panning. Pressing the page-up or page-down key changes the panning
%  fraction by a factor 2. Pressing the x or y key toggles panning along
%  the x-axis or y-axis.
%
%  SCROLL_PAN TOGGLE toggles panning functionality for current axes.
%
%  SCROLL_PAN OFF turns off panning for current axes
%
%  SCROLL_PAN ON turns on panning for current axes
%
%  SCROLL_PAN X turns on x-axis panning for current axis
%
%  SCROLL_PAN Y turns on y-axis panning for curren axis
%
%  SCROLL_PAN(hAx) turns on panning functionality for axes with handle hAx
%
%  SCROLL_PAN(hAx, command) runs panning command ('toggle', 'on', 'off',
%  'x', 'y') for axes with handle hAx
%
%  SCROLL_PAN(hAx, parameter1, value1, ...) turns on panning for axis hAx
%  with additional properties as specified by parameter/value
%  pairs. Valid parameters are:
%    Fraction - panning fraction, which determines the size of a panning
%    step as a fraction of the current axis limits. The fraction should
%    be >0 (default = 0.5).
%    Axis - allows panning along the specified axis. Valid values are:
%    'x', 'y', 'xy'.
%    Modifier - sets a modifier key to access panning functionality
%    (e.g. shift = 1, control = 2, no modifier = 0).
%    AxisOnly - when set to 1, restricts mouse wheel panning to the cases
%    when the mouse pointer is over the x-axis or y-axis. When set to 0,
%    also allows panning when mouse pointer is over axes drawing
%    area. Note that this is only practical if panning is limited
%    to a single axis. 
%
%  [state, props]=SCROLL_PAN(...) returns the panning state of an axes
%  and its panning properties.
%
%  The panning functionality provided by SCROLL_PAN depends on the extended
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

if nargin<1
  cmd = 'toggle';
  hAx = [];
elseif ischar(hAx) && nargin==1
  cmd = lower(hAx);
  hAx = [];
elseif ~isempty(hAx) && ~all(ishandle(hAx(:))) && ~all( strcmp( get(hAx(:),'Type'), 'axes' ) )
  error('scroll_pan:invalidHandle', 'Invalid axes handle')
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
    scroll_pan( hAx(k), varargin{:} )
  end
  return
end

if nargin==2 && ischar(varargin{1}) && ismember(lower(varargin{1}), {'toggle', 'on', 'off', 'x', 'y'})
  cmd = lower(varargin{1});
end


%get panning data
pan_info = getappdata( hAx, 'Scroll_Pan' );

state = 1;

%process command
switch cmd
 case 'toggle'
  if isempty(pan_info)
    pan_info = setup_pan(hAx);
  else
    clear_pan(hAx);
    state = 0;
  end
 case 'on'
  if isempty(pan_info)
    pan_info = setup_pan(hAx);
  end
 case 'off'
  if ~isempty(pan_info)
    clear_pan(hAx);
    state = 0;
  end
 case {'x', 'y'}
  if isempty(pan_info)
    pan_info = setup_pan(hAx);
  end
  pan_info.axis = cmd;
  setappdata( hAx, 'Scroll_Pan', pan_info);
 otherwise
  if isempty(pan_info)
    pan_info = setup_pan(hAx);
  end
  
  %parse parameter/value pairs
  if mod(numel(varargin),2)~=0
    error('scroll_pan:invalidParameter', 'Odd number of parameters and values')
  end
  for p = 1:2:numel(varargin)
    switch lower(varargin{p})
     case 'fraction'
      fraction = varargin{p+1};
      if ~isnumeric(fraction) || ~isscalar(fraction) || fraction <= 0
        error('scroll_pan:invalidParameter', 'Panning fraction should be scalar >0')
      end
      pan_info.fraction = fraction;
     case 'axis'
      ax = varargin{p+1};
      if (~isempty(ax) && ~ischar(ax) ) || ~all( ismember( ax, 'xyXY' ) )
        error('scroll_pan:invalidParamater', 'Panning axis should be ''x'', ''y'' or ''xy''')
      end
      pan_info.axis = lower( unique( ax ) );
     case 'modifier'
      modifier = varargin{p+1};
      if ~isnumeric(modifier) || ~isscalar(modifier) || modifier<0
        error('scroll_pan:invalidParameter', 'Modifier should be a scalar >=0')
      end
      pan_info.modifier = modifier;
     case 'axisonly'
      axisonly = varargin{p+1};
      if (~isnumeric(axisonly) && ~islogical(axisonly)) || ~isscalar(axisonly)
        error('scroll_pan:invalidParameter', 'AxisOnly parameter should be a scalar')
      end
      pan_info.axisonly = (axisonly~=0);
     otherwise
      error('scroll_pan:invalidParameter', 'Invalid parameter')
    end
  end
  setappdata( hAx, 'Scroll_Pan', pan_info);
end

if nargout<1
  clear state
elseif nargout>1
  if state
    props.fraction = pan_info.fraction;
    props.axis = pan_info.axis;    
    props.modifier = pan_info.modifier;
    props.axisonly = pan_info.axisonly;
  else
    props = [];
  end
end


end


function retval = panfcn( hObj, eventdata )

I = getappdata( hObj, 'Scroll_Pan' );

if ~I.modifier || ( bitand(I.modifier, eventdata.Modifiers) ) 
  
  retval = false;    
  
  if eventdata.WheelRotation<0
    G = I.fraction;
  else
    G = -I.fraction;
  end
  
    xl = get(hObj, 'XLim');
    yl = get(hObj, 'YLim');
    
    if I.axisonly
      xmax = xl(1);
      ymax = yl(1);
    else
      xmax = xl(2);
      ymax = yl(2);
    end
    
    if ismember( 'x', I.axis) && ( eventdata.HitPoint(1)>= xl(1) && ...
                               eventdata.HitPoint(1)<=xl(2) ) && eventdata.HitPoint(2)<=ymax
      xl = xl + diff(xl)*G;
      set(hObj, 'XLim', xl);
      retval = true;
    end
    if ismember( 'y', I.axis) && ( eventdata.HitPoint(2)>= yl(1) && ...
                               eventdata.HitPoint(2)<=yl(2) ) && eventdata.HitPoint(1)<=xmax
      yl = yl + diff(yl)*G;
      set(hObj, 'YLim', yl);
      retval = true;
    end
    
else
  retval = false;
end

end

function retval = keypanfcn( hObj, eventdata )

I = getappdata( hObj, 'Scroll_Pan' );

if (~I.modifier || bitand(I.modifier, eventdata.Modifiers) ) && ...
      ismember(eventdata.KeyCode, [33 34 37:40 88 89])
  
  retval = true;
  
  xl = get(hObj, 'XLim');
  yl = get(hObj, 'YLim');

  %restore info text if it doesn't exist anymore
  if ~ishandle(I.info_text)
    I.info_text = text( mean(xl), mean(yl), '', 'Parent', hObj, 'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', 'BackgroundColor', [1 1 1]);
    setappdata(hObj, 'Scroll_Pan', I );
  end  
  
  if eventdata.KeyCode == 33 %page up
    stop(I.info_timer);
    I.fraction = I.fraction * 2;
    set(I.info_text, 'String', ['pan fraction = ' num2str(I.fraction)], ...
                   'Position', [mean(xl) mean(yl) 0] );
    start(I.info_timer);
    setappdata( hObj, 'Scroll_Pan', I );
    return
  elseif eventdata.KeyCode == 34 %pagedown
    stop(I.info_timer);
    I.fraction = I.fraction / 2;
    set(I.info_text, 'String', ['pan fraction = ' num2str(I.fraction)], ...
                   'Position', [mean(xl) mean(yl) 0] );
    start(I.info_timer);
    setappdata( hObj, 'Scroll_Pan', I );
    return
  elseif eventdata.KeyCode == 88 %x
    if ismember('x', I.axis)
      I.axis = setdiff( I.axis, 'x' );
    else
      I.axis = union('x', I.axis);
    end
    setappdata( hObj, 'Scroll_Pan', I );    
    return
  elseif eventdata.KeyCode == 89 %y
    if ismember('y', I.axis)
      I.axis = setdiff(I.axis, 'y');
    else
      I.axis = union( I.axis, 'y');
    end
    setappdata( hObj, 'Scroll_Pan', I );
    return
  end
  
  retval = false;
  
  if ismember( 'x', I.axis)
    switch eventdata.KeyCode
     case 37 %left -> x-axis pan left
      xl = xl - diff(xl).*I.fraction;
     case 39 %right -> x-axis pan right
      xl = xl + diff(xl).*I.fraction;
    end
    set(hObj, 'XLim', xl);
    retval = true;
  end
  if ismember( 'y', I.axis )
    switch eventdata.KeyCode
     case 38 %up -> y-axis pan up
      yl = yl + diff(yl).*I.fraction;
     case 40 %down -> y-axis pan down
      yl = yl - diff(yl).*I.fraction;
    end
    set(hObj, 'Ylim', yl);      
    retval = true;
  end    
  
else
  
  retval = false;
  
end

end




function clear_pan(hAx)

try
  remove_callback( hAx, 'MyWheelMovedFcn', 'panfcn' );
  remove_callback( hAx, 'MyKeyPressFcn', 'keypanfcn' );
  D = getappdata( hAx, 'Scroll_Pan');
  rmappdata( hAx, 'Scroll_Pan' );
  delete( D.info_timer );
  delete( D.listener );
catch
end

end

function pan_info = setup_pan(hAx)

pan_info = struct( 'fraction', 0.5, ...
                   'axis', 'xy', ...
                   'modifier', 0, ...
                   'axisonly', 1, ...
                   'info_text', [], ...
                   'info_timer', [], ...
                   'listener', []);

event_dispatch( ancestor( hAx, 'figure' ) );
enable_events( hAx );

add_callback( hAx, 'MyWheelMovedFcn', @panfcn, 'panfcn' );
add_callback( hAx, 'MyKeyPressFcn', @keypanfcn, 'keypanfcn' );
pan_info.info_text = text( mean(xlim(hAx)), mean(ylim(hAx)), '', 'Parent', hAx, 'HorizontalAlignment', 'center', ...
                           'VerticalAlignment', 'middle', 'BackgroundColor', [1 1 1]);

pan_info.info_timer = timer('TimerFcn', {@dim_pan_infotext, hAx}, ...
                            'StartDelay', 1, 'ExecutionMode', ...
                            'singleShot');

pan_info.listener = handle.listener( hAx, 'ObjectBeingDestroyed', ...
                                     @(h,e) delete(pan_info.info_timer) );

setappdata( hAx, 'Scroll_Pan', pan_info );

end
  

function dim_pan_infotext( hObj, eventdata, hAx ) %#ok

I = getappdata(hAx, 'Scroll_Pan');
set( I.info_text, 'String', '' );

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