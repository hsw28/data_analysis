function insert_column(L, idx)
%INSERT_COLUMN inserts column
%
%  INSERT_COLUMN(L,idx) inserts column at given index
%


if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  error('layoutmanager:insert_column:invalidHandle', ['Parent does not exist or has ' ...
                      'no layout manager'])
end

Lappdata = getappdata(L.parent, 'LayoutManager');

[nrows, ncols, nz] = size( Lappdata.childmatrix );

if ~isnumeric(idx) || ~isscalar(idx) || idx<0 || idx>(ncols)
  error('layoutmanager:insert_column:invalidInput', ['Invalid insertion ' ...
                      'index'])
end

h = NaN(nrows,1, nz);

for r = 1:nrows
  for level = 1:nz
    h(r, 1, level) = Lappdata.fcn( Lappdata.argin{:}, 'Parent', L.parent );
  end
end

Lappdata.childmatrix = interlace( Lappdata.childmatrix, h, idx, 2);
Lappdata.width = interlace(Lappdata.width, 1, idx, 2);

setappdata(L.parent, 'LayoutManager', Lappdata);

resizefcn(L.parent, []);