function varargout=matrixfun(m,fcn,dim)
%MATRIXFUN perform function on matrix for 1 or more dimensions
%
%  [...]=MATRIXFUN(m,function) for array m, will perform the specified
%  function along the first dimension. The function argument should be a
%  valid function handle that takes an array as the first input and the
%  dimension along which to work as the second input. Functions that do not
%  adhere to this convention should be wrapped into an anonymous function
%  handle (i.e. @(m,d) var(m,1,d))
%
%  [...]=MATRIXFUN(m,function,dims) will perform function on the collective
%  dimensions specified in dims.

%  Copyright 2008-2011 Fabian Kloosterman

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

if nargin<3
    dim = 1;
elseif isempty(dim)
    return
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

[varargout{1:nargout}] = fcn( reshape( permute( m, [dim otherdim] ), [prod(sz(dim)) sz(otherdim) 1] ) , 1 );
varargout = cellfun( @(z) ipermute( reshape(z, [ones(1,numel(dim)) sz(otherdim) 1] ), [dim otherdim] ), varargout, 'UniformOutput', false );


%alternative method, generally faster, but not as widely applicable (i.e.
%a function that would compute the difference between max and min wouldn't
%work)

%for k=1:numel(dim)
    
%    m = fcn(m, dim(k));
    
%end
