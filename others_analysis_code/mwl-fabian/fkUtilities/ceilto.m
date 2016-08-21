function m = ceilto( m, f )
%CEILTO round towards Inf
%
%  m=CEILTO(m) round m to nearest larger integer.
%
%  m=CEILTO(m, f) round m to nearest larger multiple of f. 
%
%  Example
%    ceilto( [3.4 4.8] ) %returns [4 5]
%    ceilto( [3.3 5.7], 0.25 ) %returns [3.5 5.75]
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(f)
  m = ceil(m);
elseif ~isscalar(f)
  error('ceilto:invalidArgument', 'F should be a scalar')
else
  m = f.*ceil(m./f);
end
