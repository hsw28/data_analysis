function e=ientropy( p, base )
%IENTROPY computes entropy of probability distribution
%
%  c=IENTROPY(p) computes the entropy of probability distributions p.
%
%  c=IENTROPY(p,base) computes entropy using the logarithm with the
%  specified base (default=2).
%

if nargin<2 || isempty(base)
    base = 2;
elseif ~isnumeric(base) || ~isscalar(base) || base<=0
    error('ientropy:invalidArgument', 'Invalid base')
end

if nargin<1 || ~isnumeric(p)
    error('ientropy:invalidArgument', 'Invalid probability distribution')
end

p = p(:)./nansum(p(:));

e = -nansum( p.*log(p)./log(base) );