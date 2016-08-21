function [dist, points] = dist_point_segment(xy, segment, clipends)
%DIST_POINT_SEGMENT calculate distance between points and a line segment
%
%  dist=DIST_POINT_SEGMENT(coordinates,segment) returns the distance
%  between 2d-coordinates (nx2 matrix) and a line segment defined by
%  start and end coordinates in a 2x2 matrix. The distance can be
%  positive or negative, depending on which side of the segment the
%  coordinate is located on. (Imagine walking on the segment from the
%  start to the end point, coordinates located on your right have a
%  negative distance, coordinates located on your left have a positive
%  distance)
%
%  [dist,project]=DIST_POINT_SEGMENT(coordinates,segment) also returns
%  for each coordinate the projected point onto the line segment,
%  i.e. the point on the line segment that is closest to the coordinate.
%
%  [...]=DIST_POINT_SEGMENT(coordinates,segment,false) treats the line segment
%  as a infinitely long line, such that the projected point can be
%  outside the specified line segment.
%
%  Example
%    p = [1 1.5];
%    seg = [0 0; 4 4];
%    [dist, pp] = dist_point_segment( p, seg );
%

%  Copyright 2005-2008 Fabian Kloosterman

%initialize output
dist=[];
points = zeros(0,2);

%check  input arguments
if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty(clipends)
    clipends = true;
end

if ndims(segment)>2 || size(segment,1)~=2 || size(segment,2)~=2 || ~isnumeric(segment)
    error('dist_point_segment:invalidSegment', 'Invalid segment')
end

[r, c] = size(xy);
if ndims(xy)>2 || ~isnumeric(xy) || c~=2
    error('dist_point_segment:invalidXY', 'Invalid xy array')
end

%calculate distance between points and segment
v = segment(2,:)-segment(1,:);
w = bsxfun( @minus, xy, segment(1,:) );

c1 = w*v';

i1 = [];
i2 = [];

c2 = v*v';

%clip points to ends of segment
if clipends
    %for points closest to start of segment
    i1 = find(c1<=0);
    i1 = i1(:);
    if length(i1)>0
        dist(i1) = sqrt(sum(w(i1,:).^2,2));
        points(i1,:) = repmat(segment(1,:), length(i1), 1);
    end

    %for points closest to end of segment
    i2 = find(c2<=c1);
    i2=i2(:);
    if length(i2)>0
        w2 = bsxfun( @minus, xy, segment(2,:) );
        dist(i2) = sqrt(sum(w2(i2,:).^2,2));
        points(i2,:) = repmat(segment(2,:), length(i2), 1);
    end
end

b = c1 ./ c2;

%calculate distance and projected points for non-clipped coordinates
i3 = setdiff((1:r)', [i1;i2]);
i3 = i3(:);
if length(i3)>0
    points(i3,:) = bsxfun( @plus, segment(1,:), [v(1).*b(i3) v(2).*b(i3)] );
    dist(i3) = sqrt( sum( [points(i3,1)-xy(i3,1) points(i3,2)-xy(i3,2)].^2 , 2 ) );
end

dseg = segment(2,:)-segment(1,:);
dpoint = xy - points;

ss = sign( sin( atan2(dpoint(:,2), dpoint(:,1)) - atan2(dseg(1,2),dseg(1,1)) ) );

ss(ss==0)=1;

dist = dist';

dist = dist .* ss;
