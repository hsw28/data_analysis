function G = fkgrid( varargin )
%FKGRID fkgrid object constructor
%
%  g=FKGRID default constructor
%
%  g=FKGRID(g) copy constructor
%
%  g=FKGRID(grid_def1, ...) returns a new fkgrid object with the
%  specified grids for each dimension. A grid definition can be any of
%  the following:
%  vector - grid edges for a linear grid
%  string,vector - the string can be either 'linear' or 'circular' and
%  the vector specifies the grid edges
%  cell - three element cell array: {'linear'/'circular', vector of grid
%  edges, 'name'}
%
%  An fkgrid object stores the grid edges for n-dimensions, which can be
%  either linear or circular (like angles). Each dimension ahs a name
%  associated with it. The following methods are defined for a fkgrid
%  object:
%  bin - get the bin indices for a set of coordinates
%  binsizes - get binsizes
%  centers - get bin centers
%  edges - get bin edges
%  iscategorical - tests for NaNs and Infs
%  isuniform - test for uniform spacing and size  of bins
%  labels - get bin edge labels
%  map - create a map using the grid
%  names - get dimension names
%  ndims - get number of dimensions
%  size - get the number of bins in each dimension
%
%  fkgrid objects can be concatenated using the plus operator.
%
%  Example
%    g = fkgrid( 'linear', 0:100, {'linear', -10:10, 'test'}, 1:50 );
%    g2 = g + fkgrid( 'circular', (0:0.1:1)*pi );
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin == 0
  %create default (empty) grid object
  
  G = struct( 'grid', struct( 'type', {}, ...
                              'vector', {}, ...
                              'name', {} ) );
  
  G = class( G, 'fkgrid' );
  
elseif nargin == 1 && isa( varargin{1}, 'fkgrid' )
  %make copy
  
  G = class( struct( varargin{1} ), 'fkgrid' );
  
else
  
  G = struct( 'grid', struct( 'type', {}, 'vector', {}, 'name', {} ) );
  
  k = 1;
  
  while k<=nargin
    
    if ischar( varargin{k} ) && k<nargin
      switch lower(varargin{k})
       case {'linear', 'l'}
        k = k+1;
        G.grid(end+1) = struct( 'type', 'linear', ...
                                'vector', check_linear_grid(varargin{k}), ...
                                'name', ['var ' num2str(numel(G.grid)+1)]);
       case {'circular', 'c'}
        k = k+1;
        G.grid(end+1) = struct(  'type', 'circular', ...
                                 'vector', check_circular_grid(varargin{k}(:)), ...
                                'name', ['var ' num2str(k)]);        
       otherwise
        error('fkgrid:fkgrid:invalidArguments', 'Invalid grid vectors')
      end
    elseif isnumeric( varargin{k} )
      G.grid(end+1) = struct( 'type', 'linear', ...
                              'vector', check_linear_grid(varargin{k}), ...
                              'name', ['var ' num2str(numel(G.grid)+1)]);
    elseif iscell( varargin{k} ) && numel(varargin{k})==3 && ...
          ismember(varargin{k}{1}, {'l', 'c', 'linear', 'circular'}) && isnumeric(varargin{k}{2}) && ...
          ischar( varargin{k}{3} )
      t = varargin{k}{1};
      if ismember( t, {'l', 'linear'} )
        t = 'linear';
        v = check_linear_grid(varargin{k}{2});
      elseif strcmp(t, 'c')
        t = 'circular';
        v = check_circular_grid(varargin{k}{2}(:));
      end
      G.grid(end+1) = struct( 'type', t, 'vector', v, 'name', ...
                              varargin{k}{3} );
    else
      error('fkgrid:fkgrid:invalidArguments', 'Invalid grid vectors')
    end
    
    k = k+1;
    
  end

      G = class( G, 'fkgrid' );   

end
  

function g = check_linear_grid( g )

tmp = g';

if ~ismonotonic( tmp(:), 1, 'i' )
  error( 'fkgrid:fkgrid:invalidArguments', 'Linear grid must be monotonically increasing' )
end

if isvector(g)
  g = g(:);
elseif ndims(g)~=2 || size(g,2)~=2
  error( 'fkgrid:fkgrid:invalidArguments', 'Invalid linear grid');
end

function g = check_circular_grid( g )

tmp = limit2pi( g-g(1) );
if tmp(end)<=eps
  tmp(end) = 2*pi;
end
if ~ismonotonic( tmp, 1, 'i' )
  error('fkgrid:fkgrid:invalidArguments', ['Circular grid must be monotonically increasing and cannot span ' ...
          'more than 2 pi'])
end
