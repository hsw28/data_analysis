function resizefcn( hParent, eventdata ) %#ok

L = getappdata( hParent, 'LayoutManager');

if isempty(L)
  return
end
  
if isempty(L.childmatrix)
  return
end

[nrows, ncols, nz] = size(L.childmatrix);

old_units = get( hParent, 'Units' );
old_pos = get( hParent, 'Position');
set( hParent, 'Units', L.units );
container_pos = get( hParent, 'Position' );
set( hParent, 'Units', old_units);

%reset position because callback could have been interrupted
if ~strcmp(get(hParent','type'),'figure') || ~strcmp(get(hParent, 'WindowStyle'),'docked')
    set(hParent, 'Position', old_pos ); 
end

visible_rows = L.height~=0;
visible_columns = L.width~=0;
nvis_rows = numel( find(visible_rows) );
nvis_columns = numel( find(visible_columns) );

fixed_row_sz_idx = find( L.height<0 );
var_row_sz_idx = find( L.height>0 );

fixed_col_sz_idx = find( L.width<0 );
var_col_sz_idx = find( L.width>0 );

fixed_row_sz = abs( sum( L.height( fixed_row_sz_idx ) ) );
fixed_col_sz = abs( sum( L.width( fixed_col_sz_idx ) ) );

L.height( fixed_row_sz_idx ) = abs( L.height( fixed_row_sz_idx ) );
L.width( fixed_col_sz_idx ) = abs( L.width( fixed_col_sz_idx ) );

if ~isempty(var_row_sz_idx)
  L.height( var_row_sz_idx ) = max( 0, L.height(var_row_sz_idx).* ...
                                  (container_pos(4)-fixed_row_sz-2*L.yoffset-(nvis_rows-1)*L.yspacing) ./ sum( L.height(var_row_sz_idx) ));
end
if ~isempty(var_col_sz_idx)
  L.width( var_col_sz_idx ) = max( 0, L.width(var_col_sz_idx).* ...
                                  (container_pos(3)-fixed_col_sz-2*L.xoffset-(nvis_columns-1)*L.xspacing) ./ sum( L.width(var_col_sz_idx) ));
end
row_offset = cumsum( L.height(1:end) );
col_offset = cumsum( [0 L.width(1:end-1)] );
visrow_offset = cumsum( visible_rows );
viscol_offset = cumsum( visible_columns );

for r=1:nrows
  for c=1:ncols
    for level = 1:nz
    
      if ~ishandle(L.childmatrix(r,c,level))
        continue
      end

    
      if L.height(r)==0 || L.width(c)==0

        handles = findobj( L.childmatrix(r,c,level), 'Visible', 'on');
        
        set( handles, 'Tag', 'visible' );
        set( handles, 'Visible', 'off', 'HitTest', 'off');
      
        %HACK: java widgets are put in a uicontainer by javacomponent, but are not
        %made invisible, by making the parent uipanel invisible
        %set( findobj(get(L.childmatrix(r,c,level), 'Children'), 'Type', ...
        %             'uicontainer'), 'Visible', 'off', 'HitTest', 'off');
        %set( findobj(get(L.childmatrix(r,c,level), 'Children'), 'Type', 'uicontrol'), ...
        %     'HitTest', 'off');
        
      else
        
        handles = findobj( L.childmatrix(r,c,level), 'Tag', 'visible' ...
                              );
        set(handles, 'Visible', 'on', 'Tag', '', 'HitTest', 'on' );
        
        set( L.childmatrix(r,c,level), 'Units', L.units, 'Position', ...
                          [col_offset(c)+L.xoffset+(viscol_offset(c)-1)*L.xspacing ...
                           container_pos(4)-row_offset(r)-L.yoffset-(visrow_offset(r)-1)*L.yspacing ...
                           L.width(c) ...
                           L.height(r)], 'HitTest', 'on' );
        
        %HACK: java widgets are put in a uicontainer by javacomponent, but are not
        %made invisible, by making the parent uipanel invisible
        %set( findobj(get(L.childmatrix(r,c,level), 'Children'), 'Type', ...
        %             'uicontainer'), 'Visible', 'on', 'HitTest', 'on');      
        %set( findobj(get(L.childmatrix(r,c,level), 'Children'), 'Type', 'uicontrol'), ...
        %     'HitTest', 'on');      
      end
    end
  end
end


