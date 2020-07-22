function [px, py] = lineboxintersect( L, B )
%LINEBOXINTERSECT find intersections of lines with a box
%
%  [x,y]=LINEBOXINTERSECT(lineparms,box) lineparms is a nx2 matrix of
%  theta/rho pairs that define a line. Box is a vector [xleft xright
%  ybottom ytop]. The function returns the two intersection points of
%  each line with the box (i.e. x and y are nx2 matrices) or NaN if the
%  line does not intersect the box.
%


sintheta = sin(L(:,1));
costheta = cos(L(:,1));

yleft   = (L(:,2) - B(1).*costheta ) ./ sintheta;
yright  = (L(:,2) - B(2).*costheta ) ./ sintheta;
xtop    = (L(:,2) - B(4).*sintheta ) ./ costheta;
xbottom = (L(:,2) - B(3).*sintheta ) ./ costheta;

n = size(L,1);

px = NaN(n,2);
py = NaN(n,2);

np = zeros(n,1);

idx = find( yleft > B(3) & yleft <= B(4) );
sidx = idx;
np(idx) = np(idx)+1;
px(sidx) = B(1);
py(sidx) = yleft(idx);
    
idx = find( yright >= B(3) & yright < B(4) );
sidx = idx + n*np(idx);
np(idx) = np(idx)+1;
px(sidx) = B(2);
py(sidx) = yright(idx);
    
idx = find( xtop > B(1) & xtop <= B(2) );
sidx = idx + n*np(idx);
np(idx) = np(idx)+1;
px(sidx) = xtop(idx);
py(sidx) = B(4);
    
idx = find( xbottom >= B(1) & xbottom < B(2) );
sidx = idx + n*np(idx);
np(idx) = np(idx)+1;
px(sidx) = xbottom(idx);
py(sidx) = B(3);

idx = find(np==1);
px(idx, 2) = px(idx, 1);
py(idx, 2) = py(idx, 1);
