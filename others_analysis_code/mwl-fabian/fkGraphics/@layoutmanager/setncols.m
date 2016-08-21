function setncols(L,n)
%SETNCOLS set the number of cols
%
%  SETNCOLS(L,n) set the number of cols of the layoutmanager to n.
%

if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  error('layoutmanager:setncols:invalidHandle', ['Parent does not exist or has ' ...
                      'no layout manager'])
end

Lappdata = getappdata(L.parent, 'LayoutManager');

[nrows, ncols, nz] = size( Lappdata.childmatrix ); %#ok

if ~isnumeric(n) || ~isscalar(n) || n<1
  error('layoutmanager:setncols:invalidInput', 'Invalid number of cols')
end

if n>ncols
  for r=1:nrows
    for c=(ncols+1):n
      for level=1:nz
        Lappdata.childmatrix(r,c,level) = Lappdata.fcn( Lappdata.argin{:}, ...
                                                        'Parent', ...
                                                        L.parent);
      end
    end
  end
  Lappdata.width((ncols+1):n) = 1; 
elseif n<ncols
  for r=1:nrows
    for c=(n+1):ncols
      for level=1:nz
        if ishandle(Lappdata.childmatrix(r,c,level))
          delete(Lappdata.childmatrix(r,c,level));
        end
      end
    end
  end
  Lappdata.childmatrix((n+1):ncols, :,:)=[];
  Lappdata.width((n+1):ncols) = [];
end

setappdata(L.parent, 'LayoutManager', Lappdata);
resizefcn(L.parent, []);