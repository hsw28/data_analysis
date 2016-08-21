function d = dist2point( coords, center )
%DIST2POINT calculate distance to point
%
%  d=DIST2POINT(coordinates,center) computes the distance between a list
%  of coordinates and center. Coordinates should be given as a n-by-d
%  matrix, where n is the number of coordinates and d is the number of
%  dimensions. By default center is the origin.
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
    help(mfilename)
    return
end

if ~isnumeric(coords) || ndims(coords)>2
  error('dist2point:invalidCoords', 'Invalid coordinates');
end

[n, nd] = size( coords );

%compute distance
if nargin<2
  d = sqrt( sum( coords.^2, 2) );
elseif ~isnumeric(center) || ndims(center)>2 || size( center,2) ~= nd || size(center,1)~=1
  error('dist2point:invalidCenter', 'Invalid center point')
else
  d = sqrt( sum( bsxfun( @minus, coords,  center ).^2, 2 ) );
end

