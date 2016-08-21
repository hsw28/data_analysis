function p=multicorr(y,x)
%MULTICORR multiple correlation
%
%  p=MULTICORR(x) returns the multiple correlation coefficient
%  for each variable (column) in x with all the remaining variables as
%  predictors.
%
%  p=MULTICORR(y,x) returns the multiple correlation coefficient
%  of y, with x as predictors.
%

if nargin<1
  help(mfilename)
  return
end

if nargin==1
  
  p = corr(y);
  p = pinv(p);
  p = 1 - 1./diag(p);
  
else
  
  p = corr( [y,x] );
  p = pinv(p);
  p = 1 - 1./p(1,1);
  
end

p = sqrt(p);