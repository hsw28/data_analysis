function G1 = plus( G1, G2 )
%PLUS concatenate grids
%
%  g=PLUS(g1,g2) concatenate two grids
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || ~isa(G2, 'fkgrid')
  return;
end

G1.grid(end+1:end+ndims(G2)) = G2.grid;