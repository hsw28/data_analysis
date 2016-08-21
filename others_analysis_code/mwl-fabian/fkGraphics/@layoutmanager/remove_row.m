function remove_row(L, idx)
%REMOVE_ROW removes a single row
%
%  REMOVE_ROW(L,index) removes the row at index
%

if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  error('layoutmanager:remove_row:invalidHandle', ['Parent does not exist or has ' ...
                      'no layout manager'])
end

Lappdata = getappdata(L.parent, 'LayoutManager');

[nrows, ncols, nz] = size( Lappdata.childmatrix );

if nrows==1
  error('layoutmanager:remove_row:noRemove', ['Can''t remove last ' ...
                      'row'])
end

if ~isnumeric(idx) || ~isscalar(idx) || idx<1 || idx>(nrows)
  error('layoutmanager:insert_row:invalidInput', 'Invalid index')
end

for k=1:ncols
  for level = 1:nz
    if ishandle(Lappdata.childmatrix(idx, k, level))
      delete(Lappdata.childmatrix(idx, k, level));
    end
  end
end

Lappdata.childmatrix(idx,:,:) = [];
Lappdata.height(idx) = [];

setappdata(L.parent, 'LayoutManager', Lappdata);

resizefcn(L.parent, []);