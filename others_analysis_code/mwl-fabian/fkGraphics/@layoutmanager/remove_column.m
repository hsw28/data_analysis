function remove_column(L, idx)
%REMOVE_COLUMN removes a column
%
%  REMOVE_COLUMN(L,idx) removes column at specified index
%

if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  error('layoutmanager:remove_column:invalidHandle', ['Parent does not exist or has ' ...
                      'no layout manager'])
end

Lappdata = getappdata(L.parent, 'LayoutManager');

[nrows, ncols, nz] = size( Lappdata.childmatrix );

if ncols==1
  error('layoutmanager:remove_column:noRemove', ['Can''t remove last ' ...
                      'column'])
end

if ~isnumeric(idx) || ~isscalar(idx) || idx<1 || idx>(ncols)
  error('layoutmanager:insert_column:invalidInput', 'Invalid index')
end

for k=1:nrows
  for level=1:nz
    if ishandle(Lappdata.childmatrix(k, idx, level))
      delete(Lappdata.childmatrix(k, idx, level));
    end
  end
end

Lappdata.childmatrix(:,idx,:) = [];
Lappdata.width(idx) = [];

setappdata(L.parent, 'LayoutManager', Lappdata);

resizefcn(L.parent, []);