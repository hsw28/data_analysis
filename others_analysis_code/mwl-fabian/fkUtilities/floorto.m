function m = floorto( m, f )
%FLOORTO round towards -Inf
%
%  m=FLOORTO(m) round m to nearest smaller integer.
%
%  m=FLOORTO(m, f) round m to nearest smaller multiple of f. 
%
%  Example
%    floorto( [3.4 4.8] ) %returns [3 4]
%    floorto( [3.3 5.7], 0.25 ) %returns [3.25 5.5]
%

%  Copyright 2006-2008 Fabian Kloosterman

if nargin<2 || isempty(f)
  m = floor(m);
elseif ~isscalar(f)
  error('floor:invalidArgument', 'F should be a scalar')
else
  m = f.*floor(m./f);
end
