function [data, kernel] = smoothn( data, varargin )
%SMOOTHN smooth data with a gaussian kernel
%
%  m=SMOOTHN(m) smooths matrix with a gaussian with standard deviation of
%  1 in all dimensions.
%
%  m=SMOOTHN(m, sd) uses the specified standard deviation, which either
%  can be a scalar or a vector with standard deviations for each
%  dimension of m.
%
%  m=SMOOTHN(m, sd, dx) specifies the sampling distance dx for each
%  dimension. The standard deviations are measured in the same units as
%  the sampling distance.
%
%  [m,kernel]=SMOOTHN(...) returns the gaussian kernel
%
%  [...]=SMOOTHN(m, width, dx, 'kernel', 'box') uses a box kernel with
%  specified width and sampling distance dx.
%
%  [...]=SMOOTHN(m, ..., parm1, val1, ... ) specifies optional
%  parmater/value pairs. Valid parameters are:
%  nanexcl - 0/1 set NaN value to zero (default=0)
%  correct - 0/1 only include existing values (i.e. no padded zero's or NaNs)
%   in calculating of the smoothed matrix. With this option smoothing of
%   the matrix ones(n) will be all ones, without any edge
%   effects. (default=0)
%  kernel - smoothing kernel to be used, either 'gauss', 'normal', 'box'
%   or a matrix with a user defined kernel. In the latter case, standard
%   deviation and sampling distance parameters are ignored. (default='gauss')
%  normalize - 0/1 normalize kernel such that the sum is one (default=1).
%
%  See also GAUSSN
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

options = struct( 'correct', 0, 'nanexcl', 0, 'kernel', 'gauss', 'normalize', 1, 'my_kernel', []);
[options,other] = parseArgs(varargin, options);

sd = [];
dx = [];

if ~isempty(other)
  sd = other{1};
  if numel(other)>1
    dx = other{2};
  end
end
    
    
%get number of dimensions and size of data
nd = ndims( data );

switch options.kernel
 case 'none'
  return
 case {[],'gauss','normal'}
  if isempty(sd)
    sd = ones( nd,1);
  elseif isscalar(sd)
    sd = ones(nd,1) .* sd;
  else
    sd = sd(1:nd);
  end

  if isempty(dx)
    dx = ones( nd,1);
  elseif isscalar(dx)
    dx = ones(nd,1) .* dx;
  else
    dx = dx(1:nd);
  end

  if isvector( data )
    if size(data,1)==1 %row vector
      sd(1) = 0;
      dx(1) = 1;
    else %column vector
      sd(2) = 0;
      dx(2) = 1;
    end
  end

  %create kernel
  kernel = gaussn( sd, dx );
  
 case {'box'}
  
  if isempty(sd)
    sd = zeros(nd,1)+3;
  elseif isscalar(sd)
    sd = zeros(nd,1)+sd;
  end

  if isempty(dx)
    dx = ones(nd,1);
  elseif isscalar(dx)
    dx = zeros(nd,1)+dx;
  end

  if isvector( data )
    if size(data,1)==1 %row vector
      sd(1) = 0;
      dx(1) = 1;
    else %column vector
      sd(2) = 0;
      dx(2) = 1;
    end
  end

  %create kernel
  npoints = round( sd(:)./dx(:) );
  npoints(npoints==0)=1;
  kernel = ones( npoints' );
 
case 'my_kernel'
  if ~isnumeric( options.my_kernel )
    error('smoothn:invalidArgument', 'Invalid kernel')
  end
  kernel = options.my_kernel;
   
 otherwise
  
  if ~isnumeric( options.kernel )
    error('smoothn:invalidArgument', 'Invalid kernel')
  end
  
  kernel = options.kernel;
  
end

if options.normalize
  kernel = kernel ./ sum( kernel(:) ); 
end
  

  
%exclude NaNs
if options.nanexcl
  idx = find( isnan( data ) );
  data( idx ) = 0;
  
  idx_kernel = find( isnan( kernel) );
  kernel( idx_kernel ) = 0;
  
else
  idx = [];
end

%do convolution
data = convn( data, kernel, 'same' );

%scaling correction
%normally, the data is padded with zeros which tends to reduces the
%smoothed value at the edges, but with the scaling correction
%on, this effect is reduce by ignoring the contribution of those padded
%zeros.

if options.correct
  n = ones( size(data) ) ./ sum(kernel(:));
  n( idx ) = 0;
  n = convn( n, kernel, 'same' );
  n( idx ) = NaN;
  data = data ./ n;
end





