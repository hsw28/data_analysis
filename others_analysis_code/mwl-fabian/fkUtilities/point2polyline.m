function [pts, dist, seg, lindist] = point2polyline(nodes, xy, clipends, closed)
%POINT2POLYLINE find nearest point on polyline for a set of points
%
%  pp=POINT2POLYLINE(p,xy) returns for each x,y coordinate the nearest x,y
%  coordinate on the polyline.
%
%  pp=POINT2POLYLINE(p,xy,0) will extrapolate beyond the terminal segments.
%
%  [pp,d]=POINT2POLYLINE(...) also returns the distance between the x,y
%  coordinate and the nearest point on the polyline.
%
%  [pp,d,s]=POINT2POLYLINE(...) also returns the index of the polyline
%  segment that the nearest point is located on.
%
%  [pp,d,s,ld]=POINT2POLYLINE(...) also returns the distance along the
%  polyline from the first node to the nearest point.
%


%  Copyright 2005-2008 Fabian Kloosterman

pts = [];

if nargin<2
    return
end

if nargin<3 || isempty( clipends )
    clipends = 1;
end

if nargin<4 || isempty( closed )
  closed = 0;
end

[r, c] = size(xy);

if ndims(xy)>2 || ~isnumeric(xy) || c~=2
    error('point2polyline:invalidArgument', 'Invalid xy array')
end


%loop through all segments
nseg = size(nodes,1)-1;

dist = Inf(r,1);
pts = NaN(r,2);
seg = NaN(r,1);
lindist = NaN(r,1);

if r==0
    return
end

if closed
    nodes(end+1,:) = nodes(1,:);
    nseg = nseg+1;
end

for s = 1:nseg
    
    [tmp_dist, tmp_pts] = dist_point_segment(xy, nodes(s:s+1, :),1);
    i = find(abs(tmp_dist)<abs(dist));
    if length(i)>0
        dist(i) = tmp_dist(i);
        pts(i,:) = tmp_pts(i,:);
        seg(i) = s;
    end
    
end

valid = find(~isnan(seg));
cumdist = cumsum([0; sqrt( sum(diff(nodes).^2,2) )]);
lindist(valid) = cumdist(seg(valid)) + sqrt( sum([pts(valid,1)-nodes(seg(valid),1) pts(valid,2)-nodes(seg(valid),2)].^2 ,2) );

if ~clipends
    
    idx = find(lindist==0);
    [dist(idx), pts(idx,:)] = dist_point_segment( xy(idx,:) , nodes(1:2,:), 0);
    lindist(idx) = - sqrt( sum([pts(idx,1)-nodes(seg(idx),1) pts(idx,2)-nodes(seg(idx),2)].^2 ,2) );
    
    idx = find(lindist==cumdist(end));
    [dist(idx), pts(idx,:)] = dist_point_segment( xy(idx,:) , nodes(end-1:end,:), 0);
    lindist(idx) = cumdist(end) + sqrt( sum([pts(idx,1)-nodes(end,1) pts(idx,2)-nodes(end,2)].^2 ,2) );
        
end
