function n = remove_callback( hObj, callback_name, callback_id )
%REMOVE_CALLBACK removes callbacks from object
%
%  REMOVE_CALLBACK(hObj, callback_name) removes all callback functions
%  from the object with handle hObj.
%
%  REMOVE_CALLBACK(hObj, callback_name, callback_id) removes all callback
%  functions with the specified callback ID from the object with handle hObj.
%
%  n=REMOVE_CALLBACK(...) returns the number of callback functions removed
%
%  Example
%    hFig = figure;
%    event_dispatch( hFig );
%    fcn = @(hObj, eventdata) fprintf( 'Wheel moved\n' );
%    fcn_id = add_callback( hFig, 'MyWheelMovedFcn', fcn );
%    remove_callback( hFig, 'MyWheelMoved', fcn_id );
%
%  See also EVENT_DISPATCH, ADD_CALLBACK
%

%check input arguments
if nargin<2
    help(mfilename)
    return
end

%check object handles
if ~all( ishandle( hObj ) )
  error( 'remove_callback:invalidHandle', 'Invalid object handle(s)')
end

%check callback name
if ~ismember( callback_name, {'MyButtonDownFcn', 'MyButtonUpFcn', 'MyKeyPressFcn', ...
                      'MyKeyReleaseFcn', 'MyDragFcn', 'MyWheelMovedFcn', 'MyStartDragFcn', ...
                      'MyStopDragFcn', 'MyDropFcn', 'MyEntryFcn', 'MyExitFcn', ...
                      'MyMoveFcn', 'MyDragEnterFcn', 'MyDragExitFcn'} )
  error( 'remove_callback:invalidCallback', 'Invalid callback name' )
end


if nargin<3
  %remove all callback function
  if nargout>0
    cb = get( hObj, callback_name );
    if ~ischar(cb) && isempty(cb)
      n=0;
    elseif ~isempty(cb) && isstruct(cb) && ...
          all( ismember( {'callback', 'id'}, fieldnames(cb) ) )
      n = numel(cb);
    else
      n=1;
    end
  end
  
  set(hObj, callback_name, []);
  
  return
end

n = 0;

if isprop( hObj, callback_name )
  
  %get callback functions
  cb = get( hObj, callback_name );
  
  if ~isempty(cb) && isstruct(cb) && all( ismember( {'callback', 'id'}, ...
                                                    fieldnames(cb) ) )
    
    n = numel(cb);
    
    for k=n:-1:1
      if isequal( cb(k).id , callback_id )
        cb(k) = [];
      end
    end

    n = n - numel(cb);
    
    %save remaining callbacks
    set( hObj, callback_name, cb );    
    
  end

  
end

if nargout<1
  clear n;
end
