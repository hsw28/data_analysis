function m = slice2d( m, options )
%SLICE2D get a 2d slice from a n-dimensional matrix
%
%  slice=SLICE2D(m) returns a slice of matrix m defined in the first two
%  dimensions and index=1 in all other dimensions.
%
%  slice=SLICE2D(m,options) where options is a struct with the following
%  fields:
%   x - dimension of m that defines the x-dimension of the slice
%   y - dimension of m that defines the y-dimension of the slice
%   z - dimension of m that defines the rgb dimension of the slice (z=0
%       for a non-color slice)
%   slice_index - for each dimension of m the index for the slice. In
%                 case z>0, this determines the red color component.
%   slice_index2 - for each dimension of m the index of the green color
%                  component (only used if z>0).
%   slice_index3 - for each dimension of m the index of the blue color
%                  component (only used if z>0).
%   slice_method - one of 'slice', 'sum', 'max'. For 'sum' and 'max' the
%                  slice is the sum/max of along all dimensions but the x
%                  and y dimensions. The rgb dimension of the slice is
%                  only supported for the 'slice' method.
%

if nargin<1 || ~isnumeric(m)
  error('slice2d:invalidInput', 'Invalid matrix')
end  

nd = ndims(m);

if nargin<2
  %default slicing
  options = struct( 'x', 1, 'y', 2, 'z', 0, ...
                    'slice_index', ones( ndims(m), 1), ...
                    'slice_method', {repmat({'slice'}, ndims(m), 1)});
elseif ~isstruct(options) || ...
      ~all(ismember(fieldnames(options), {'x', 'y', 'z', 'slice_index', 'slice_index2', 'slice_index3', 'slice_method'})) || ...
      ~isscalar(options.x) || ~isscalar(options.y) || options.x<1 || options.x>nd || ...
      options.y<1 || options.y>nd || ~isnumeric(options.slice_index) || ...
      options.z<0 || options.z>nd || ...
      numel(options.slice_index)~=nd || ~iscellstr(options.slice_method) || ...
      numel(options.slice_method)~=nd || ...
      ~all(ismember(options.slice_method,{'slice','sum','max'}))
  error('slice2d:invalidInput', 'Invalid slice option');
end

s = cell( nd, 1);

for k=1:nd
  
  if k==options.x || k==options.y
    s{k} = ':';
  elseif strcmp(options.slice_method{k},'slice')
    if options.z==k
      s{k} = round( [options.slice_index(k) options.slice_index2(k) options.slice_index3(k)]);
    else
      s{k} = round( options.slice_index(k) );
    end
  elseif strcmp(options.slice_method{k}, 'max')
    m = nanmax( m, [], k );
    s{k} = 1;
  elseif strcmp(options.slice_method{k}, 'sum')
    m = nansum( m, k );
    s{k} = 1;
  else
    s{k} = 1;
  end

end


m = squeeze( subsref( m, struct('type', '()', 'subs', {s} ) ) );


if options.z==0 || any(strcmp(options.slice_method{options.z}, {'max', 'sum'}))
  if options.x<options.y
    m = m';
  end
else
  [dummy, permute_idx] = sort( [options.y options.x options.z] ); %#ok
  [dummy, permute_idx] = sort( permute_idx ); %#ok
  
  if ~isequal( permute_idx, [1 2 3])
    m = permute( m, permute_idx );
  end
end

