function [x, y] = circle2square(px, py, cx, cy, length, diameter )
%CIRCLE2SQUARE scales points in a circular space into a square space by
%evalutating where on the parimeter of a circle a point lies and then 
%places that point at the same location on the perimeter of a square
% 
% [x y] = square_to_circle(px, py, length, diameter) 
%
% px, py   = the x,y coordinates for each point to be transformed
% cx, cy   = the x,y coordinates for the center of the square environment
% length   = the length of the side of the square that bounds the environment
% diameter = the diameter of the new circle that bounds the environment
%
% Written by Stuart P. Layton, MIT, December 2010
% Contact Info: slayton@mit.edu


if ~isvector(px) || ~isvector(py)  || size(px,2)~=1 || size(py,2)~=1 || ...
        size(px,1) ~= size(py,1) || size(px,2) ~= size(py,2)
    error('px and py column must be vectors of the same size');
end

if ~isscalar(length) || ~isscalar(diameter) || length<=0 || diameter <= 0
    error('length and diameter must be positives scalars');
end

% Center the points
px = px-cx;
py = py-cy;

% Convert to polar
r = sqrt(px.^2 + py.^2);
theta = atan2(px, py);

ind = ((-pi/4) < theta & theta < (pi/4)) | ((3*pi/4) < theta & theta< (5*pi/4));


Rs = sqrt(1 + (1/tan(theta.^2)))';
%Rs(ind) = sqrt(1+tan(theta(ind)).^2)';

[x,y] = pol2cart(theta, Rs);

%[x, y] = pol2cart(theta,r);
%x = theta;
%y= r;

x = x+cx;
y = y+cy;
