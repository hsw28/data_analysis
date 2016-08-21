function [xyout] = flattencurve( xy, varargin )
%FLATTENCURVE flattening of 2D curve
%
%  xy=FLATTENCURVE(xy) Flattens the curve defined by the nx2 matrix xy in
%  25 steps. The output xy is a 3d matrix of the x,y coordinates of all
%  intermediate curves, such that the first plane is the original curve
%  and the last plane is the flattened curve. The curve is flattened until
%  all line segments are colinear with the first segment.
%
%  s=FLATTENCURVE(xy,param1,val1,...) Additional keyword/value pair options
%  can be specified:
%   path - can be a scalar that sets the number of steps over which the
%          curve is flattened, or a vector that defines a motion path or a
%          matrix with (#segments-1) rows that defines the motion path for
%          each segment beyond the first one. Motion paths are relative to
%          the original angle (i.e. 1 means the angle is identical to the
%          original and 0 means completely flattened).
%   startangle - either a scalar that defines the final angle of the
%                first segment, or a vector that defines the motion
%                path of the angle of the first segment (which should
%                have the same number of steps as the path above).
%   origin - either a 1x2 vector that defines the final x,y
%            coordinates of the first point on the curve, or a nx2
%            matrix that defines the motion path of the origin (n
%            should be identical to the numbe rof steps).
%

%  Copyright 2008-2008 Fabian Kloosterman

%check arguments
if nargin<1
    help(mfilename)
    return
end

if ~isnumeric(xy) || ndims(xy)~=2 || size(xy,2)~=2 || size(xy,1)<2
    error('flattencurve:invalidArguments', 'Invalid curve');
end

options = struct('startanglepath', [], 'path', 25, 'origin', []);
options = parseArgs(varargin,options);

%compute direction of line segments
d = atan2( diff(xy(:,2)), diff(xy(:,1)) );

%compute difference of line segment directions
dd = diff( unwrap(d) );

%length of line segments
l = sqrt( diff( xy(:,2)).^2 + diff(xy(:,1)).^2 );

%create path of angle flattening factors
if isempty(options.path)
    options.path = linspace(1,0,25);
elseif isvector(options.path)
    options.path = options.path(:)';
elseif ~isnumeric(options.path) || ~ndims(options.path)==2 || size(options.path,1)~=numel(dd)
    error('flattencurve:invalidArgument', 'Invalid motion path');
end

n = size(options.path,2);


%create path for angle of first segment
if isempty(options.startanglepath)
    options.startanglepath = repmat( d(1), 1, n );
elseif isscalar(options.startanglepath)
    if size(options.path,1)==1
        options.startanglepath = interp1( [1 0], [d(1) options.startanglepath], options.path, 'linear', 'extrap');
    else
        error('flattencurve:invalidArgument', 'Scalar startangle not allowed if path is a matrix');
    end
elseif ~isnumeric(options.startanglepath) || ~isvector(options.startanglepath) || numel(options.startanglepath)~=n
    error('flattencurve:invalidArgument', 'Invalid start angle path');
end

%create path for origin of first point of curve
if isempty(options.origin)
    options.origin = repmat( xy(1,:), n, 1);
elseif isequal(size(options.origin),[1 2])
    if size(options.path,1)==1
        options.origin = interp1( [1;0], [xy(1,:) ; options.origin], options.path, 'linear', 'extrap' );
    else
        error('flattencurve:invalidArgument', 'Scalar origin not allowed if path is a matrix');
    end
elseif ~isnumeric(options.origin) || ~isequal(size(options.origin),[n 2])
    error('flattencurve:invalidArgument', 'Invalid origin');
end    

%create motion path of direction deltas
%columns are the different timepoints
%rows are segments
if ~isempty(dd)
    dd = bsxfun( @times, dd, options.path );
end

%recreate directions
d = cumsum( [options.startanglepath ; dd], 1);

%create curves
x = cumsum( [ options.origin(:,1)' ; bsxfun( @times, cos(d), l)] );
y = cumsum( [ options.origin(:,2)' ; bsxfun( @times, sin(d), l)] );

xyout = permute(cat(3, x, y), [1 3 2] );
