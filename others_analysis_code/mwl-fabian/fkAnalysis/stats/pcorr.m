function p=pcorr(x,y,z)
%PCORR partial correlation
%
%  p=PCORR(x) returns the partial correlation matrix for all variables
%  (columns) in x. Each element p(i,j) is the partial correlation of
%  variable i and j, with the influence af all other variables removed.
%
%  p=PCORR(x,z) returns the correlation matrix for all variables
%  (columns) in x, with the influence of the variables in z removed.
%
%  p=PCORR(x,y,z) returns the partial correlation between x and y, with
%  the influence of z removed from both x and y.
%

if nargin<1
  help(mfilename)
  return
end

if nargin==1
  omega = corr(x);
  inv_omega = pinv(omega);
  d = diag(inv_omega);
  
  p = -inv_omega./sqrt(d*d');
  
elseif nargin==2
  
  c = cov( [x,y] );
  nx=1:size(x,2);
  ny=nx(end)+(1:size(y,2));
  
  c = c(nx,nx) - (c(nx,ny)*inv(c(ny,ny))*(c(nx,ny)'));
  d = diag(c);
  p = c ./sqrt(d*d');
  
else

  p = (corr(x,y) - corr(x,z).*corr(y,z))./(sqrt(1-corr(x,z)^2).*sqrt(1-corr(y,z)^2));
  
end