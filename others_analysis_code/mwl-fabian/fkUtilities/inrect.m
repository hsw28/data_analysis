function result = inrect(x, y, rect)
%INRECT check whether points x,y are within a rectangle
%
%  b=INRECT(x,y,rectangle) returns true if x,y coordinates are located
%  within the rectangle [x y width height]. Points on the border of
%  the rectangle are considered to be inside. 
%
%  Example
%    r = inrect( rand(10,1), rand(10,1), [0 0 0.2 0.2] );
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<3
    help(mfilename)
    return
end

if length(x) ~= length(y)
    error('inrect:invalidArguments', 'x and y are not the same size')
end

if ~isnumeric(rect) && length(rect)~=4
    error('inrect:invalidArguments', 'Invalid rectangle')
end

result = (x >= rect(1) & (x<=rect(1)+rect(3)) & y>=rect(2) & y<=rect(2)+rect(4));
