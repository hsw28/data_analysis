function r = fcorrcoef( f, g, limits, tol )
%FCORRCOEF correlation coefficient of two functions
%
%  r=FCORRCOEF(f,g) correlation coefficient of the two functions f and g
%  over the range [0 2pi].
%
%  r=FCORRCOEF(f,g,limits) returns the correlation coefficient over the
%  specified limits.
%
%  r=FCORRCOEF(f,g,limits,tol) sets the tolerance for the integrating
%  quad function.
%


%  Copyright 2005-2008 Fabian Kloosterman


%check input arguments
if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty(limits)
    limits = [0 2*pi];
end

if nargin<4 || isempty(tol)
    tol = 1e-6;
end

%compute integrals
i1 = quad( f, limits(1), limits(2), tol);
i2 = quad( g, limits(1), limits(2), tol);
i3 = quad( @(x) f(x).^2, limits(1), limits(2), tol);
i4 = quad( @(x) g(x).^2, limits(1), limits(2), tol);
i5 = quad( @(x) f(x).*g(x), limits(1), limits(2), tol);

d = diff(limits);

%compute correlation coefficient
r = ( d.*i5 - i1.*i2 ) ./ ( sqrt(d.*i3 - i1.^2) .* sqrt(d.*i4 - i2.^2) );
