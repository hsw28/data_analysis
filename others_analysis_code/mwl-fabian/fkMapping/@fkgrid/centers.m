function val = centers( G, d )
%CENTERS get bin centers
%
%  c=CENTERS(grid) returns a cell array of vectors with for each
%  dimension the bin centers of the grid.
%
%  c=CENTERS(grid,dim) returns the bin centers only along dimension dim
%
%  Example
%    grid = fkgrid('linear', 0:100);
%    c = centers(grid);
%
%  See also FKGRID/BINSIZES, FKGRID/EDGES
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(d) 
  d = 1:numel(G.grid);
elseif ~isnumeric(d) || any( d<1 | d>numel(G.grid) )
  error( 'fkgrid:centers:invalidIndex', 'Invalid dimension' )
end

val = {};

for k=1:numel(d)
  switch G.grid(d(k)).type
   case 'linear'
    if ~isvector(G.grid(d(k)).vector)
      val{end+1} = mean( G.grid(d(k)).vector, 2 )';
    else
      val{end+1} = (G.grid(d(k)).vector(1:end-1) + G.grid(d(k)).vector(2:end) ...
                    )./2;
    end
   case 'circular'
    val{end+1} = limit2pi( circ_mean([G.grid(d(k)).vector(1:end-1) ...
                        G.grid(d(k)).vector(2:end)], 2) );    
  end
end

if numel(d)==1
  val = val{1};
end