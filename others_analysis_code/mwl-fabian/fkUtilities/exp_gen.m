function f = exp_gen( lambda, offset )
%EXP_GEN exponential function generator
%
%  f=EXP_GEN returns a function handle that can be used to generate an
%  exponential function with lambda=1 and offset=0. The exponential
%  function has the following form:
%  f(x):lambda*e^( -lambda*(x-offset) )
%
%  f=EXP_GEN(lambda) uses the specified lambda.
%
%  f=EXP_GEN(lambda, offset) uses the specified lambda and offset.
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  lambda = 1;
end

if nargin<2
  offset = 0;
end

%generate exponential function
f = @(t) lambda .* exp( -lambda.*(t-offset));
