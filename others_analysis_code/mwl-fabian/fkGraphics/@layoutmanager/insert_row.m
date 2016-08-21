function insert_row(L, idx)
%INSERT_ROW inserts a row
%
%  INSERT_ROW(L,index) inserts a row after index.
%


if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  error('layoutmanager:insert_row:invalidHandle', ['Parent does not exist or has ' ...
                      'no layout manager'])
end

Lappdata = getappdata(L.parent, 'LayoutManager');

[nrows, ncols, nz] = size( Lappdata.childmatrix );

if ~isnumeric(idx) || ~isscalar(idx) || idx<0 || idx>(nrows)
  error('layoutmanager:insert_row:invalidInput', ['Invalid insertion ' ...
                      'index'])
end

h = NaN(1, ncols, nz);

for c = 1:ncols
  for level = 1:nz
    h(c,1, level) = Lappdata.fcn( Lappdata.argin{:}, 'Parent', L.parent );
  end
end

Lappdata.childmatrix = interlace( Lappdata.childmatrix, h, idx, 1);
Lappdata.height = interlace(Lappdata.height, 1, idx, 1);

setappdata(L.parent, 'LayoutManager', Lappdata);

resizefcn(L.parent, []);