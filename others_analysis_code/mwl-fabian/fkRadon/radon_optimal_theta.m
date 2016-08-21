function [dtheta, theta_range, T] = radon_optimal_theta( dx, dy, M, N, theta_range)
%RADON_OPTIMAL_THETA compute optimal theta range and spacing
%
%  [dtheta,range,n]=RADON_OPTIMAL_THETA(dx,dy,m,n) 
%
%  [dtheta,range,n]=RADON_OPTIMAL_THETA(dx,dy,m,n,range)
%


if nargin<4
  help(mfilename)
  return
end

if nargin<5 || isempty(theta_range) || all(theta_range==[-0.5 0.5]*pi)
  theta_range = [-0.5 0.5]*pi;
  val = sqrt((dy./dx).^2+1);
else
  if numel(theta_range)~=2
    error('radon_optimal_theta:invalidArgument', 'Invalid theta range')
  end
  if theta_range(1)>theta_range(2)
    theta_range(1)=theta_range(1)+2*pi;
  end
  f = @(x) -min( 1./abs(sin(x)), dy./(dx.*abs(cos(x))));
  [dummy, val] = fminbnd( f, theta_range(1), theta_range(2) ); %#ok
  val = -val;
end

xmin = -dx.*(M-1)./2;
ymin = -dy.*(N-1)./2;

dtheta = dy ./ (val .* sqrt(xmin.^2+ymin.^2));

T = ceil( diff(theta_range) ./ dtheta );
dtheta = diff( theta_range )./T;
