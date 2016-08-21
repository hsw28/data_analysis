function m=matrixfun(m,fcn,dim)
%MATRIXFUN perform function on matrix for 1 or more dimensions
%
%  m=MATRIXFUN(m,function) for a n-d matrix m, will perform the specified
%  function along the first dimension. The function argument should be a
%  valid function handle that takes a matrix as the first input and the
%  dimension along which to work as the second input. Functions that do not
%  adhere to this convention should be wrapped into an anonymous function
%  handle (i.e. @(m,d) var(m,1,d))
%
%  m=MATRIXFUN(m,function,dims) will perform function on the collective
%  dimensions specified in dims.

%  Copyright 2008-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if ~isnumeric(m)
    error('matrixfun:invalidArgument', 'Invalid matrix');
end

if isempty(m)
    return
end

sz = size(m);
nd = ndims(m);

if ischar(fcn)
    fcn = str2func(fcn);
elseif ~isa(fcn,'function_handle')
    error('matrixfun:invalidArgument', 'Invalid function');
end

if nargin<3 || isempty(dim)
    dim = 1;
elseif ~isnumeric(dim) || ~isvector(dim) || any( dim<1 )
    error('matrixfun:invalidArgument', 'Invalid dimension vector');
end

dim = round(dim(:)');

if max(dim)>nd
    nd = max(dim);
    sz(end+1:nd) = 1;
end
    
otherdim = 1:nd;
otherdim(dim)=[];

m = fcn( reshape( permute( m, [dim otherdim] ), [prod(sz(dim)) sz(otherdim) 1] ) , 1 );
m = ipermute( reshape(m, [ones(1,numel(dim)) sz(otherdim) 1] ), [dim otherdim] );


%alternative method, generally faster, but not as widely applicable (i.e.
%a function that would compute the difference between max and min wouldn't
%work)

%for k=1:numel(dim)
    
%    m = fcn(m, dim(k));
    
%end
