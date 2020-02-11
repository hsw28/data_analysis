function ctx = create_linearize_fcn_spline(nodes, isclosed)
%CREATE_LINEARIZE_FCN_SPLINE spline linearization context
%
%  ctx=CREATE_LINEARIZE_FCN_SPLINE(nodes) For a spline
%  described by a set of nodes, this function will return a
%  linearization context. This structure contains the following
%  fields:
%   length - (estimated) total length of the spline. The spline is
%            100 times oversampled and the length is computed as
%            the sum of the resulting line segments.
%   isclosed - true/false, whether the spline is closed or not
%   linearize - linearization function of the form:
%               [lpos,delta]=linearize(xy), this function
%               will take a nx2 matrix of x,y coordinates and
%               computes for each point the linearized position
%               (lpos) and the distance to the spline (delta).
%   inv_linearize - inverse linearization function of the form:
%                   xy=inv_linearize(linpos[,delta]), this function
%                   will take a vector of linearized positions
%                   (linpos) and return the corresponding x,y
%                   coordinates on the spline. Optionally, a vector
%                   with distances to the spline (delta) can be
%                   provided, and the corresponding x,y coordinates
%                   will be offset from the spline by that amount.
%   direction - local direction function of the form:
%               dir=direction(linpos), this function will take a
%               vector of linearized positions (linpos) and return
%               the angle of the spline (dir) at those positions in
%               radians.
%   velocity - velocity function of the form:
%              vel=velocity(linpos[,dt]), this function will take a
%              vector of regularly sampled linearized positions and
%              returns the velocity. It will correctly deal with
%              closed splines. Optionally, a sample period (dt) can
%              be provided (default=1/30).
%   bin - binning function of the form: bins=bin(binsize), this
%         function will return a vector of bin edges that span the
%         complete spline with a bin size as close as possible to
%         the desired bin size.
%   thicken - outlining function of the form: xy=thicken(width),
%             this function will create an outline of the spline
%             with the specified width.
%   flatten - flattening function of the form:
%             ctx=flatten([factor,origin,startangle]), this
%             function will return a new linearization context of
%             the spline flattened with the specified
%             factor. Optionally, the final origin and startangle
%             can be specified.
%


%  Copyright 2007-2008 Fabian Kloosterman

%check arguments
if nargin>1 && ~isempty(isclosed) && isequal(isclosed,true)
    nodes = nodes( [1:size(nodes,1) 1], : );
else
    isclosed=false;
end

