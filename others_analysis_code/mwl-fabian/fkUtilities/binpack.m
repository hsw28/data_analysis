function idx = binpack(element_sizes, total_size)
%BINPACK efficient packing of elements in container
%
%  i=BINPACK(element_sizes,container_size) returns the indices of the
%  elements whose summed size fits best in a container with specified
%  size. If the number of elements > 8 than not all possible permutations
%  are searched, but rather 10000 random permutations.
%

%  Copyright 2007-2008 Fabian Kloosterman

N = length( element_sizes );

%create permutations
if N>8
  [p,p] = sort(rand(10000,N ),2); %#ok
else
  p = perms( 1:N );
end

%find best permutation
cs = cumsum( element_sizes(p), 2 );
g = sum( cs<=total_size, 2 );

valid = find(g>0);

np = size( p,1);
[mxi, mxi] = max( cs( (g(valid)-1).*np + valid  ) ); %#ok

%return indices
idx = sort( p(valid(mxi),1:g(valid(mxi))) );
