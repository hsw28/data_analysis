function val=get(L,prop)
%GET get layoutmanager property
%
%  val=GET(L) returns a structure with all properties
%
%  val=GET(L,prop) returns the value of the requested property.
%

if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  error('layoutmanager:get:invalidHandle', ['Parent does not exist or has ' ...
                      'no layout manager'])
end


Lappdata = getappdata(L.parent, 'LayoutManager');

if nargin<2
  val = Lappdata;
  val.parent = L.parent;
else
  if strcmp(prop, 'parent')
    val = L.parent;
  else
    val = Lappdata.(prop);
  end
end
  