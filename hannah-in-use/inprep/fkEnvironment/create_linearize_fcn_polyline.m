function ctx = create_linearize_fcn_polyline(nodes, isclosed)
%CREATE_LINEARIZE_FCN_POLYLINE polyline linearization context
%
%  ctx=CREATE_LINEARIZE_FCN_POLYLINE(nodes) For a polyline
%  described by a set of nodes, this function will return a
%  linearization context. This structure contains the following
%  fields:
%   length - total length of the polyline
%   isclosed - true/false, whether the polyline is closed or not
%   linearize - linearization function of the form:
%               [lpos,delta]=linearize(xy), this function
%               will take a nx2 matrix of x,y coordinates and
%               computes for each point the linearized position
%               (lpos) and the distance to the polyline (delta).
%   inv_linearize - inverse linearization function of the form:
%                   xy=inv_linearize(linpos[,delta]), this function
%                   will take a vector of linearized positions
%                   (linpos) and return the corresponding x,y
%                   coordinates on the polyline. Optionally, a vector
%                   with distances to the polyline (delta) can be
%                   provided, and the corresponding x,y coordinates
%                   will be offset from the polyline by that amount.
%   direction - local direction function of the form:
%               dir=direction(linpos), this function will take a
%               vector of linearized positions (linpos) and return
%               the angle of the polyline (dir) at those positions in
%               radians.
%   velocity - velocity function of the form:
%              vel=velocity(linpos[,dt]), this function will take a
%              vector of regularly sampled linearized positions and
%              returns the velocity. It will correctly deal with
%              closed polylines. Optionally, a sample period (dt) can
%              be provided (default=1/30).
%   bin - binning function of the form: bins=bin(binsize), this
%         function will return a vector of bin edges that span the
%         complete polyline with a bin size as close as possible to
%         the desired bin size.
%   thicken - outlining function of the form: xy=thicken(width),
%             this function will create an outline of the polyline
%             with the specified width.
%   flatten - flattening function of the form:
%             ctx=flatten([factor,origin,startangle]), this
%             function will return a new linearization context of
%             the polyline flattened with the specified
%             factor. Optionally, the final origin and startangle
%             can be specified.
%

%  Copyright 2007-2008 Fabian Kloosterman

%check arguments
if nargin>1 && ~isempty(isclosed) && isequal(isclosed,true)
    nodes = nodes( [1:size(nodes,1) 1], : );
else
    isclosed = false;
end

%compute length of polyline
L = sum( sqrt( sum( diff( nodes ).^2, 2 ) ) );

%create linearization context
ctx = struct( 'length', L, ...
              'isclosed', isclosed, ...
              'linearize', @(xy) linearize_polyline(xy, nodes), ...
              'inv_linearize', @(p,varargin) inv_linearize_polyline(p, nodes, varargin{:}), ...
              'direction', @(p) direction_polyline(p, nodes), ...
              'velocity', @(p, varargin) velocity_polyline(p, isclosed, L, varargin{:}), ...
              'bin', @(binsize) bin_polyline(binsize, L), ...
              'thicken', @(w) polysolid(thickencurve(nodes,w)), ...
              'flatten', @(varargin) flatten_polyline(nodes, varargin{:}) );

end


%------------------
%INTERNAL FUNCTIONS
%------------------


function [p,d] = linearize_polyline(xy, nodes)
%LINEARIZE_POLYLINE linearization function

[dummy, d, dummy, p] = point2polyline( nodes, xy, 1 ); %#ok

end

%------------------

function xy = inv_linearize_polyline(p, nodes, dist)
%INV_LINEARIZE_POLYLINE inverse linearization function

%compute length
l = cumsum( [0; sqrt( sum( diff( nodes ).^2, 2 ) )] );

%interpolate to find x,y coordinates
xy = interp1( l, nodes, p, 'linear', 'extrap' );

%apply distance to polyline if requested
if nargin>2
    
    %compute normal
    d = floor( interp1( l, [1:(size(nodes,1)-1) (size(nodes,1)-1)]', p, 'linear', 'extrap') );
    d = atan2( nodes(d+1 , 2) - nodes(d, 2), nodes(d+1, 1) - nodes(d, 1) ) + 0.5*pi;    

    %add offsets to x,y coordinates
    xy = xy + [dist.*cos(d) dist.*sin(d)];

end

end

%------------------

function d = direction_polyline(p, nodes)
%DIRECTION_POLYLINE local polyline direction

%compute length
l = cumsum( [0; sqrt( sum( diff( nodes ).^2, 2 ) )] );

%compute direction
d = floor( interp1( l, [1:(size(nodes,1)-1) (size(nodes,1)-1)]', p, 'linear', 'extrap' ) );
d = atan2( nodes(d+1 , 2) - nodes(d, 2), nodes(d+1, 1) - nodes(d, 1) );

end

%------------------

function v = velocity_polyline(p, isclosed, L, dt)
%VELOCITY_POLYLINE compute linearized velocity

%unwrap linear position if polyline is closed
if isclosed
    factor = 2*pi./L;
    p = unwrap( p.*factor )./factor;
end

%compute gradient
if nargin>3
    v = gradient( p, dt );
else
    v = gradient( p, 1./30 );
end

end

%------------------

function edges = bin_polyline(binsize, l)
%BIN_POLYLINE binning function

nbins = ceil( l./binsize );

edges = linspace(0,l,nbins+1);

end

%------------------

function xyout = flatten_polyline(xy, n, origin, startangle)
%FLATTEN_POLYLINE create flattened polyline

%check arguments
if nargin<2 || isempty(n)
    n=0;
else
    %make sure 0<=n<=1
    n = min( max( n, 0 ), 1 );
end

if nargin<3
    origin = [];
end

if nargin<4 
    startangle = [];
end

%do actual flattening
xy = flattencurve( xy, 'path', n, 'startanglepath', startangle, 'origin', origin );

%create linearization contexts
for k=1:size(xy,3)
    xyout(k) = create_linearize_context('polyline', xy(:,:,k) );
end

end




