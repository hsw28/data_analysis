function setnrows(L,n)
%SETNROWS set the number of rows
%
%  SETNROWS(L,n) set the number of rows of the layoutmanager to n.
%

if ~ishandle(L.parent) || ~isappdata(L.parent, 'LayoutManager')
  error('layoutmanager:setnrows:invalidHandle', ['Parent does not exist or has ' ...
                      'no layout manager'])
end

Lappdata = getappdata(L.parent, 'LayoutManager');

[nrows, ncols, nz] = size( Lappdata.childmatrix ); %#ok

if ~isnumeric(n) || ~isscalar(n) || n<1
  error('layoutmanager:setnrows:invalidInput', 'Invalid number of rows')
end

if n>nrows
  for r=(nrows+1):n
    for c=1:ncols
      for level=1:nz
        Lappdata.childmatrix(r,c,level) = Lappdata.fcn( Lappdata.argin{:}, ...
                                                        'Parent', ...
                                                        L.parent);
      end
    end
  end
  Lappdata.height((nrows+1):n) = 1; 
elseif n<nrows
  for r=(n+1):nrows
    for c=1:ncols
      for level=1:nz
        if ishandle(Lappdata.childmatrix(r,c,level))
          delete(Lappdata.childmatrix(r,c,level));
        end
      end
    end
  end
  Lappdata.childmatrix((n+1):nrows, :,:)=[];
  Lappdata.height((n+1):nrows) = [];
end

setappdata(L.parent, 'LayoutManager', Lappdata);
resizefcn(L.parent, []);