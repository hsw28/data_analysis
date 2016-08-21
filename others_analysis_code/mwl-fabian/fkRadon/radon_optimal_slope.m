function dslope = radon_optimal_slope( dx, dy, M )
%RADON_OPTIMAL_SLOPE compute optimal slope sampling
%
%  dslope=RADON_OPTIMAL_SLOPE(dx,dy,m)
%

if nargin<2
  help(mfilename)
  return
end

xmax = dx.*(M-1)./2;

dslope = dy./xmax;
