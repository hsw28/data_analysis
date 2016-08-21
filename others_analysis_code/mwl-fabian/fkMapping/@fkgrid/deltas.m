function dt = deltas( G, d)
%DELTAS returns grid spacing
%
%  delta=DELTAS(grid) returns the spacing for every linear uniform
%  dimension in the grid, or 1 for categorical dimensions or NaN
%  otherwise.
%
%  delta=DELTAS(grid,dim) returns spacing for diension dim only
%
%  Example
%    grid = fkgrid('linear', 0:3:30, 'linear', 10:2:80);
%    delta = deltas(grid); %returns [3 2]
%
%  See also FKGRID/ISUNIFORM
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(d)
  d = 1:numel(G.grid);
elseif ~isnumeric(d) || any( d<1 | d>numel(G.grid) )
  error('fkgrid:deltas:invalidIndex', 'Invalid dimension')
end

dt = NaN(1, numel(d) );

for k=1:numel(d)
  
  switch G.grid(d(k)).type
   case 'linear'
    if iscategorical(G,d(k))
      dt(k)=1;
    elseif isuniform(G,d(k))
      dt(k) = mean( diff(centers(G, d(k))) );
    end
  end
end