function state = validate_state( grid, state )


if ~isstruct(state) || ~all( ismember( fieldnames(state), {'x', 'y', 'z', ...
                      'slice_index', 'slice_index2', 'slice_index3', 'slice_method'} ) )
  error('slicerui:validate_state:invalidState', ['Invalid state ' ...
                      'structure']);
end

if ~isscalar( state.x) || ~isscalar(state.y) || state.x<1 || state.y<1 || state.x>ndims(grid) ...
      || state.y>ndims(grid) || ~isscalar(state.z) || state.z<0 || state.z>ndims(grid)
  
  error('slicerui:validate_state:invalidState', ['Invalid x,y,z ' ...
                      'dimensions']);
end

if state.x==state.y || state.x==state.z || state.y==state.z
  error('slicerui:validate_state:invalidState', ['Invalid x,y,z ' ...
                      'dimensions']);
end  

if ~isnumeric( state.slice_index ) || numel(state.slice_index)~=ndims(grid) ...
      || any( state.slice_index<1 | state.slice_index>size(grid) )
  error('slicerui:validate_state:invalidState', 'Invalid slice indices');
end  
if isempty(state.slice_index2)
  state.slice_index2=state.slice_index;
elseif ~isnumeric( state.slice_index2 ) || numel(state.slice_index2)~=ndims(grid) ...
      || any( state.slice_index2<1 | state.slice_index2>size(grid) )
  error('slicerui:validate_state:invalidState', 'Invalid slice indices');
end  
if isempty(state.slice_index3)
  state.slice_index3=state.slice_index;
elseif ~isnumeric( state.slice_index3 ) || numel(state.slice_index3)~=ndims(grid) ...
      || any( state.slice_index3<1 | state.slice_index3>size(grid) )
  error('slicerui:validate_state:invalidState', 'Invalid slice indices');
end  

if ~iscellstr( state.slice_method ) || numel(state.slice_method)~=ndims(grid) ...
      || ~all( ismember( state.slice_method, {'slice', 'mean', 'max'}) )
  error('slicerui:validate_state:invalidState', 'Invalid slice methods');
end
