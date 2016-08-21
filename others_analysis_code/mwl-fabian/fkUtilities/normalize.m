function m = normalize( m, dimension, option, nancheck )
%NORMALIZE normalizes an array
%
%  m=NORMALIZE(m) normalize matrix m to the sum along the first
%  dimension.
%
%  m=NORMALIZE(m,dimension) normalize along the specified
%  dimension(s). If dimension=0, then the matrix will be normalized
%  as a whole. If dimensions is a vector, then normalization will
%  occur within the subspace defined by those dimensions (e.g. for
%  a 3-d matrix, setting dimension to [1 2] will normalize each x,y
%  plane)
%
%  m=NORMALIZE(m,dimension,option) normalize using the specified
%  option. Valid options are:
%   sum - normalize to the sum
%   area - normalize to the area (i.e. sum of absolute values)
%   mean - normalize to mean
%   max - normalize to max
%   min - normalize to min
%   extreme - normalize to extreme value
%   amp - normalize to maximum-minimum
%   range - subtract minimum and normalize to maximum-minimum
%   zscore - subtract mean and normalize to standard deviation
%   detrend - subtract mean
%
%  m=NORMALIZE(m,dim,option,1) ignores NaNs
%


%  Copyright 2005-2008 Fabian Kloosterman

valid_options = {'sum', 'area', 'mean', 'max', 'min', 'extreme', 'amp', 'range', 'zscore', 'detrend'};

%check input arguments
if nargin<1
  help(mfilename)
  return
end

if nargin<2 || isempty(dimension)
  dimension = 1;
end

if nargin<3  || isempty(option)
  option = 'sum';
end

if nargin<4 || isempty(nancheck)
  nancheck=0;
end

if ~isnumeric(dimension) || ( any( dimension<1 | dimension>ndims(m) ) && ~isequal(dimension,0))
  error('normalize:invalidArguments', 'Invalid dimension')
end

if ~ismember( option, valid_options )
  return %fail quietly
end

if isequal(dimension,0)
    dimension = 1:ndims(m);
else
    dimension = dimension(:)';
end

%temporarily turn off warning
w = warning( 'off', 'MATLAB:divideByZero');

%normalization
switch option
  
 case 'sum'

  if nancheck
    tmp = matrixfun( m, @nansum, dimension );
  else
    tmp = matrixfun( m, @sum, dimension );
  end
  
  m = bsxfun( @rdivide, m, tmp);
 
 case 'area'
  
  if nancheck
    tmp = matrixfun( abs(m), @nansum, dimension );
  else
    tmp = matrixfun( abs(m), @sum, dimension );
  end  

  m = bsxfun( @rdivide, m,tmp);
  
 case 'mean'
  
  if nancheck
    tmp = matrixfun( m, @nanmean, dimension );
  else
    tmp = matrixfun( m, @mean, dimension );
  end
  
  m = bsxfun(@rdivide, m, tmp);
 
 case 'max'
  
  if nancheck
    tmp = matrixfun( m, @(x,d) nanmax(x,[],d), dimension );
  else
    tmp = matrixfun( m, @(x,d) max(x,[],d), dimension );
  end

  m = bsxfun(@rdivide,m,abs(tmp));
  
 case 'min'
  
  if nancheck
    tmp = matrixfun( m, @(x,d) nanmin(x,[],d), dimension );
  else
    tmp = matrixfun( m, @(x,d) min(x,[],d), dimension );
  end
  
  m = bsxfun(@rdivide,m,abs(tmp));
 
 case 'extreme'
 
  if nancheck
    tmp = matrixfun( abs(m), @(x,d) nanmax(x,[],d), dimension );
  else
    tmp = matrixfun( abs(m), @(x,d) max(x,[],d), dimension );
  end

  m = bsxfun(@rdivide,m,tmp);
  
 case 'amp'
  
  if nancheck
    tmp = matrixfun( m, @(x,d) nanmax(x,[],d)-nanmin(x,[],d), dimension );
  else
    tmp = matrixfun( m, @(x,d) max(x,[],d)-min(x,[],d), dimension );
  end

  m = bsxfun(@rdivide,m,tmp);
 
 case 'range'
  
  if nancheck
    tmp1 = matrixfun( m, @(x,d) nanmax(x,[],d), dimension );
    tmp2 = matrixfun( m, @(x,d) nanmin(x,[],d), dimension );
  else
    tmp1 = matrixfun( m, @(x,d) max(x,[],d), dimension );
    tmp2 = matrixfun( m, @(x,d) min(x,[],d), dimension );
  end

  m = bsxfun(@rdivide, bsxfun(@minus, m, tmp2), tmp1-tmp2 );
  
 case 'zscore'
  
  if nancheck
    m = bsxfun( @rdivide, bsxfun( @minus, m, matrixfun( m, @nanmean, dimension ) ), matrixfun( m, @(x,d) nanstd(x,[],d), dimension) );
  else
    m = bsxfun( @rdivide, bsxfun( @minus, m, matrixfun( m, @mean, dimension ) ), matrixfun( m, @(x,d) std(x,[],d), dimension) );
  end
  
 case 'detrend'
  
  if nancheck
    m = bsxfun( @minus, m, matrixfun( m, @nanmean, dimension ) );
  else
    m = bsxfun( @minus, m, matrixfun( m, @mean, dimension ) );
  end
  
 otherwise
  
end

%restore warning
warning( w.state, 'MATLAB:divideByZero');

