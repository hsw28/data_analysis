function L=set(L,varargin)
%SET set layout manager object properties
%
%  l=SET(l,parm1,val1,...) set object properties. Valid properties are:
%  xoffset, xspacing, yoffset, yspacing, width, height
%

if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  error('layoutmanager:set:invalidHandle', ['Parent does not exist or has ' ...
                      'no layout manager'])
end

valid_parms = {'xoffset', 'xspacing', 'yoffset', 'yspacing', 'width', 'height'};

Lappdata = getappdata(L.parent, 'LayoutManager');

Lappdata = validate_parms(Lappdata, valid_parms, varargin{:});



setappdata(L.parent, 'LayoutManager', Lappdata);

resizefcn( L.parent, []);