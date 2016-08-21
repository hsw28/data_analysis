function suspend_callback(S, val)
 
if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:suspend_callback:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

Sappdata = getappdata(S.parent, 'Slider');

if nargin<2
  Sappdata.suspend_callback = ~Sappdata.suspend_callback;
else
  Sappdata.suspend_callback = isequal(val, 1);
end

setappdata(S.parent, 'Slider', Sappdata);