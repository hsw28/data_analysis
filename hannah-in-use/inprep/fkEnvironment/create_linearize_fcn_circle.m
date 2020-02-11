function ctx = create_linearize_fcn_circle(center, radius)
%CREATE_LINEARIZE_FCN_CIRCLE circle linearization functions
%
%  ctx=CREATE_LINEARIZE_FCN_CIRCLE(center,radius) For a circle
%  described by a center and radius, this function will return a
%  linearization context. This structure contains the following
%  fields:
%   length - total length of the circle outline
%   isclosed - true
%   linearize - linearization function of the form:
%               [lpos,delta]=linearize(xy), this function
%               will take a nx2 matrix of x,y coordinates and
%               computes for each point the linearized position
%               (lpos) and the distance to the circle (delta).
%   inv_linearize - inverse linearization function of the form:
%                   xy=inv_linearize(linpos[,delta]), this function
%                   will take a vector of linearized positions
%                   (linpos) and return the corresponding x,y
%                   coordinates on the circle. Optionally, a vector
%                   with distances to the circle (delta) can be
%                   provided, and the corresponding x,y coordinates
%                   will be offset from the circle by that amount.
%   direction - local direction function of the form:
%               dir=direction(linpos), this function will take a
%               vector of linearized positions (linpos) and return
%               the angle of the circle (dir) at those positions in
%               radians.
%   velocity - velocity function of the form:
%              vel=velocity(linpos[,dt]), this function will take a
%              vector of regularly sampled linearized positions and
%              returns the velocity. Optionally, a sample period
%              (dt) can be provided (default=1/30).
%   bin - binning function of the form: bins=bin(binsize), this
%         function will return a vector of bin edges that span the
%         complete circle outline with a bin size as close as
%         possible to the desired bin size.
%   thicken - outlining function of the form: xy=thicken(width),
%             this function will create an outline of the circle
%             with the specified width.
%   flatten - flattening function of the form:
%             ctx=flatten([factor,origin,startangle]), this
%             function will return a new linearization context of
%             the circle flattened with the specified
%             factor. Optionally, the final origin and startangle
%             can be specified.
%

%  Copyright 2007-2008 Fabian Kloosterman

L = 2*pi.*radius;

ctx = struct( 'length', L, ...
              'isclosed', true, ...
              'linearize', @(xy) linearize_circle(xy, center, radius), ...
              'inv_linearize', @(p,varargin) inv_linearize_circle(p, center, radius, varargin{:}), ...
              'direction', @(p) direction_circle(p, radius), ...
              'velocity', @(p, varargin) velocity_circle(p, L, varargin{:} ), ...
              'bin', @(binsize) bin_circle(binsize, L), ...
              'thicken', @(w) thicken_circle(center, radius ,w), ...
              'flatten', @(varargin) flatten_circle(center, radius, varargin{:} ) );
          
end

%------------------
%INTERNAL FUNCTIONS
%------------------

function [theta,rho] = linearize_circle(xy, center, radius)
%LINEARIZE_CIRCLE linearization function

%convert x,y coordinates to polar coordinates
[theta, rho] = cart2pol( xy(:,1)-center(1), xy(:,2)-center(2) );

theta = theta.*radius;
rho = rho - radius;

end

%------------------

function xy = inv_linearize_circle(theta, center, radius, dist)
%INV_LINEARIZE_CIRCLE inverse linearization function

%convert linearized psoitions to x,y coordinates
if nargin>3
    [x,y] = pol2cart( theta./radius, radius+dist );
else
    [x,y] = pol2cart( theta./radius, radius );
end

xy = [x+center(1) y+center(2)];

end

%------------------

function d = direction_circle(theta, radius)
%DIRECTION_CIRCLE local circle direction

d = theta./radius + 0.5*pi;

end

%------------------

function v = velocity_circle(p, L, dt)
%VELOCITY_CIRCLE compute linearized velocity

%unwrap linearized position
factor = 2*pi./L;
p = unwrap( p.*factor )./factor;

%compute gradient
if nargin>2
    v = gradient( p, dt );
else
    v = gradient( p, 1./30 );
end

end

%------------------

function edges = bin_circle(binsize, l)
%BIN_CIRCLE binning function

nbins = ceil( l./binsize );

edges = linspace(0,l,nbins+1);

end

%------------------

function xy = thicken_circle(center, radius, w)
%THICKEN_CIRCLE create circle outline

theta = linspace(2*pi,0,100)';
xy = [cos(theta).*(radius+w(1))+center(1) sin(theta).*(radius+w(1))+center(2)];

if w(end)<radius
    xy = {xy ; [cos(theta(end:-1:1)).*(radius-w(end))+center(1) sin(theta(end:-1:1)).*(radius-w(end))+center(2)] };
end

end

%------------------

function xyout = flatten_circle(center, radius, n, origin, startangle)
%FLATTEN_CIRCLE created flattened circle

%check arguments
if nargin<2 || isempty(n)
    n=0;
else
    %make sure 0<=n<1
    n=min(max(n,0),1);
end

if nargin<3
    origin = [];
end

if nargin<4 
    startangle = [];
end

%create circle curve
theta = linspace(0,2*pi,100)';
xy = [cos(theta).*radius+center(1) sin(theta).*radius+center(2)];

%do actual flattening
xy = flattencurve( xy, 'path', n, 'startanglepath', startangle, 'origin', origin );

%create linearization contexts
for k=1:size(xy,3)
    xyout(k) = create_linearize_context('polyline', xy(:,:,k) );
end

end



