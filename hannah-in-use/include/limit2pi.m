function theta = limit2pi( theta, offset )
%LIMIT2PI confines angles to [0 2pi)
%
%  theta=LIMIT2PI(theta) makes sure all angles in theta are in the
%  interval [0 2*pi>.
%
%  theta=LIMIT2PI(theta, shift) where shift is a scalar, confine all
%  angles to the interval [shift 2*pi+shift>.
%
%  theta=LIMIT2PI(theta, range) where range is a two element vector,
%  confine all angles to the interval [range(1) range(2)>.
%
%  Example
%    limit2pi( 3*pi )        %result: pi
%    limit2pi( 3*pi, -pi )   %result: -pi
%    limit2pi( 4, [1 3] )    %result: 2
%

%  Copyright 2005-2008 Fabian Kloosterman


%check input arguments
if nargin<2
  range = 2*pi;
  offset = 0;
elseif numel(offset)==1
  range = 2*pi;
else
  range = abs( offset(2)-offset(1) );
  offset = offset(1);
end

%limit theta to interval
theta = mod( mod( theta, range ) + range - offset, range ) + offset;
