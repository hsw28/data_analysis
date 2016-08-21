function d = circ_diff( phi, theta, directed)
%CIRC_DIFF angle of smallest arc between two angles
%
%  d=CIRC_DIFF(phi) compute the smallest arc between successive angles in
%  phi. This arc is always in the range [0,pi].
%
%  d=CIRC_DIFF(phi, theta) compute smallest arc between elements in phi
%  and theta.
%
%  d=CIRC_DIFF(phi, theta, 1) compute directed differences. That is, d<0
%  if theta-pi<=phi<=theta and d>=0 if theta<=phi<=theta+pi
%
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2 || isempty(theta)
  theta = phi(2:end);
  phi = phi(1:end-1);
end

%default to absolute difference angles
if nargin<3 || isempty(directed)
    directed = 0;
end

%make sure 0<=theta<2*pi and 0<=phi<2*pi
phi = limit2pi( phi );
theta = limit2pi( theta );

%compute circular difference
if directed
    d = limit2pi(theta - phi, -pi);
else
    d = pi - abs( pi - abs( theta - phi ) );
end
