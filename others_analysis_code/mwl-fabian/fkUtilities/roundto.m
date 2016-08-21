function m = roundto( m, f )
%ROUNDTO round numbers
%
%  m=ROUNDTO(m) round m to nearest integer.
%
%  m=ROUNDTO(m, f) round m to nearest multiple of f. 
%
%  Example
%    roundto( [3.4 4.8] ) %returns [3 5]
%    roundto( [3.3 5.7], 0.25 ) %returns [3.25 5.75]
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(f)
  m = round(m);
elseif ~isscalar(f)
  error('roundto:invalidArgument', 'F should be a scalar')
else
  m = f.*round(m./f);
end
