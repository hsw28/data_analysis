function resizefcn( hParent, eventdata, hChild, row_sz, col_sz, row_border, row_spacing, col_border, col_spacing, units ) %#ok
%RESIZEFCN resize function for GUIs
%
%  RESIZEFCN(hparent,eventdata,hchild,rowsize,colsize,rowborder,rowspacing,colborder,colspacing,units)
%
  
  
  
%raw_sz, col_sz: positive values are relative sizes, negative values are
%fixed sizes in characters

if nargin<3 || isempty(hChild)
  return
end

if nargin<4 || isempty(row_sz)
  row_sz = ones( size(hChild, 1), 1);
elseif isscalar(row_sz)
  row_sz = ones( size(hChild, 1), 1) .* row_sz;  
end

if nargin<5 || isempty(col_sz)
  col_sz = ones( size(hChild, 2), 1);
elseif isscalar(col_sz)
  col_sz = ones( size(hChild, 2), 1) .* col_sz;  
end

row_sz = row_sz(:)';
col_sz = col_sz(:)';

if size(hChild,1)~=numel(row_sz) || size(hChild,2)~=numel(col_sz)
  error('resizefcn:invalidArguments', ['Incompatible sizes of row ' ...
                      'and/or column size vectors']);
end

if nargin<10 || isempty(units)
  units = 'characters';

end

if ~ismember(units, {'pixels', 'characters', 'inches', 'centimeters', ...
                     'points'})
  error('resizefcn:invalidArguments', 'Invalid units')
end

[nrows, ncols] = size(hChild);

old_units = get( hParent, 'Units' );
set( hParent, 'Units', units );
container_pos = get( hParent, 'Position' );

fixed_row_sz_idx = find( row_sz<0 );
var_row_sz_idx = find( row_sz>0 );

fixed_col_sz_idx = find( col_sz<0 );
var_col_sz_idx = find( col_sz>0 );

fixed_row_sz = abs( sum( row_sz( fixed_row_sz_idx ) ) );
fixed_col_sz = abs( sum( col_sz( fixed_col_sz_idx ) ) );

row_sz( fixed_row_sz_idx ) = abs( row_sz( fixed_row_sz_idx ) );
col_sz( fixed_col_sz_idx ) = abs( col_sz( fixed_col_sz_idx ) );

if ~isempty(var_row_sz_idx)
  row_sz( var_row_sz_idx ) = max( 0, row_sz(var_row_sz_idx).* ...
                                  (container_pos(4)-fixed_row_sz-2*row_border-(nrows-1)*row_spacing) ./ sum( row_sz(var_row_sz_idx) ));
end
if ~isempty(var_col_sz_idx)
  col_sz( var_col_sz_idx ) = max( 0, col_sz(var_col_sz_idx).* ...
                                  (container_pos(3)-fixed_col_sz-2*col_border-(ncols-1)*col_spacing) ./ sum( col_sz(var_col_sz_idx) ));
end
row_offset = cumsum( row_sz(1:end) );
col_offset = cumsum( [0 col_sz(1:end-1)] );


for r=1:nrows
  for c=1:ncols
    
    if ~ishandle(hChild(r,c))
      continue
    end
    
    if row_sz(r)==0 || col_sz(c)==0
      set( hChild(r,c), 'Visible', 'off');
    else
      set( hChild(r,c), 'Visible', 'on', 'Units', units, 'Position', ...
                   [col_offset(c)+col_border+(c-1)*col_spacing ...
                    container_pos(4)-row_offset(r)-row_border-(r-1)*row_spacing ...
                    col_sz(c) ...
                    row_sz(r)] );
    end
  end
end
  
set( hParent, 'Units', old_units );

