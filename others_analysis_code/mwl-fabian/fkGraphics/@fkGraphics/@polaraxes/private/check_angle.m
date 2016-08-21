function [theta, idx] = check_angle( theta, lim, method )
%POLAR_CHECK_THETA check theta values
%
%  [theta,idx]=CHECK_ANGLE(theta,lim,method) checks and corrects
%  theta values. Theta value outside the specified limits are either
%  clipped or set to NaN, depending on the method argument. The function
%  also returns the indices of the theta values that were corrected.
%

% Copyright 2008-2008 Fabian Kloosterman

% make sure 0<=theta<2*pi
theta = limit2pi( theta );

if mod( diff( lim ), 2*pi ) == 0
  idx = [];
  return
end

if lim(1)<lim(2)
  if strcmp(method, 'clip')
    M = rem(mean(lim)+pi, 2*pi);
    if lim(2) > M
      i1 = find( theta<=M | theta>lim(2) );
      theta( i1 ) = lim(2);
    else
      i1 = find( theta<=M & theta>lim(2) );
      theta( i1 ) = lim(2);
    end
    if lim(1) > M
      i2 = find( theta>M & theta<lim(1) );
      theta( i2 ) = lim(1);
    else
      i2 = find( theta>M | theta<lim(1) );
      theta( i2 ) = lim(1);
    end
    idx = [i1; i2];
  else %replace with NaNs
    idx = find( theta<lim(1) | theta>lim(2) );
    theta(idx) = NaN;
  end
else
  if strcmp(method, 'clip')
    M = rem(mean(lim), 2*pi);
    if lim(1) > M
      i1 = find( theta>=M & theta<lim(1) );
      theta( i1 ) = lim(1);
    else
      i1 = find( theta>=M | theta<lim(1) );
      theta( i1 ) = lim(1);
    end
    if lim(2) > M
      i2 = find( theta<M | theta>lim(2) );
      theta( i2 ) = lim(2);
    else
      i2 = find( theta<M & theta>lim(2) );
      theta( i2 ) = lim(2);
    end
    idx = [i1; i2];
  else %replace with NaNs
    idx = find( theta<lim(1) & theta>lim(2) );
    theta(idx) = NaN;        
  end
end