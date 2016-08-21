function p=semipcorr(x,y,z)
%SEMIPCORR semi-partial correlation
%
%  p=SEMIPCORR(x) returns the semi-partial correlation matrix for all
%  variables (columns) in x. Each element p(i,j) is the semi-partial
%  correlation coefficient of variables i and j, with the influence of
%  all other variables removed from j only.
%
%  p=SEMIPCORR(x,y,z) returns the semi-partial correlation between x and
%  y, with the influence of z removed from y.
%


if nargin<1
  help(mfilename)
  return
end

if nargin==1
  omega = corr(x);
  inv_omega = pinv(omega);
  d = diag(inv_omega);
  
  p = -inv_omega.*sqrt(det(omega)) ./ sqrt(d*ones(1,size(x,2)));
  
elseif nargin==3
  
  p = ( corr(x,y) - corr(x,z).*corr(y,z) ) ./ sqrt(1-corr(y,z)^2);
  
else
  
  error('semipcorr:invalidArguments', 'Incorrect number of arguments')
  
end