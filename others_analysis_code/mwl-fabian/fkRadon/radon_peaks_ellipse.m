function pks = radon_peaks_ellipse(M, varargin)
%RADON_PEAKS_ELLIPSE find peaks in radon transform (elliptical neighborhood)
%
%  peaks=RADON_PEAKS_ELLIPSE(m)
%
%  peaks=RADON_PEAKS_ELLIPSE(m,parm1,val1,...)
%   theta - 
%   rho - 
%   threshold - 
%   ellipse - 
%   npeaks - 
%


if nargin<1 || isempty(M)
  help(mfilename)
  return
end

[sx, sy] = size(M);

args = struct( 'theta', [], ...
               'rho', [], ...
               'threshold', [], ...
               'ellipse', [1 1], ...
               'npeaks', Inf ...
               );

args = parseArgs(varargin, args);

if isempty(args.theta)
  args.theta = 1:sx;
elseif numel(args.theta)~=sx
  error('radon_peaks_ellipse:invalidArgument', 'Incorrect length of theta vector')
end
if isempty(args.rho)
  args.rho = 1:sy;
elseif numel(args.rho)~=sy
  error('radon_peaks_ellipse:invalidArgument', 'Incorrect length of rho vector')
end
if isempty(args.ellipse)
  args.ellipse = [1 1];
elseif ~numel(args.ellipse)==2
  error('radon_peaks_ellipse:invalidArgument', 'Incorrect ellipse parameters')
end
args.rho = args.rho(:);
args.theta = args.theta(:);

if isempty(args.threshold)
  args.threshold = 0.75.*max(M(:));
end

if isempty(args.npeaks)
  args.npeaks = Inf;
end

pks = [];

if args.npeaks<1
  return
end

Idx = find( M(:) >= args.threshold );
[sM, sIdx] = sort( M( Idx(:) ), 1, 'descend' );
[dummy, sIr] = sort( sIdx, 1); %#ok

for k=1:numel(sM)
  
  %check validatity
  if isnan(sM(k))
    continue
  end
  
  %check neighborhood
  [p,q] = ind2sub([sx sy], Idx(sIdx(k)));
  nhood = M( max(1,(p-1)):min(sx,(p+1)), max(1,(q-1)):min(sy,(q+1)) );
  
  if ~all( nhood(:) <= sM(k) )
    continue
  end
  
  %check ellipse 
% $$$   bidx = [];
% $$$   for n=1:numel(args.theta)
% $$$     b = find( inellipse( args.rho, args.theta(n), args.ellipse(1), args.ellipse(2), ...
% $$$                    args.rho(q), args.theta(p)) );
% $$$     bidx = [bidx; sub2ind( [sx,sy], repmat(n,numel(b),1), b )];
% $$$   end
  
  V = find( args.rho>=args.rho(q)-args.ellipse(1) & args.rho<= ...
            args.rho(q)+args.ellipse(1) );
  W = find( args.theta>=args.theta(p)-args.ellipse(2) & args.theta<= ...
            args.theta+args.ellipse(2) );
  
  [V,W] = meshgrid( V, W );
  
  L = inellipse( args.rho(V), args.theta(W), args.ellipse(1), args.ellipse(2), ...
                 args.rho(q), args.theta(p) );
  
  bidx = sub2ind( [sx,sy], W(L), V(L) );
  
  if any(M(bidx)>sM(k))
    continue
  else
    pks(end+1,:) = [args.theta(p), args.rho(q), sM(k)];      
    sM( sIr( ismember(Idx, bidx ) ) ) = NaN;
  end

  if size(pks,1)==args.npeaks
    break;
  end  
  
end  
  
  
