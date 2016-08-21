function [x, y] = square2circle(x, y, cx, cy)
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
r(ind1) = y(ind1)*4/pi;
r(ind2) = x(ind2)*4/pi*-1;
r(ind3) = y(ind3)*4/pi*-1;
r(ind4) = x(ind4)*4/pi;

% corners
r(ind5) = y(ind5)*4/pi;
r(ind6) = x(ind6)*4/pi*-1;
r(ind7) = y(ind7)*4/pi*-1;
r(ind8) = x(ind8)*4/pi;

[x,y] = pol2cart(th,r);


