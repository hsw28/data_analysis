function val = binsizes( G, d )
%BINSIZES bin sizes
%
%  b=BINSIZES(grid) returns a cell array of vectors with for each
%  dimension the bin sizes of the grid.
%
%  b=BINSIZES(grid,dim) returns the bin sizes only along dimension dim
%
%  Example
%    grid = fkgrid('linear', 0:100);
%    b = binsize(grid);
%
% See also FKGRID/CENTERS, FKGRID/EGDES
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(d) 
  d = 1:numel(G.grid);
elseif ~isnumeric(d) || any( d<1 || d>numel(G.grid) )
  error( 'fkgrid:binsizes:invalidIndex', 'Invalid dimension' )
end

val = {};

for k=1:numel(d)
  switch G.grid(d(k)).type
   case 'linear'
    if ~isvector(G.grid(d(k)).vector)
      val{end+1} = diff(G.grid(d(k)).vector, 1, 2)';
    else
      val{end+1} = diff(G.grid(d(k)).vector);
    end
   case 'circular'
    val{end+1} = circ_diff(G.grid(d(k)).vector);
  end
end

if numel(d)==1
  val = val{1};
end