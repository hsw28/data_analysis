function [state, props]=scroll_zoom( hAx, varargin )
%SCROLL_ZOOM adds zoom capabilities to axes
%
%  SCROLL_ZOOM toggles zooming functionality for current axes. Scrolling
%  the mouse wheel over the x-axis or y-axis zoom in/out by a factor of
%  two. Alternatively, the cursor keys can be used for zooming. Pressing
%  the page-up/page-down keys change the zoom factor by a factor of two.
%  Pressing the x or y key toggles zooming along the x-axis or y-axis.
%
%  SCROLL_ZOOM TOGGLE toggle zooming for current axes
%
%  SCROLL_ZOOM OFF turns off zooming for current axes
%
%  SCROLL_ZOOM ON turns off zooming for current axes
%
%  SCROLL_ZOOM X turns on x-axis zooming for current axes
%
%  SCROLL_ZOOM Y turns on y-axis zooming for current axes
%
%  SCROLL_ZOOM(hAx) turns on zooming for axes with handle hAx
%
%  SCROLL_ZOOM(hAx, command) runs zooming command ('toggle', 'on', 'off',
%  'x', 'y') for axes with handle hAx
%
%  SCROLL_ZOOM(hAx, parameter1, value1, ...) turns on zooming for axis
%  hAx with additional properties as specified by parameter/value
%  pairs. Valid paramters are:
%    Factor - zoom factor, should be >1 (default=2)
%    Axis - allows zooming along the specified axis. Valid values are:
%    'x', 'y', 'xy'
%    Modifier - sets a modifier key to access zooming functionality
%    (e.g. shift = 1, control = 2, no modifier = 0).
%    AxisOnly - when set to 1, restricts mouse wheel zooming to the cases
%    when the mouse pointer is over the x-axis or y-axis. When set to 0,
%    also allows zooming when mouse pointer is over axes drawing
%    area. Note that this is only practical if zooming is limited
%    to a single axis. 
%
%  [state, props]=SCROLL_ZOOM(...) returns the zooming state of an axes
%  and its zoom properties.
%
%  The zooming functionality provided by SCROLL_ZOOM depends on the extended
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
  error('scroll_zoom:invalidHandle', 'Invalid axes handle')
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
    scroll_zoom( hAx(k), varargin{:} )
  end
  return
end

if nargin==2 && ischar(varargin{1}) && ismember(lower(varargin{1}), {'toggle', 'on', 'off', 'x', 'y'})
  cmd = lower(varargin{1});
end

%get panning data
zoom_info = getappdata( hAx, 'Scroll_Zoom' );

state = 1;

%process command
switch cmd
 case 'toggle'
  if isempty(zoom_info)
    zoom_info = setup_zoom(hAx);
  else
    clear_zoom(hAx);
    state = 0;
  end
 case 'on'
  if isempty(zoom_info)
    zoom_info = setup_zoom(hAx);
  end  
 case 'off'
  if ~isempty(zoom_info)
    clear_zoom(hAx);
    state = 0;
  end
 case {'x', 'y'}
  if isempty(zoom_info)
    zoom_info = setup_zoom(hAx);
  end
  zoom_info.axis = cmd;
  setappdata( hAx, 'Scroll_Zoom', zoom_info);  
 otherwise
  if isempty(zoom_info)
    zoom_info = setup_zoom(hAx);
  end
  
  %parse parameter/value pairs
  if mod(numel(varargin),2)~=0
    error('scroll_zoom:invalidParameter', 'Odd number of parameters and values')
  end
  for p = 1:2:numel(varargin)
    switch lower(varargin{p})  
     case 'factor'
      factor = varargin{p+1};
      if ~isnumeric(factor) || ~isscalar(factor) || factor <= 1
        error('scroll_zoom:invalidParameter', 'zooming factor should be scalar >1')
      end
      zoom_info.factor=factor;
     case 'axis'
      ax = varargin{p+1};
      if (~isempty(ax) && ~ischar(ax) ) || ~all( ismember( ax, 'xyXY' ) )
        error('scroll_zoom:invalidParamater', 'Zooming axis should be ''x'', ''y'' or ''xy''')
      end
      zoom_info.axis = lower( unique( ax ) );
     case 'modifier'
      modifier = varargin{p+1};
      if ~isnumeric(modifier) || ~isscalar(modifier) || modifier<0
        error('scroll_zoom:invalidParameter', 'Modifier should be a scalar >=0')
      end
      zoom_info.modifier = modifier;      
     case 'axisonly'
      axisonly = varargin{p+1};
      if (~isnumeric(axisonly) && ~islogical(axisonly)) || ~isscalar(axisonly)
        error('scroll_zoom:invalidParameter', 'AxisOnly parameter should be a scalar')
      end
      zoom_info.axisonly = (axisonly~=0);      
     otherwise
      error('scroll_zoom:invalidParameter', 'Invalid parameter')      
    end
  end
  setappdata( hAx, 'Scroll_Zoom', zoom_info);
