function sz = size(G, i)
%SIZE get number of bins
%
%  n=SIZE(grid) returns the number of bins in each dimension
%
%  n=SIZE(grid, dim) returns the number of bins only for dimension dim
%
%  Example
%    grid = fkgrid(1:100,1:50)
%    n = size( grid );
%
%  See also FKGRID/NDIMS
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(i)
  i = 1:ndims(G);
elseif ~isnumeric(i) || any( i<i || i>numel(G.grid) )
  error('fkgrid:size:invalidIndex', 'Invalid dimension')
end

sz = zeros(1, numel(i));

for k=1:numel(i)
  if strcmp( G.grid(i(k)).type, 'linear' ) && ~isvector(G.grid(i(k)).vector)
    sz(k) = size(G.grid(i(k)).vector,1);
  else
    sz(k) = numel(G.grid(i(k)).vector)-1;
  end
end

