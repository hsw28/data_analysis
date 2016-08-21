function [hPol] = rose(varargin)
%ROSE   Angle histogram plot.
%   ROSE(THETA) plots the angle histogram for the angles in THETA.  
%   The angles in the vector THETA must be specified in radians.
%
%   ROSE(THETA,N) where N is a scalar, uses N equally spaced x 
%   from 0 to 2*PI.  The default value for N is 20.
%
%   ROSE(THETA,X) where X is a vector, draws the histogram using the
%   bins specified in X.
%
%   ROSE(AX,...) plots into AX instead of GCA.
%
%   H = ROSE(...) returns a vector of line handles.
%
%   [T,R] = ROSE(...) returns the vectors T and R such that 
%   POLAR(T,R) is the histogram.  No plot is drawn.
%
%   See also HIST, POLAR, COMPASS.

%   Clay M. Thompson 7-9-91
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.14.4.6 $  $Date: 2011/07/25 03:49:40 $

[cax,args,nargs] = axescheck(varargin{:});
remArgs = {};
theta = args{1};

if nargs > 1 
  x = args{2}; 
  if nargs > 2
      remArgs = args(3:end);
  end
end

theta = mod(unwrap(theta), 2*pi); % ensure that theta is bound between 0 and 2pi;

if nargs==1,
  x = (0:35)*pi/18+pi/36;

elseif nargs==2,
  if length(x)==1,
    x = (0:x-1)*2*pi/x + pi/x;
  else
    x = sort( rem( x(:)', 2*pi) );
  end
end

% Determine bin edges and get histogram
edges = sort(rem([(x(2:end)+x(1:end-1))/2 (x(end)+x(1)+2*pi)/2],2*pi));
edges = [edges edges(1)+2*pi];
nn = histc(rem(theta+2*pi-edges(1),2*pi),edges-edges(1));
nn(end-1) = nn(end-1)+nn(end);
nn(end) = [];

% Form radius values for histogram triangle
if min(size(nn))==1, % Vector
  nn = nn(:); 
end
[m,n] = size(nn);
mm = 4*m;
r = zeros(mm,n);
r(2:4:mm,:) = nn;
r(3:4:mm,:) = nn;

% Form theta values for histogram triangle from triangle centers (xx)
zz = edges;

t = zeros(mm,1);
t(2:4:mm) = zz(1:m);
t(3:4:mm) = zz(2:m+1);

polar2(cax, t, r, remArgs{:});
end


