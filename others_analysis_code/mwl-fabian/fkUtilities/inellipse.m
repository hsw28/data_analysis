function b = inellipse(x,y,a,b,x0,y0)
%INELLIPSE find points in ellipse
%
%  b=INELLIPSE(x,y) returns true if x,y coordinates are located within the
%  circle with radius 1 and origin [0 0];
%
%  b=INELLIPSE(x,y,a,b,x0,yo) returns true if x,y coordinates are located
%  within the ellipse with minor axes a,b and origin [x0 y0].
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2
  return
end

if nargin<3 || isempty(a)
  a = 1;
end
if nargin<4 || isempty(b)
  b = 1;
end
if nargin<5 || isempty(x0)
  x0=0;
end
if nargin<6 || isempty(y0)
  y0=0;
end
  

b = ( ((x-x0).^2)./a.^2 + ((y-y0).^2)./b.^2 ) <= 1 ;
