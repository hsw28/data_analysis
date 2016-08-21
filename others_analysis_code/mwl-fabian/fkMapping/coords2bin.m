function [b, grid]=coords2bin(coords,grid)
%COORDS2BIN map coordinates to a grid
%
%  bins=COORDS2BIN(coords) coords is a matrix in which each row is a
%  coordinate and each column is a dimension. The function will bin the
%  coordinates with a grid that has size 10 in all dimensions, spanning
%  all data.
%
%  bins=COORDS2BIN(coords,nbins) specifies the number of bins. This can
%  either be a scalar or a vector that gives the number of bins for each
%  dimension separately.
%
%  bins=COORDS2BIN(coords,edges) specifies a cell array with for each
%  dimension a vector of bin edges
%
%  bins=COORDS2BIN(coords,grid) specifies a grid object to use for
%  binning,
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

if isempty(coords)
  b=[];
  return
end

[n,m] = size(coords); %#ok
maxcoords = max(coords);
mincoords = min(coords);

edges = {};

if nargin<2 || isempty(grid)
  grid=10;
end

if isnumeric(grid) && isscalar(grid)
  grid = grid.*ones(1,m);
end

if isnumeric(grid) && isvector(grid) && numel(grid)==m
  for k=1:m
    if maxcoords(k)==mincoords(k)
      edges{k}= (maxcoords(k)-0.5*grid(k)):(maxcoords(k)+0.5*grid(k));
    else
      edges{k} = linspace( mincoords(k), maxcoords(k), grid(k)+1 );
    end
  end
  grid = edges;
end

if ~isa(grid, 'fkgrid') && (iscell(grid) || numel(grid)==m)
  grid = fkgrid( grid{:} );
end

if ~isa(grid, 'fkgrid')
  error('coords2bin:invalidArgument', 'Invalid grid')
end

b = bin(grid,coords);
