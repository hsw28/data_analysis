function enable_events( h )
%ENABLE_EVENTS enable events for graphical objects
%
%  ENABLE_EVENTS(h) enable event handling by graphical objects with
%  handles h.
%

if nargin<1
  help(mfilename)
  return
end

if any( ~ishandle(h) )
  error('enable_events:invalidHandle', 'Invalid handles')
end

for k=1:numel(h)
  
  tp = get( h(k), 'Type' );
  
  if strcmp(tp, 'figure')
    
    event_dispatch( h(k) );
    
  elseif strcmp(tp, 'axes')
    
    addprops( h(k) )
    addprops( get(h(k), 'title') );
    addprops( get(h(k), 'xlabel') );        
    addprops( get(h(k), 'zlabel') );
    addprops( get(h(k), 'ylabel') ); 
    
  else
    
    addprops(h(k))
    
  end
  
end
    


function addprops( h ) %#ok

%define valid event callbacks
props = {'MyButtonDownFcn', 'MyButtonUpFcn', 'MyKeyPressFcn', ...
         'MyKeyReleaseFcn', 'MyDragFcn', 'MyWheelMovedFcn', 'MyStartDragFcn', ...
         'MyStopDragFcn'};

%add callback properties to object
for k=1:numel(props)
  if isempty( findprop( handle( h ), props{k} ) )
    schema.prop( h, props{k}, 'mxArray' );
  end
end    
