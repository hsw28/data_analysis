function varargout=posterior_mode( m, varargin )
%POSTERIOR_MODE mode of estimate
%
%  [m1,m2,...,mn]=POSTERIOR_MODE(estimate) compute the location of the mode in the n-dimensional
%  estimate (i.e. maximum a posteriori).
%
%  [m1,m2,...,mn]=POSTERIOR_MODE(estimate,n) explicitly specify the number of dimensions
%  (i.e. variables) in the estimate. This is for example required if
%  estimate is a matrix with multiple estimates. I.e. several 2d estimates
%  can be passed in as a 3d matrix, where the first two dimensions are the
%  variables nd the last dimension the number of separate estimates.
%
%  [...]=POSTERIOR_MODE(...,parm1,val1,...) Specify optional parameter/value
%  pairs. Valid options are:
%   marginal - true/false, computes mode of marginals, rather than maximum
%              a posteriori (default=false)
%   grid - cell array of sample grid vectors
%   index - true/false, return index of mode
%

%  Copyright 2008-2010 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

if ~isnumeric(m)
    error('posterior_mode:invalidArgument', 'Invalid estimate matrix');
end

options = struct('marginal', false, 'grid', [], 'vartype', [], 'index', false );
[options,other]=parseArgs(varargin,options);

if isempty(other)
    if isvector(m)
        nd = 1;
    else
        nd = ndims(m);
    end
elseif ~isscalar(other{1}) || other{1}<1
    error('posterior_mode:invalidArgument', 'Invalid ndim argument');
else
    nd = other{1};
end

sz = size(m);
nd_all = ndims(m);

if nd>nd_all
    sz((nd_all+1):nd)=1;
    nd_all = nd;
end

if isempty( options.grid ) || options.index
    g = cell(1,nd);
    for k=1:nd
        g{k} = (1:sz(k))';
    end
elseif ~iscell(options.grid) || numel(options.grid)~=nd || ~all(cellfun( @(z) isnumeric(z) & isvector(z), options.grid )) ...
        || ~isequal( cellfun( 'prodofsize', options.grid(:)' ), sz(1:nd) )
    error('est_mean:invalidGrid', 'Invalid sample grid')
else
    g = cellfun( @(z) z(:), options.grid, 'UniformOutput', false );
end

if ~options.marginal

    %MAP
    [~, idx] = nanmax( reshape( m, [prod( sz(1:nd) ) sz((nd+1):nd_all) 1] ) );
    [varargout{1:nd}] = ind2sub( sz(1:nd), shiftdim(idx,1) );
    varargout = cellfun( @(a,b) a(b), g(:), varargout(:), 'UniformOutput', false );

else
    
    for k=1:nd
    
        %compute marginal
        tmp = matrixfun( m, @nansum, setdiff(1:nd,k) );
    
        [~,mi] = nanmax( tmp, [], k );
        varargout{k} = g{k}( shiftdim( mi, nd ) );

    end
    
end
