function b = iscategorical( G, d )
%ISCATEGORICAL checks whether grid is categorical or numerical
%
%  b=ISCATEGORICAL(grid) returns a 1 for each dimension that is
%  categorical (i.e. contains NaNs or Infs) and 0 for those that are not.
%
%  b=ISCATEGORICAL(grid,dim) performs the test only on dimension dim.
%
%  Example
%    grid = fkgrid([-Inf 0 Inf]);
%    b = iscategorical(grid);
%
%  See also FKGRID/ISUNIFORM
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(d) 
  d = 1:numel(G.grid);
elseif ~isnumeric(d) || any( d<1 || d>numel(G.grid) )
  error( 'fkgrid:iscategorical:inavalidIndex', 'Invalid dimension' )
end

b = zeros( 1, numel( d ) );

for k=1:numel(d)
  
  if any( isnan(G.grid(d(k)).vector(:)) ) || any( isinf(G.grid(d(k)).vector(:)) )
    b(k) = 1;
  end
  
end
