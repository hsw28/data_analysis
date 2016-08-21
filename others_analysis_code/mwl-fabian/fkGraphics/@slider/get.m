function val = get(S, prop)
%GET get slider properties
%
%  val=GET(slider) get a structure with all slider properties.
%
%  val=GET(slider,prop) get specified slider property.
%

if ~ishandle(S.parent) || ~isappdata(S.parent, 'Slider')
  error('slider:get:invalidHandle', ['Parent does not exist or has ' ...
                      'no slider'])
end

Sappdata = getappdata(S.parent, 'Slider');

if nargin<2
  val = Sappdata;
  val.parent = S.parent;
else
  if strcmp(prop, 'parent')
    val = S.parent;
  else
    val = Sappdata.(prop);
  end
end