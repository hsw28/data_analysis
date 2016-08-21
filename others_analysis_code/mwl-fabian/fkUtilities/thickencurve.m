function s=thickencurve(xy,w)
%THICKENCURVE create curve outline
%
%  outline=THICKENCURVE(xy,width) create an outline for the curve
%  defined by the x,y coordinates in the nx2 matrix xy. The width
%  of the outline is measured from the curve to the outline on
%  either side.
%

%  Copyright 2008-2008 Fabian Kloosterman


%check input arguments
if nargin<2
    help(mfilename)
    return
end

if ~isnumeric(xy) || ndims(xy)~=2 || size(xy,2)~=2 || size(xy,1)<2
    error('thickencurve:invalidArgument', 'Invalid curve coordinates')
end

if ~isnumeric(w) || ~isscalar(w) || w<=0
    error('thickencurve:invalidArgument', 'Invalid width')
end


%determine if curve is closed by checking first and last point
isclosed = isequal( xy(end,:), xy(1,:) );

if isclosed
    %copy 2nd and 2nd to last point so that the angles can be
    %computed correctly for closed curves
    xy = xy([end-1 1:end 2],:);
end

%compute differences
xy = xy';
dx = diff( xy(1,:) );
dy = diff( xy(2,:) );

%compute angles
segment_theta = atan2( dy, dx ) - 0.5*pi;

%compute half angle between two curve segments
theta = circ_mean( [ segment_theta([1 1:end]) ; segment_theta([1:end end]) ] );
dtheta = [0 circ_diff( segment_theta, theta(2:end) )];

%compute normalized x and y offsets
dx = cos(theta)./(cos(dtheta));
dy = sin(theta)./(cos(dtheta));

%create outline
x1 = xy(1,:) + w(end).*dx;
y1 = xy(2,:) + w(end).*dy;
x2 = xy(1,:) - w(1).*dx;
y2 = xy(2,:) - w(1).*dy;

if isclosed
    s = [[x1(2:end-1) x2(end-1:-1:2)] ; [y1(2:end-1) y2(end-1:-1:2)]]';
else
    s = [[x1 x2(end:-1:1)] ; [y1 y2(end:-1:1)]]';
end

