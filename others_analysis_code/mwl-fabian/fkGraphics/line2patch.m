function [px,py] = line2patch( x, y, width )
%LINE2PATCH create patches along a line
%
%  [px,py]=LINE2PATCH(x,y) construct patches for a polyline with x,y
%  coordinates.
%
%  [px,py]=LINE2PATCH(x,y,width) set the width of the line.
%

%  Copyright 2007-2008 Fabian Kloosterman


if nargin<2
  help(mfilename)
  return
end

if nargin<3 || isempty(width)
  width = 1;
end

x = x(:)';
y = y(:)';

dx = diff( x );
dy = diff( y );

segment_theta = atan2( dy, dx ) -0.5*pi;

theta = circ_mean( [ segment_theta([1 1:end]) ; segment_theta([1:end end]) ] );
dtheta = [0 circ_diff( segment_theta, theta(2:end) )];

dx = width.*cos(theta)./cos(dtheta);
dy = width.*sin(theta)./cos(dtheta);

x1 = x + dx;
y1 = y + dy;
x2 = x - dx;
y2 = y - dy;

px = [x2(1:end-1);x1(1:end-1);x1(2:end);x2(2:end)];
py = [y2(1:end-1);y1(1:end-1);y1(2:end);y2(2:end)];

%px = [x(1:end-1)-dx;x(1:end-1)+dx;x(2:end)+dx;x(2:end)-dx];
%py = [y(1:end-1)-dy;y(1:end-1)+dy;y(2:end)+dy;y(2:end)-dy];
