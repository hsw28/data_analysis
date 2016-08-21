function state = tab_axes( hFig, cmd )
%TAB_AXES axes tabbing
%
%  TAB_AXES toggles axes tabbing for current figure. Pressing 't' tabs
%  between axes. Pressing 'shift-t' show current axes.
%
%  TAB_AXES TOGGLE toggles axes tabbing for current figure
%
%  TAB_AXES ON turns on axes tabbing for current figure
%
%  TAB_AXES OFF turns off axes tabbing for current figure
%
%  TAB_AXES NEXT selects next axes
%
%  TAB_AXES PREVIOUS selects previous axes
%
%  TAB_AXES CURRENT shows current axes
%
%  TAB_AXES(hFig) turns on axes tabbing for specified figure
%
%  TAB_AXES(hFig, command) runs specified command ('toggle', 'on', 'off',
%  'next', 'previous', 'current') for figure with handle hFig
%
%  state = TAB_AXES(...) returns the axes tabbing state
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


if nargin<1
  cmd = 'toggle';
  hFig = [];
elseif ischar(hFig) && nargin==1
  cmd = lower(hFig);
  hFig = [];
elseif ~isempty(hFig) && ~ishandle(hFig) && ~ismember( get(hFig, 'Type'), ...
                                                    {'figure','uipanel'})
  error('tab_axes:invalidHandle', 'Invalid figure or uipanel handle')
end

if nargin==2 && ischar(cmd) && ismember(lower(cmd), {'toggle', 'on', 'off', 'next', 'previous','current'})
  cmd = lower(cmd);
elseif nargin<2
  cmd = 'on';
end

%get current figure
if isempty(hFig)
  hFig = get(0, 'CurrentFigure');
  if isempty(hFig)
    if nargout>0
      state = 0;
    end
    return
  end
end

%get tabbing data
tab_info = getappdata(hFig, 'Tab_Axes');

state = 0;

switch cmd
 case 'toggle'
  if isempty(tab_info)
    setup_tab(hFig);
    state = 1;
  else
    clear_tab(hFig);
  end
 case 'on'
  if isempty(tab_info)
    setup_tab(hFig);
    state = 1;
  end  
 case 'off'
  if ~isempty(tab_info)
    clear_tab(hFig);
  end 
 case 'next'
  if ~isempty(tab_info)
    stop(tab_info.info_timer);
    select_axes(hFig, 1);
    start(tab_info.info_timer);
    state = 1;
  end
 case 'previous'
  if ~isempty(tab_info)
    stop(tab_info.info_timer);
    select_axes(hFig, -1);
    start(tab_info.info_timer);
    state = 1;
  end
 case 'current'
  if ~isempty(tab_info)
    stop(tab_info.info_timer);
    select_axes(hFig, 0);
    start(tab_info.info_timer);
    state = 1;
  end  
 otherwise
  error('tab_axes:invalidCommand', 'Unknown command')
end


if nargout<1
  clear state
end




function retval = tabax( hObj, eventdata )

I = getappdata( hObj, 'Tab_Axes' );

if eventdata.KeyCode == 84 %tab
  
  stop(I.info_timer);
  
  if bitand(eventdata.Modifiers, 1 ) %shift
    select_axes(hObj,0)
  else
    select_axes(hObj,1);
  end
  
  start(I.info_timer);
  
  retval = true;
else
  retval = false;
end


function select_axes( hFig, jump )

all_ax = sort( findobj( hFig, 'Type', 'axes' ) );
cur_ax = get( hFig, 'CurrentAxes');
  
if ~isempty(cur_ax)
  
  visible_ax = strcmp( get( all_ax, 'Visible' ), 'on' );
  visible_idx = find( visible_ax );
  
  if isempty(visible_idx)
    return
  end
  
  idx = find( cur_ax == all_ax(visible_idx) );
  
  if isempty(idx)
    idx = visible_idx(1);
  end
  
  idx = mod( idx -1 + jump , numel(visible_idx) ) + 1;
  idx = visible_idx( idx );
  
  
  set( all_ax, 'Selected', 'off' )
    
  set( all_ax(idx), 'Selected', 'on' )
  
  set( hFig, 'CurrentAxes', all_ax(idx) );
  set( hFig, 'CurrentObject', all_ax(idx) );  
  
end


function tab_info = setup_tab(hFig)

tab_info = struct('info_timer', [], ...
                  'listener', []);

parent = ancestor( hFig, 'figure' );

event_dispatch( parent );

add_callback( hFig, 'MyKeyPressFcn', @tabax, 'tabax' );

tab_info.info_timer =timer('TimerFcn', @(h,e) set( findobj(parent, 'Type', 'axes'), 'Selected', 'off' ), ...
                           'StartDelay', 0.5, 'ExecutionMode', 'singleShot', ...
                           'BusyMode', 'queue');

tab_info.listener = handle.listener( hFig, 'ObjectBeingDestroyed', ...
                                     @(h,e) delete(tab_info.info_timer) );

setappdata(hFig, 'Tab_Axes', tab_info );

select_axes( hFig, 0);

start( tab_info.info_timer );


function clear_tab(hFig)

remove_callback( hFig, 'MyKeyPressFcn', 'tabax' );

D = getappdata( hFig, 'Tab_Axes');
rmappdata( hFig, 'Tab_Axes');
delete(D.info_timer);
delete(D.listener);