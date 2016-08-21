function id = add_callback(S, fcn, id )
%ADD_CALLBACK add callback to slider
%
%  id=ADD_CALLBACK(slider,fcn) adds the callback fcn to the slider. Whenever
%  the slider changes, the callback is executed. Returns the callback id.
%
%  id=ADD_CALLBACK(slider,fcn,id) specifies a custom callback identifier, or
%  when a callback with that id already exists, it will be replaced.
%
%

if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:add_callback:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

if nargin<2
  return
end

if ~isvalidcallback(fcn)
  error('slider:add_callback:invalidFunction', 'Invalid function')
end

Sappdata = getappdata(S.parent, 'Slider');

if nargin<3 || isempty(id)
  
  idx = cellfun( 'isclass', {Sappdata.updatefcn.id}, 'double' ) & cellfun( ...
      'prodofsize', {Sappdata.updatefcn.id})==1;
  id = max( [Sappdata.updatefcn(idx).id] ) + 1;
  if isempty(id)
    id = 1;
  end
  
elseif ~ischar(id) && ~isnumeric(id)
  error('slider:add_callback:invalidID', 'Invalid function ID');
end

idx = numel(Sappdata.updatefcn)+1;
for k=1:numel(Sappdata.updatefcn)
  
  if isequal( Sappdata.updatefcn(k).id, id )
    idx = k;
    break;
  end
  
end

Sappdata.updatefcn(idx) = struct('id', id, 'fcn', {fcn});

setappdata(S.parent, 'Slider', Sappdata);