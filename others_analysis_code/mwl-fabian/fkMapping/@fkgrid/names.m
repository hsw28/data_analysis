function val = names( G, d )
%NAMES return grid dimension names
%
%  n=NAMES(grid) returns the names of all dimensions
%
%  n=NAMES(grid,dim) returns the name of dimension dim
%
%  Example
%    grid = fkgrid({'linear', 1:100, 'test'), 1:100);
%    n=names(grid);
%
%  See also FKGRID/LABELS
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(d) 
  d = 1:numel(G.grid);
elseif ~isnumeric(d) || any( d<1 || d>numel(G.grid) )
  error( 'fkgrid:names:invalidIndex', 'Invalid dimension' )
end

val = {G.grid(d).name};

if numel(d)==1
  val = val{1};
end