function E=reconstruct_basis(ratemaps,spikecounts,varargin)
%RECONSTRUCT_BASIS stimulus reconstruction using basis-function method
%
%  estimate=RECONSTRUCT_BASIS(ratemap,spikecounts)
%
%  estimate=RECONSTRUCT_BASIS(...,parm1,val1,...)
%   prior - prior for bayesian reconstruction
%   normalization - normalization method (default = 'sum')
%   alpha - rate map scaling factor
%

options = struct('prior', [], ...
                 'normalization', 'sum', ...
                 'alpha', 1);

[options,other, remainder] = parseArgs(varargin,options); %#ok

sz = size(ratemaps);

nt = size(spikecounts,2);

%collapse dimensions 2...n
if numel(sz)>2
  ratemaps = reshape( ratemaps, [prod(sz(1:(end-1))) sz(end)] );
end

%apply alpha factor
if ~isequal(options.alpha,1)
  if isvector(options.alpha) && numel(options.alpha)==size(spikecounts,1)
    ratemaps = bsxfun(@times, ratemaps, options.alpha(:)' );
  elseif isscalar(options.alpha)
    ratemaps = ratemaps.*options.alpha;
  else
    error('reconstruct_basis:invalidArguments', ['Invalid ' ...
                        'alpha'])
  end
end

%do reconstruction
if ~isempty(options.prior)
  E = ( ratemaps.*repmat(options.prior(:), [1 size(ratemaps,2)]) ) * spikecounts;
else
  E = ratemaps*spikecounts;
end

%normalize
E = normalize( E, 1, options.normalization );

%"uncollapse" dimensions
if numel(sz)>2
  E = reshape(E, [sz(1:(end-1)) nt] );
end
