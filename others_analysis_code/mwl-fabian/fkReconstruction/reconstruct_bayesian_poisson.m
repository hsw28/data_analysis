function E=reconstruct_bayesian_poisson(ratemaps,spikecounts,varargin)
%RECONSTRUCT_BAYESIAN_POISSON stimulus reconstruction using bayesian method
%
%  estimate=RECONSTRUCT_BAYESIAN_POSSION(ratemap,spikecounts)
%
%  estimate=RECONSTRUCT_BAYESIAN_POISSON(...,parm1,val1,...)
%   prior - use prior
%   bins - bin sizes
%   normalization - normalization method (default = 'sum')
%   alpha - rate map scaling factor
%

options = struct('prior', [], ...
                 'bins', [], ...
                 'normalization', 'sum', ...
                 'alpha', 1, ...
                 'baseline', 0.01);

[options,other, remainder] = parseArgs(varargin,options); %#ok


sz = size(ratemaps);

nt = size(spikecounts,2);

%collapse dimensions 2...n
if numel(sz)>2
  ratemaps = reshape( ratemaps, [prod(sz(1:(end-1))) sz(end)] );
end

%process bin sizes
if isempty(options.bins)
  options.bins = ones( 1, nt );
elseif isscalar(options.bins)
  options.bins = options.bins.*ones(1, nt );
elseif isvector(options.bins) && numel(options.bins)==nt
  options.bins = options.bins(:)';
elseif size(options.bins,1)==nt && size(options.bins,2)==2
  options.bins = diff( options.bins, [], 2)';
else
  error('reconstruct_bayesian_poisson:invalidArguments', 'Invalid bins')
end

%apply alpha factor
if ~isequal(options.alpha,1)
  if isvector(options.alpha) && numel(options.alpha)==size(spikecounts,1)
    ratemaps = bsxfun( @times, ratemaps, options.alpha(:)' );
  elseif isscalar(options.alpha)
    ratemaps = ratemaps.*options.alpha;
  else
    error('reconstruct_bayesian_poisson:invalidArguments', ['Invalid ' ...
                        'alpha'])
  end
end

ratemaps=ratemaps+options.baseline; %add very small value to make algorithm robust

%do reconstruction
E = sum( ratemaps, 2 ) * -options.bins;
E = exp( E + bayesian_helper( log(ratemaps), spikecounts ) );

%multiply by prior
if ~isempty(options.prior)
  E = E .* repmat( options.prior(:), [ 1 size(E, 2) ] );
end

%normalize
E = normalize( E, 1, options.normalization,1 );

%"uncollapse" dimensions
if numel(sz)>2
  E = reshape(E, [sz(1:(end-1)) nt] );
end
