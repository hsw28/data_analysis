function M = randcycle( M, dim )
%RANDCYCLE randomly cycles columns or rwos
%
%  m=RANDCYCLE(m) randomly shifts and cycles columns of matrix m.
%
%  m=RANDCYCLE(m,dim) randomly shifts and cycles along specified
%  dimension.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

if nargin<2 || isempty(dim)
  dim = 1;
end

if ~isnumeric(M) || ndims(M)>2
  error('randcycle:invalidMatrix', 'Invalid matrix');
end

if ~isscalar(dim) || ~isnumeric(dim) || dim<1 || dim>2
  error('randcycle:invalidDimension','Invalid dimension');
end

[nrows, ncols] = size(M);

[r,c] = ndgrid( 1:nrows, 1:ncols);

if dim==1
  rr = unidrnd( nrows, [1 ncols]); %randsample( 0:(nrows-1), ncols, true );
  r = mod( r + repmat(rr, nrows, 1) - 2, nrows ) + 1;
  M = M( sub2ind( [nrows ncols], r, c ) );
else
  cc = unidrnd( ncols, [nrows 1]); %randsample( 0:(ncols-1), nrows, true );
  c = mod( c + repmat(cc, 1, ncols) - 2, ncols ) + 1;
  M = M( sub2ind( [nrows ncols], r, c ) );  
end
