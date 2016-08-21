function remove_callback(S, id )
%REMOVE_CALLBACK remove callback
%
%  REMOVE_CALLBACK(e) remove all callbacks
%
%  REMOVE_CALLBACK(e,id) remove callback with specified identifier
%

if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:remove_callback:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

Sappdata = getappdata(S.parent, 'Slider');

if nargin<2
  %remove all callbacks
  Sappdata.updatefcn(:) = [];
  
elseif ~ischar(id) && ~isnumeric(id)
  error('slider:remove_callback:invalidID', 'Invalid function ID');
else
  
  idx = [];
  for k=1:numel(Sappdata.updatefcn)
  
    if isequal( Sappdata.updatefcn(k).id, id )
      idx = k;
      break;
    end
    
  end
  
  Sappdata.updatefcn(idx) = [];
  
end

setappdata(S.parent, 'Slider', Sappdata);