function id = add_callback(S, fcn, id)
%ADD_CALLBACK add callback to slicer
%
%  id=ADD_CALLBACK(slicer,fcn) adds the callback fcn to the slicer. Whenever
%  the slicer changes, the callback is executed. Returns the callback id.
%
%  id=ADD_CALLBACK(slicer,fcn,id) specifies a custom callback identifier, or
%  when a callback with that id already exists, it will be replaced.
%
%


if nargin<2
  return
end

if ~isvalidcallback(fcn)
  error('slicerui:add_callback:invalidFunction', 'Invalid function')
end

h = S.hash;
A = h.get('slicer');

if nargin<3 || isempty(id)
  
  idx = cellfun( 'isclass', {A.callbacks.id}, 'double' ) & cellfun( ...
      'prodofsize', {A.callbacks.id})==1;
  id = max( [A.callbacks(idx).id] ) + 1;
  if isempty(id)
    id = 1;
  end
  
elseif ~ischar(id) && ~isnumeric(id)
  error('slicerui:add_callback:invalidID', 'Invalid function ID');
end

idx = numel(A.callbacks)+1;
for k=1:numel(A.callbacks)
  
  if isequal( A.callbacks(k).id, id )
    idx = k;
    break;
  end
  
end

A.callbacks(idx) = struct('id', id, 'fcn', {fcn} );

h.put('slicer', A);