end

if nargout<1
  clear state
elseif nargout>1
  if state
    props.factor = zoom_info.factor;
    props.axis = zoom_info.axis;    
    props.modifier = zoom_info.modifier;
    props.axisonly = zoom_info.axisonly;
  else
    props = [];
  end
end


end


function retval = keyzoom( hObj, eventdata ) %#ok

I = getappdata( hObj, 'Scroll_Zoom' );

if (~I.modifier || bitand(I.modifier, eventdata.Modifiers) ) && ...
      ismember(eventdata.KeyCode, [33 34 37:40 88 89])
    
  retval = true;

  xl = get(hObj, 'XLim');
  yl = get(hObj, 'YLim');

  %restore info text if it doesn't exist anymore
  if ~ishandle(I.info_text)
    I.info_text = text( mean(xl), mean(yl), '', 'Parent', hObj, 'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', 'BackgroundColor', [1 1 1]);
    setappdata(hObj, 'Scroll_Zoom', I );
  end     
    
  if eventdata.KeyCode == 33 %page up
    stop(I.info_timer);
    I.factor = (I.factor-1)*2 + 1;
    set(I.info_text, 'String', ['zoom factor = ' num2str(I.factor)], 'Position', ...
                   [mean(xl) mean(yl) 0]);
    start(I.info_timer);
    setappdata( hObj, 'Scroll_Zoom', I ); 
    return
  elseif eventdata.KeyCode == 34 %pagedown
    stop(I.info_timer);
    I.factor = (I.factor-1)/2 + 1;
    set(I.info_text, 'String', ['zoom factor = ' num2str(I.factor)], 'Position', ...
                   [mean(xl) mean(yl) 0]);
    start(I.info_timer);
    setappdata( hObj, 'Scroll_Zoom', I ); 
    return
  elseif eventdata.KeyCode == 88 %x
    if ismember('x', I.axis)
      I.axis = setdiff( I.axis, 'x' );
    else
      I.axis = union('x', I.axis);
    end
    setappdata( hObj, 'Scroll_Zoom', I );    
    return    
  elseif eventdata.KeyCode == 89 %y
    if ismember('y', I.axis)
      I.axis = setdiff(I.axis, 'y');
    else
      I.axis = union( I.axis, 'y');
    end
    setappdata( hObj, 'Scroll_Zoom', I );
    return    
  end    
    
  retval = false;
  
  if ismember( 'x', I.axis)
    switch eventdata.KeyCode
     case 37 %left -> x-axis zoom out
      xl = mean(xl) + [-0.5 0.5]* diff( xl ) * I.factor;
     case 39 %right -> x-axis zoom in
      xl = mean(xl) + [-0.5 0.5]* diff( xl ) / I.factor;
    end
    set(hObj, 'XLim', xl);
    retval = true;
  end
  if ismember( 'y', I.axis)
    switch eventdata.KeyCode
     case 38 %up -> y-axis zoom in
      yl = mean(yl) + [-0.5 0.5]* diff( yl ) / I.factor;
     case 40 %down -> y-axis zoom out
      yl = mean(yl) + [-0.5 0.5]* diff( yl ) * I.factor;
    end
    set(hObj, 'Ylim', yl);      
    retval = true;
  end

  
else
  retval = false;
end

end


function retval = zoomfcn( hObj, eventdata )

I = getappdata( hObj, 'Scroll_Zoom' );

if ~I.modifier || ( bitand(I.modifier, eventdata.Modifiers) ) 
    
  retval = false;
    
  if eventdata.WheelRotation<0
    G = I.factor;
  else
    G = 1./I.factor;
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
    
  if ismember( 'x', I.axis) && ( eventdata.HitPoint(1)>= xl(1) && eventdata.HitPoint(1)<=xl(2) ) && eventdata.HitPoint(2)<=ymax
    l = (xl-eventdata.HitPoint(1)).*G + eventdata.HitPoint(1);
    xl = sort(l);
    retval = true;
  end
  if ismember( 'y', I.axis) && ( eventdata.HitPoint(2)>= yl(1) && eventdata.HitPoint(2)<=yl(2) ) && eventdata.HitPoint(1)<=xmax
    l = (yl-eventdata.HitPoint(2)).*G + eventdata.HitPoint(2);
    yl = sort(l);
    retval = true;
  end
    
  if retval
    set(hObj, 'XLim', xl, 'YLim', yl);
  end
  
else
  retval = false;
end
  
end


function retval = boxzoomfcn( hObj, eventdata )

