function callback_id = add_callback( hObj, callback_name, callback_fcn, callback_id)
%ADD_CALLBACK add callbacks to object
%
%  ADD_CALLBACK(hObj, callback_name, fcn) adds the specified callback
%  function to the object with handle hObj. The callback function can
%  be one of: 1. string to be evaluated, 2. function handle, 3. cell
%  array with first cell function handle or function name and remaining
%  cells extra arguments.
%
%  id=ADD_CALLBACK(hObj, callback_name, fcn) returns the callback
%  function IDassigned to the callback function. This ID can be used with
%  REMOVE_CALLBACK to remove the callback function from the list. 
%
%  id=ADD_CALLBACK(hObj, callback_name, fcn, id) specifies a
%  custom callback function ID.
%
%  Example
%    hFig = figure;
%    event_dispatch( hFig );
%    fcn = @(hObj, eventdata) fprintf( 'Wheel moved\n' );
%    add_callback( hFig, 'MyWheelMovedFcn', fcn );
%
%  See also EVENT_DISPATCH REMOVE_CALLBACK
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



%check input arguments
if nargin<2 || isempty(hObj) || isempty(callback_name)
  return
end

%check object handles
if ~isscalar(hObj) && ~ishandle( hObj )
  error( 'add_callback:invalidHandle', 'Invalid object handle(s)')
end

%check callback name
if ~ismember( callback_name, {'MyButtonDownFcn', 'MyButtonUpFcn', 'MyKeyPressFcn', ...
                      'MyKeyReleaseFcn', 'MyDragFcn', 'MyWheelMovedFcn', 'MyStartDragFcn', ...
                      'MyStopDragFcn'} )
  error( 'add_callback:invalidCallback', 'Invalid callback name' )
end

if nargin<3
  %nothing to add
  if nargout>0
    callback_id = [];
  end
  return
end

if nargin<4
  callback_id = [];
end

%convert callback
if ~isvalidcallback( callback_fcn )
  error( 'add_callback:invalidCallback', 'Invalid callback function')
end

%add callback if this object has a slot for it
if isprop( hObj, callback_name )
    
  old_callback = get( hObj, callback_name );
    
  if isstruct( old_callback ) && all( ismember( {'callback', 'id'}, fieldnames( ...
      old_callback ) ) )

    if isempty(callback_id)
      idx = cellfun( 'isclass', {old_callback.id}, 'double' ) & cellfun( ...
          'prodofsize', {old_callback.id})==1;
      callback_id = max( [old_callback(idx).id] ) + 1;
      if isempty(callback_id)
        callback_id = 1;
      end
    end
      
    call_index = numel( old_callback )+1;
    old_callback(call_index).callback = callback_fcn;
    old_callback(call_index).id = callback_id;

    set(hObj, callback_name, old_callback );
  
  else

    if isempty(old_callback)
      if isempty(callback_id), callback_id = 1; end
      old_callback = struct('callback', {callback_fcn}, 'id', callback_id);
    elseif ~isvalidcallback( old_callback )
      warning('add_callback:invalidCallback', ['Found invalid callback - ' ...
                          'removed'])
      if isempty(callback_id), callback_id = 1; end
      old_callback = struct('callback', {callback_fcn}, 'id', callback_id);
    else
      old_callback = struct('callback', old_callback, 'id', 1 );
      if isempty(callback_id), callback_id = 2; end
      old_callback(end+1) = struct('callback', {callback_fcn}, 'id', callback_id);
    end

    set(hObj, callback_name, old_callback);
    
  end

end

if nargout<1
  clear callback_id;
end