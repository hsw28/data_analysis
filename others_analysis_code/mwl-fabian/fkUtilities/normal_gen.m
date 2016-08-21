function f = normal_gen( mu, sigma )
%NORMAL_GEN normal function generator
%
%  f=NORMAL_GEN returns the handle of a function that can be used to
%  generate a normal distribution with mu=0 and sigma=1.
%
%  f=NORMAL_GEN(mu) uses specified mu.
%
%  f=NORMAL_GEN(mu,sigma) uses specified mu and sigma,
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  mu = 0;
end

if nargin<2
  sigma = 1;
end

%generate normal function
f = @(t) exp(-((t-mu).^2)./(2*sigma.^2)) ./ (sigma .* sqrt(2*pi));
