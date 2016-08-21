function m = ndmedian( x, weights, option )
%NDMEDIAN compute N-dimensional median
%
%  m=NDMEDIAN(x) computes the median of the nxd matrix x, where n is the
%  number of coordinates and d is the number of dimensions. This function
%  minimizes the mean absolute deviation, E(|x-m|). The function returns
%  a local minimum, which is not guaranteed te be the global minimum.
%
%  m=NDMEDIAN(x,weights) computes weighted median
%
%  m=NDMEDIAN(x,weights, 1) returns the point in x closest to the true median
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1
  help(mfilename)
  return
end

if isempty(x) || size(x,1)==0
  error('ndmedian:invalidArgument', 'Invalid matrix')
end

if nargin<2 || isempty(weights)
    m = fminsearch( @(c) mean( dist2point( x, c ) ), x(1,:) );  
elseif ~isnumeric(weights) || ~isvector(weights) || numel(weights)~=size(x,1)
    error('ndmedian:invalidArgument', 'Invalid weights vector')
else
    m = fminsearch( @(c) mean( weights.*dist2point(x, c) ), x(1,:) );
end


if nargin>2 && isequal( option, true )
  
  [midx, midx] = min( dist2point( x, m ) ); %#ok
  m = x( midx, : );
  
end
