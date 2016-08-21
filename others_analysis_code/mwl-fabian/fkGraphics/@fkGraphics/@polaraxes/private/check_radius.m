function [rho, idx_low, idx_high] = check_radius( rho, lim, rdir, method )
%POLAR_CHECK_RHO check rho values
%
%  [rho,idxlow,idxhigh]=CHECK_RADIUS(rho,lim,rdir,method) checks and
%  normalizes radius values. Rho values that are outside the specified
%  limits are either clipped, set to NaN or set to zero, depending on the
%  method argument. The rdir argument is the direction of the radial axis 
%  ('normal' or 'reverse'). The function also returns the indices of the
%  rho values that were outside the limits either in center or the
%  periphery of the unit circle.
%

% Copyright 2008-2008 Fabian Kloosterman

if strcmp(rdir, 'normal')
    rho = (rho - lim(1)) ./ diff(lim);
else
    rho = (lim(2) - rho) ./ diff(lim);
end

idx_low = find(rho<0);
idx_high = find(rho>1);

switch method
 case 'nan'
  rho( rho<0 | rho>1 ) = NaN;
 case 'zero'
  rho( rho<0 | rho>1 ) = 0;
 case 'clip'
  rho( rho<0 ) = 0;
  rho( rho>1 ) = 1;
 otherwise
  %no clipping
end