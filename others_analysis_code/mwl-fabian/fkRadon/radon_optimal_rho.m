function [drho, rho_range, R] = radon_optimal_rho( dx, dy, M, N, theta_range, rho_x)
%RADON_OPTIMAL_RHO compute optimal rho range and spacing
%
%  [drho,range,n]=RADON_OPTIMAL_RHO(dx,dy,m,n)
%
%  [drho,range,n]=RADON_OPTIMAL_RHO(dx,dy,m,n,thetarange)
%
%  [drho,range,n]=RADON_OPTIMAL_RHO(dx,dy,m,n,thetarange,rho_x)
%
  
if nargin<4
  help(mfilename)
  return
end

if nargin<5 || isempty(theta_range) || all(theta_range==[-0.5 0.5]*pi)
  val = sqrt((dy./dx).^2+1);
else
  if numel(theta_range)~=2
    error('radon_optimal_rho:invalidArgument','Invalid theta range')
  end
  if theta_range(1)>theta_range(2)
    theta_range(1)=theta_range(1)+2*pi;
  end
  f = @(x) -min( 1./abs(sin(x)), dy./(dx.*abs(cos(x))));
  [dummy, val] = fminbnd( f, theta_range(1), theta_range(2) ); %#ok
  val = -val;
end

if nargin<6 || isempty(rho_x)
  rho_x = 0;
end

drho = dy./val;

xmin = -dx.*(M-1)./2;
ymin = -dy.*(N-1)./2;

if rho_x
  
  rho_max = abs(xmin);
  R = 2*rho_max./drho+1;
  rho_range = [-drho.*(R-1)./2 rho_max];
  
else
  
  if nargin<5 || isempty(theta_range) || all(theta_range==[-0.5 0.5]*pi)
    rho_max = sqrt( xmin.^2 + ymin.^2 );
    R = 2*rho_max./drho+1;
    rho_range = [-drho.*(R-1)./2 rho_max];
  else
    
    L = [xmin ymin ; xmin -ymin ; -xmin ymin ; -xmin -ymin ];
    minrho = Inf;
    maxrho = -Inf;
    
    rhofcn = @(theta, xy) xy(1).*cos(theta) + xy(2).*sin(theta);

    for k=1:4
      [dummy, tmp] = fminbnd( @(x) -rhofcn(x, L(k,:) ), theta_range(1), theta_range(2));%#ok
      maxrho = max( maxrho, -tmp);
      [dummy, tmp] = fminbnd( @(x) rhofcn(x, L(k,:) ), theta_range(1), theta_range(2));%#ok
      minrho = min( minrho, tmp);    
    end
    
    rho_range = [minrho maxrho];
    R = diff(rho_range)./drho+1;
  end
  
end
