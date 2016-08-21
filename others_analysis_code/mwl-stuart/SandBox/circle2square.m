function [x, y] = circle2square(x, y, cx, cy)
%CIRCLE2SQUARE scales points in a circular space into a square space by
%evalutating where on the parimeter of a circle a point lies and then 
%places that point at the same location on the perimeter of a square
% 
% [x y] = square_to_circle(x, y, length, diameter) 
%
% x, y   = the x,y coordinates for each point to be transformed
% cx, cy   = the x,y coordinates for the center of the square environment
% length   = the length of the side of the square that bounds the environment
% diameter = the diameter of the new circle that bounds the environment
%
% Written by Stuart P. Layton, MIT, December 2010
% Contact Info: slayton@mit.edu


if ~isvector(x) || ~isvector(y)  || numel(x) ~= numel(y)
    error('x and y column must be vectors of the same size');
end
x = x(:);
y = y(:);


x = x - cx;
y = y - cy;

[th r] = cart2pol(x,y);

% edges
ind1 = y>0 & abs(y) > abs(x);
ind2 = x<0 & abs(x) > abs(y);
ind3 = y<0 & abs(y) > abs(x);
ind4 = x>0 & abs(x) > abs(y);

% corners
ind5 = y>0 & x>0 & abs(y) == abs(x);
ind6 = y>0 & x<0 & abs(y) == abs(x);
ind7 = y<0 & x<0 & abs(y) == abs(x);
ind8 = y<0 & x>0 & abs(y) == abs(x);

% edges
x(ind1) = (pi*r(ind1)/4) ./ tan(th(ind1));
y(ind1) = (pi*r(ind1)/4);

x(ind2) = -(pi*r(ind2)/4);
y(ind2) = (pi*r(ind2)/4) .* tan(th(ind2));

x(ind3) = (pi*r(ind3)/4) ./ tan(th(ind3));
y(ind3) = -(pi*r(ind3)/4);

x(ind4) = (pi*r(ind4)/4);
y(ind4) = (pi*r(ind4)/4) .* tan(th(ind4));

% corners
x(ind5) = (pi*r(ind5)/4);
y(ind5) = (pi*r(ind5)/4);

x(ind6) = -(pi*r(ind5)/4);
y(ind6) = (pi*r(ind5)/4);

x(ind7) = -(pi*r(ind5)/4);
y(ind7) = -(pi*r(ind5)/4);

x(ind8) = (pi*r(ind5)/4);
y(ind8) = -(pi*r(ind5)/4);


