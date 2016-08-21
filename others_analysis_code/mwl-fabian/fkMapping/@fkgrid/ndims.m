function n = ndims( G )
%NDIMS number of dimensions
%
%  nd=NDIMS(grid) returns the number of grid dimensions
%
%  Example
%    grid = fkgrid(1:100);
%    nd = ndims(grid);
%
%  See also FKGRID/SIZE
%

%  Copyright 2006-2008 Fabian Kloosterman

n = numel( G.grid );