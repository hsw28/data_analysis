function remove_callback(S, id )
%REMOVE_CALLBACK remove callback
%
%  REMOVE_CALLBACK(e) remove all callbacks
%
%  REMOVE_CALLBACK(e,id) remove callback with specified identifier
%

h = S.hash;
A = h.get('slicer');

if nargin<2
  %remove all callbacks
  A.callbacks = struct('id', {}, 'fcn', {});
  
elseif ~ischar(id) && ~isnumeric(id)

  error('slicerui:remove_callback:invalidID', 'Invalid function ID');
  
else
  
  idx = [];
  for k=1:numel(A.callbacks)
  
    if isequal( A.callbacks(k).id, id )
      idx = k;
      break;
    end
    
  end
  
  A.callbacks(idx) = [];
  
end

h.put('slicer', A);