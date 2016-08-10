function kernel = gaussn( sd, dx, n )
%GAUSSN create gaussian kernel
%
%  kernel=GAUSSN returns a 1d gaussian kernel with a 1 sample standard
%  deviation.
%
%  kernel=GAUSSN(sd) returns a gaussian kernel with specified standard
%  deviations for each dimension. The kernel will have as many dimensions
%  as the vector sd is long. 
%
%  kernel=GAUSSN(sd,dx) specifies for each dimension the sampling
%  interval. Standard deviations are measured in the same units as the
%  sampling interval. Either sd or dx can be a scalar.
%
%  kernel=GAUSSN(sd,dx,n) the size of the kernel is round(n*sd/dx),
%  i.e. the kernel is n standard deviations wide on either side of the
%  mean. By default n=4.
%
%
%  Example
%    kernel = gaussn( [1 2], 1 );
%    imagesc( kernel );
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1 || isempty(sd)
  sd = 1;
end

if nargin<2 || isempty( dx )
  dx = 1;
end

%expand scalar inputs
if isscalar(sd)
  sd = ones( size(dx) ) .* sd;
elseif isscalar(dx)
  dx = ones( size(sd) ) .* dx;
elseif numel(sd) ~= numel(dx)
  error( 'gaussn:invalidArguments', 'Incompatible sizes of sd and dx vectors' )
end

if nargin<3 || isempty(n)
  n = 4;
end

%replace zero standard deviations by a very small number
%if any(sd==0)
%  sd(sd==0) = eps; %to prevent the algorithm from blowing up
%end

%deal with zero sd dimensions
valid_sd = sd~=0;
nvalid = sum( valid_sd(:) );
perm_dim( 1, valid_sd ) = 1:nvalid;
perm_dim( 1, ~valid_sd) = (nvalid+1):numel(sd);
sd(~valid_sd)=[];
dx(~valid_sd)=[];

if any(isnan(sd)) || any(isinf(sd)) || any(dx==0) || any(isnan(dx)) || ...
      any(isinf(dx))
  error('gaussn:invalidArguments', 'Invalid standard deviations and/or sample frequencies')
end

%make sure sd anf fs are column vectors
sd = sd(:);
dx = dx(:);

nd = numel(sd);

%calculate size of kernel
npoints = round( n.*sd./dx );

%construct N-D grid
d = cell(nd,1);

for k=1:nd
  d{k} = linspace( -n.*sd(k), n.*sd(k), 2.*npoints(k)+1 );
end

g = cell( nd, 1 );

[g{1:nd}] = ndgrid( d{:}, 1 );

s = size(g{1});

g = reshape(cat( nd+1, g{:} ), [prod(s) nd]);

%construct n-dimensional gaussian kernel
kernel =  reshape( mvnpdf( g, [], diag(sd.^2) ), s );

if numel(perm_dim)>1
  kernel = permute( kernel, perm_dim );
end

%OBSOLETE:
%optionally use the lightspeed library
%kernel = reshape( normpdf_nd( g', [], diag(sd) ), s );

