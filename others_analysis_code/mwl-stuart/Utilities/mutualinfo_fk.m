function [mi miVar] = mutualinfo_fk(p,n,base)

if nargin<2 || isempty(base)
    base = 2;
elseif ~isnumeric(base) || ~isscalar(base) || base<=0
    error('mutualinfo:invalidArgument', 'Invalid base')
end

if ~isnumeric(p) || isvector(p) || ndims(p)~=2
    error('mutualinfo:invalidArgument', 'Invalid joint probability distribution')
end

%normalize
p = p./nansum(p(:));

%compute marginals
m1 = nansum( p, 1 );
m2 = nansum( p, 2 );

%compute mutual information
mi = p.*log(p./bsxfun(@times,m1,m2))./log(base);
mi = nansum( mi(:) );

miSq = p.*( log(p./bsxfun(@times,m1,m2))./log(base) ).^2;
miSq = nansum( miSq(:) );

miVar = 1/n * (miSq-mi^2);



