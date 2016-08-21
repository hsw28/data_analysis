function [m, g]=map(coords, varargin)
%MAP map a set of coordinates to a grid
%
%  m=MAP(coords) given a set of coordinates (columns are dimensions, and
%  each row is a coordinate), this function will construct a nd histogram
%  using a default grid. The argument coords can also be a cell array of
%  matrices, in which case the maps will share the same grid and will be
%  concatenated along the first available dimension. 
%
%  m=MAP(coords,var) applies the mapping function to the matrix of
%  variables, rather than the coordinates. The var matrix should have the
%  same number of rows as the coordinates matrix. By default the variable
%  is [1] at each coordinate.
%
%  m=MAP(coords,parm1,val1,...) uses the specified options. Valid options
%  are:
%   filters - set of filters that will be used filtercoords before
%             computing the map.
%   grid - mapping grid
%   default - default value for empty bins
%   function - function to apply to the vector of samples in each bin
%              (default: @size)
%
%  [m,grid]=MAP(...) returns the mapping grid as well.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

options = struct('filters', [], 'grid', []);
[options, other, remainder]=parseArgs(varargin,options);

if isempty(other)
  vars=[];
else
  vars=other{1};
end

if isnumeric(coords)
  coords = {coords};
elseif ~iscell(coords)
  error('map:invalidArgument', 'Invalid coordinates')
end

N = numel(coords);

if isempty(vars)
  vars = cell(N,1);
elseif isnumeric( vars ) && N==1
  vars = {vars};
elseif ~iscell(vars) || numel(vars) ~= N
  error('map:invalidArguments', 'Invalid variables')
end

m = [];

for k=1:numel(coords)

  if ~isempty(options.filters)
    coords{k} = filtercoords(coords{k},options.filters);
  end

  [bins, options.grid] = coords2bin(coords{k},options.grid);

  sz = size(options.grid);

  m = cat( ndims(options.grid)+1, m, bin2map(bins, vars{k}, remainder{:}, 'size', sz ) );

end

g = options.grid;
