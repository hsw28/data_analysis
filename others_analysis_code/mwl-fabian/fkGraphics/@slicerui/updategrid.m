function updategrid(S, grid)
%UPDATEGRID update slicer grid
%
%  UPDATEGRID(slicer,grid) updates the slicer with a new grid which
%  represents the volume to be sliced.
%

if nargin<2
  return
elseif ~isa(grid, 'fkgrid')
  error('slicerui:updategrid:invalidInput', 'Invalid grid')
end

h = S.hash;
s = h.get('slicer');

if ndims(s.grid) ~= ndims(grid) || ~isequal(names(s.grid), names(grid))
  error('slicerui:updategrid:invalidInput', 'Unable to update grid')
end

gmax = size(grid);

for k=1:ndims(grid)
 
  s.state.slice_index(k) = min( gmax(k), s.state.slice_index(k) );
  s.state.slice_index2(k) = min( gmax(k), s.state.slice_index2(k) );
  s.state.slice_index3(k) = min( gmax(k), s.state.slice_index3(k) );

  lbls = labels(grid, k, [s.state.slice_index(k) s.state.slice_index2(k) s.state.slice_index3(k)] );
  
  %awtinvoke(s.ui.dim(k).scrollbar, 'setValues', s.state.slice_index(k), 1, 1, gmax(k)+1);
  %awtinvoke(s.ui.dim(k).slicelabel, 'setText', java.lang.String(lbls{s.state.slice_index(k)}) );
  s.ui.dim(k).scrollbar.setValues(s.state.slice_index(k), 1, 1, gmax(k)+1);
  s.ui.dim(k).slicelabel.setText(lbls{1});
  

  %awtinvoke(s.ui.dim(k).scrollbar2, 'setValues', s.state.slice_index2(k), 1, 1, gmax(k)+1);
  %awtinvoke(s.ui.dim(k).slicelabel2, 'setText', java.lang.String(lbls{s.state.slice_index2(k)}) );  
  s.ui.dim(k).scrollbar2.setValues( s.state.slice_index2(k), 1, 1, gmax(k)+1);
  s.ui.dim(k).slicelabel2.setText(lbls{2});
  

  %awtinvoke(s.ui.dim(k).scrollbar3, 'setValues', s.state.slice_index3(k), 1, 1, gmax(k)+1);
  %awtinvoke(s.ui.dim(k).slicelabel3, 'setText', java.lang.String(lbls{s.state.slice_index3(k)}) );
  s.ui.dim(k).scrollbar3.setValues(s.state.slice_index3(k), 1, 1, gmax(k)+1);
  s.ui.dim(k).slicelabel3.setText( lbls{3});
  
end

%s.ui.mainpanel.updateUI();

s.grid = grid;

h.put('slicer', s);