% oversample spline for length calculation
s = cscvn( nodes' );
t = linspace( s.breaks(1), s.breaks(end), numel(s.breaks).*100 );
xy = fnval( s, t );
L = sum( sqrt( sum( diff( xy,1,2 ).^2 ) ) );

%clear variables to prevent them from being captured in function
%handles
clear s t xy

%create linearization context
ctx = struct( 'length', 0, ...
              'isclosed', isclosed, ...
              'linearize', @(xyin) linearize_spline(xyin, nodes), ...
              'inv_linearize', @(p,varargin) inv_linearize_spline(p, nodes, varargin{:}), ...
              'direction', @(p) direction_spline(p, nodes), ...
              'velocity', @(p, varargin) velocity_spline(p, isclosed, L, varargin{:}), ...
              'bin', @(binsize) bin_spline(binsize,L), ...
              'thicken', @(w) thicken_spline(nodes,w), ...
              'flatten', @(varargin) flatten_spline(nodes,varargin{:}) );

end


%------------------
%INTERNAL FUNCTIONS
%------------------

function [p,d] = linearize_spline(xy, nodes)
%LINEARIZE_SPLINE linearization function

%oversample spline
s = cscvn( nodes' );
t = linspace( s.breaks(1), s.breaks(end), numel(s.breaks).*100 );
sxy = fnval( s, t )';  
  
%try linearization using delaunay triangulation
try
    
    %do triangulation
    dl = delaunay( sxy(:,1), sxy(:,2) );
    idx = dsearch( sxy(:,1), sxy(:,2), dl, xy(:,1), xy(:,2) );
  
    %compute length
    l = cumsum( [0 ; sqrt( sum( diff( sxy ).^2, 2 ) ) ] );
  
    %deal with NaNs
    valid = ~isnan(idx);
    p = NaN(size(xy,1),1);
    d = NaN(size(xy,1),1);
  
    %find linearized positions
    p(valid) = l(idx(valid));
  
    %compute distance to spline if requested
    if nargout>1
        d(valid) = sqrt( (sxy(idx(valid),1)-xy(valid,1)).^2 + (sxy(idx(valid),2)-xy(valid,2)).^2 );
        sder = fnder( s );
        sder = fnval( sder, interp1( l, t(:), p ) )';
        sder = atan2( sder(:,2), sder(:,1) );
        d = d.*sign(sin( sder - atan2( (sxy(idx(valid),2)-xy(valid,2)), (sxy(idx(valid),1)-xy(valid,1)) ) ) );
    end
    
  catch
      %fall back, if delaunay doesn;t work (i.e. if spline is flat)
      [dummy, d, dummy, p] = point2polyline( nodes, xy, 1 ); %#ok
  end
  
end

%------------------

function xy = inv_linearize_spline(p, nodes, dist)
%INV_LINEARIZE inverse linearization function

%oversample spline
s = cscvn( nodes' );
t = linspace( s.breaks(1), s.breaks(end), numel(s.breaks).*100 );
sxy = fnval( s, t )';  
  
%compute length
l = cumsum( [0 ; sqrt( sum( diff( sxy ).^2, 2 ) ) ] );

%interpolate to find x,y coordinates
xy = interp1( l, sxy, p, 'linear', 'extrap' );
  
%apply distance to spline if requested
if nargin>2
    %compute derivative of spline
    sder = fnder( s );
    d = fnval( sder, interp1( l, t(:), p, 'linear', 'extrap' ) )';
    %compute normal
    d = atan2( d(:,2), d(:,1) ) + 0.5*pi;
    %add offsets to x,y coordinates
    xy = xy + [dist.*cos(d) dist.*sin(d)];
end
  
end

%------------------

function d = direction_spline(p, nodes)
%DIRECTIONS_SPLINE local spline direction

%oversample spline
s = cscvn( nodes' );
t = linspace( s.breaks(1), s.breaks(end), numel(s.breaks).*100 );
sxy = fnval( s, t )';

%compute length
l = cumsum( [0 ; sqrt( sum( diff( sxy ).^2, 2 ) ) ] );  

%spline derivative
sder = fnder( s );

%compute direction
d = fnval( sder, interp1( l, t(:), p ) )';
d = atan2( d(:,2), d(:,1) );

end

%------------------

function v = velocity_spline(p, isclosed, L, dt)
%VELOCITY_SPLINE compute linearized velocity

%unwrap linear position if spline is closed
if isclosed
    factor = 2*pi./L;
    p = unwrap( factor.*p )./factor;
end

%compute gradient
if nargin>3
    v = gradient( p, dt );
else
    v = gradient( p, 1./30 );
end

end

%------------------

function edges = bin_spline(binsize, l)
%BIN_SPLINE binning function

nbins = ceil( l./binsize );

edges = linspace(0,l,nbins+1);

end

%------------------

function xy = thicken_spline(xy, w)
%THICKEN_SPLINE create spline outline

% oversample spline
s = cscvn( xy' );
t = linspace( s.breaks(1), s.breaks(end), numel(s.breaks).*100 );
xy = fnval( s, t );

%create actual outline
xy = polysolid( thickencurve( xy', w ) );

end

%------------------

function xyout = flatten_spline(xy, n, origin, startangle)
%FLATTEN_SPLINE create flattened spline

%check arguments
if nargin<2 || isempty(n)
    n=0;
else
    %make sure 0<=n<=1
    n=min(max(n,0),1);
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
    xyout(k) = create_linearize_context('spline', xy(:,:,k) );
end

end