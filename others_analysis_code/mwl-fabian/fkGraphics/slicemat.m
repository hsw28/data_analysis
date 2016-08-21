function slicemat( M )
%SLICEMAT explore a n-dimensional matrix
%
%  SLICEMAT(m) simple user interface to explore a n-dimensional volume by
%  slicing the volume.
%
  
  
%create figure;
hFig = figure;

nd = ndims(M);
sz = size(M);
Mx = nanmax( M(:) );
Mn = nanmin( M(:) );

for k=1:nd
  g{k} = 1:(sz(k)+1); %#ok
end

Grid = fkgrid( g{:} );

%create slicer ui
state = struct( 'x', 1, 'y', 2, 'z', 0, ...
                'slice_index', ones(1, nd), ...
                'slice_index2', min( ones(1,nd)+1, sz ), ...
                'slice_index3', min( ones(1,nd)+2, sz ), ...
                'slice_method', {repmat({'slice'}, nd, 1)} );

s = slicerui( Grid, state );
add_callback(s, @slicerchange);

[jc,hc] = javacomponent( getPanel(s), java.awt.BorderLayout.EAST, hFig ); %#ok

hAx = axes('Parent', hFig );

slicerchange( [], getState( s ) );


  function slicerchange(hObj, state) %#ok
  
  imagesc( slice2d( M, state ), 'Parent', hAx, [Mn Mx] );
  colorbar('peer',hAx);
  
  xlabel( hAx, names(Grid, state.x) );
  ylabel( hAx, names(Grid, state.y) );  
  
  end

end
