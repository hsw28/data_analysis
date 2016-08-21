function val = edges( G, d )
%EDGES get bin edges
%
%  e=EDGES(grid) returns a cell array of vectors with for each
%  dimension the bin edges of the grid.
%
%  b=EDGES(grid,dim) returns the bin edges only along dimension dim
%
%  Example
%    grid = fkgrid('linear', 0:100);
%    b = edges(grid);
%
% See also FKGRID/CENTERS, FKGRID/BINSIZES
%

%  Copyright 2006-2008 Fabian Kloosterman


if nargin<2 || isempty(d)
  val = { G.grid.vector };
elseif ~isnumeric(d) || any( d<1 || d>numel(G.grid) )
  error('fkgrid:edges:invalidIndex', 'Invalid dimension')
else
  val = G.grid(d).vector;
end