I = getappdata( hObj, 'Scroll_Zoom' );

if (~I.modifier || ( bitand(I.modifier, eventdata.Modifiers) )) && eventdata.Button==1

  xl = get(hObj, 'XLim');
  yl = get(hObj, 'YLim');
    
  if eventdata.HitPoint(1)<xl(1) || eventdata.HitPoint(1)>xl(2) || ...
      eventdata.HitPoint(2)<yl(1) || eventdata.HitPoint(2)>yl(2)
      retval = false;
      return;
  end
  
  cp = get( ancestor(hObj, 'figure'), 'CurrentPoint' );

  zoombox = rbbox( [cp 0 0] );

  pixpos = getpixelposition( hObj );
  llc = zoombox(1:2) - pixpos(1:2);
  luc = zoombox(1:2) + zoombox(3:4) - pixpos(1:2);
  llc = [xl(1) yl(1)] + [diff(xl) diff(yl)] .* ( llc ./ pixpos(3:4) );   
  luc = [xl(1) yl(1)] + [diff(xl) diff(yl)] .* ( luc ./ pixpos(3:4) );
  
  
  if llc(1)==luc(1) || llc(2)==luc(2)
    
    if ismember('x', I.axis) 
      xl = diff(xl).*[-0.5 0.5]./I.factor + eventdata.HitPoint(1);
    end
    if ismember( 'y', I.axis)
      yl = diff(yl).*[-0.5 0.5]./I.factor + eventdata.HitPoint(2); 
    end
    
  else
    if ismember('x', I.axis) 
      xl = [llc(1) luc(1)];
    end
    if ismember('y', I.axis)
      yl = [llc(2) luc(2)];
    end
  end
  
  set( hObj, 'XLim', xl, 'YLim', yl)
    
  retval = true;
else
  retval = false;
end
  
end

function retval = zoomoutfcn( hObj, eventdata )

I = getappdata( hObj, 'Scroll_Zoom' );

if (~I.modifier || ( bitand(I.modifier, eventdata.Modifiers) ) ) && eventdata.Button==3;
  xl = get(hObj, 'XLim');
  yl = get(hObj, 'YLim');

  if ismember('x', I.axis)    
    xl = diff(xl).*I.factor.*[-0.5 0.5] + eventdata.HitPoint(1);
  end
  if ismember('y', I.axis)
    yl = diff(yl).*I.factor.*[-0.5 0.5] + eventdata.HitPoint(2);
  end

  set(hObj, 'XLim', xl, 'YLim', yl);
  
  retval = true;
else
  retval = false;
end

end




function clear_zoom(hAx)

remove_callback( hAx, 'MyWheelMovedFcn', 'zoomfcn' );
remove_callback( hAx, 'MyButtonDownFcn', 'boxzoomfcn' );
remove_callback( hAx, 'MyButtonUpFcn', 'zoomoutfcn' );
remove_callback( hAx, 'MyKeyPressFcn', 'keyzoom' );  
D = getappdata( hAx, 'Scroll_Zoom');
rmappdata( hAx, 'Scroll_Zoom' );  
delete( D.info_timer );
delete( D.listener );

end

function zoom_info = setup_zoom(hAx)

zoom_info = struct( 'factor', 2, ...
                    'axis', 'xy', ...
                    'modifier', 0, ...
                    'axisonly', 1, ...
                    'info_text', [], ...
                    'info_timer', [], ...
                    'listener', []);


event_dispatch( ancestor( hAx, 'figure' ) );
enable_events( hAx );

add_callback( hAx, 'MyWheelMovedFcn', @zoomfcn, 'zoomfcn' );
add_callback( hAx, 'MyButtonDownFcn', @boxzoomfcn, 'boxzoomfcn' );
add_callback( hAx, 'MyButtonUpFcn', @zoomoutfcn, 'zoomoutfcn' );
add_callback( hAx, 'MyKeyPressFcn', @keyzoom, 'keyzoom' );

zoom_info.info_text = text( mean(xlim(hAx)), mean(ylim(hAx)), '', 'Parent', hAx, 'HorizontalAlignment', 'center', ...
                  'VerticalAlignment', 'middle', 'BackgroundColor', [1 1 1]);

zoom_info.info_timer = timer('TimerFcn', {@dim_zoom_infotext, hAx}, ...
                   'StartDelay', 1, 'ExecutionMode', 'singleShot');

zoom_info.listener = handle.listener( hAx, 'ObjectBeingDestroyed', ...
                                      @(h,e) delete(zoom_info.info_timer) );

setappdata( hAx, 'Scroll_Zoom', zoom_info);

end

function dim_zoom_infotext( hObj, eventdata, hAx ) %#ok

I = getappdata(hAx, 'Scroll_Zoom');
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