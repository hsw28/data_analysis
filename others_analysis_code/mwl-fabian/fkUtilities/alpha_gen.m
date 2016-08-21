function f = alpha_gen( tau, gain, offset )
%ALPHA_GEN alpha function generator
%
%  f=ALPHA_GEN(tau) returns a function handle that can be used to
%  generate an alpha function with the specified tau parameter, gain=1,
%  and offset=0. Alpha functions can be used to model synaptic input. Tau
%  specifies the time-to-peak, gain is the value at the peak and offset
%  determines the shift along the x-axis. An alpha function has the
%  following form:
%  f(x):gain*((x-offset)/tau)*e^(1-(x-offset)/tau)
%
%  f=ALPHA_GEN(tau,gain) uses the specified gain.
%
%  f=ALPHA_GEN(tau,gain,offset) uses the specified offset.
%
%  Example
%    f=alpha_gen(1,2);
%    fplot( f, [0 10] );
%

%  Copyright 2005-2008 Fabian Kloosterman


%check input arguments
if nargin<1
  help(mfilename)
  return
end

if nargin<2
  gain = 1;
end

if nargin<3
  offset = 0;
end

%generate alpha function
f = @(t) gain.*((t-offset)./tau).*exp(1-(t-offset)./tau);
