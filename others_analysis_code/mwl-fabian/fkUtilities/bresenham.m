function [cx,cy] = bresenham( x0, x1, y0, y1)
%BRESENHAM bresenham's algorithm for line digitization
%
%  [x,y]=BRESENHAM(x0,x1,y0,y1) Digitizes the line (x0,y0)-(x1,y1) and
%  returns the (integer) x,y image coordinates that represent the line.
%
%  Example
%    [cx, cy] = bresenham( 1, 40, 20, 80 );
%    I = sparse(cy, cx, 1);
%    imagesc( I );
%

%  Copyright 2005-2008 Fabian Kloosterman


steep = ( abs(y1-y0) > abs(x1-x0) );

if steep
  [x0, y0] = swap(x0, y0);
  [x1, y1] = swap(x1, y1);
end

if x0>x1
  [x0, x1] = swap(x0, x1);
  [y0, y1] = swap(y0, y1);
end

deltax = x1-x0;
deltay = abs(y1-y0);

error = 0;
y = y0;

if y0<y1
  ystep = 1;
else
  ystep = -1;
end
    
cx = [];
cy = [];

for x = x0:x1

  if steep
    cx(end+1)=y; %#ok
    cy(end+1)=x; %#ok
  else
    cx(end+1)=x;
    cy(end+1)=y;    
  end
  
  error = error + deltay;
  if 2*error >= deltax
    y = y + ystep;
    error = error - deltax;
  end
  
end
