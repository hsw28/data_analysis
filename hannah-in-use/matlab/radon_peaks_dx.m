function [pks, settings, sM] = radon_peaks_dx(M, varargin)
%RADON_PEAKS_DX find peaks in radon transform
%
%  peaks=RADON_PEAKS_DX(m)
%
%  peaks=RADON_PEAKS_DX(m,parm1,val1,...)
%   theta - 
%   rho - 
%   threshold - 
%   nhoodx - 
%   npeaks - 
%   ylim - 
%   rho_x - 
%
%  [peaks,options]=RADON_PEAKS_DX(...)
%

if nargin<1 || isempty(M)
  help(mfilename)
  return
end

args = struct( 'theta', [], ...
               'rho', [], ...
               'threshold', [], ...
               'nhoodx', [], ...
               'npeaks', Inf, ...
               'ylim', [], ...
               'rho_x', 0 ...
               );

args = parseArgs(varargin, args);

[sx, sy] = size(M);

if isempty(args.theta)
  args.theta = 1:sx;
elseif numel(args.theta)~=sx
  error('radon_peaks_dx:invalidArgument', 'Incorrect length of theta vector')
end
if isempty(args.rho)
  args.rho = 1:sy;
elseif numel(args.rho)~=sy
  error('radon_peaks_dx:invalidArgument', 'Incorrect length of rho vector')
end

if isempty(args.nhoodx)
  error('radon_peaks_dx:invalidArgument', 'nhoodx argument is required')
end
if isempty(args.ylim)
  error('radon_peaks_dx:invalidArgument', 'ylim argument is required')
end

args.rho = args.rho(:);
args.theta = args.theta(:);

if isempty(args.threshold)
  args.threshold = 0.75.*max(M(:));
end

if isempty(args.npeaks)
  args.npeaks = Inf;
end

if args.rho_x
  fx = @(rho, theta, y) rho-y.*sin(theta);
else
  fx = @(rho, theta, y) rho./cos(theta)-y.*sin(theta);
end
pks = [];

[sM, sI] = sort( M(:), 1, 'descend' );
[dummy, sIr] = sort( sI, 1 ); %#ok

end_idx = find( sM>=args.threshold, 1, 'last' );

for k=1:end_idx
  
  if isnan(sM(k))
    continue;
  end
  
  [p,q] = ind2sub([sx sy], sI(k));
  nhood = M( max(1,(p-1)):min(sx,(p+1)), max(1,(q-1)):min(sy,(q+1)) );
  
  if ~all( nhood(:)<=M(sI(k)) )
    continue;
  end
  
  pks(end+1,:) = [args.theta(p), args.rho(q), sM(k)];

  if size(pks,1)==args.npeaks
    break;
  end
  
  Xymin = fx( pks(end,2), pks(end,1), args.ylim(1) );
  Xymax = fx( pks(end,2), pks(end,1), args.ylim(2) );  
  
  xy = [args.ylim(1) args.ylim(1) args.ylim(2) args.ylim(2)];
  C = [Xymin+args.nhoodx.*[-1 1] Xymax+args.nhoodx.*[-1 1] ];
  
  for n=1:numel(args.theta)
    
    if args.rho_x
      valid = find( ...
          ( C(1) + xy(1)*tan(args.theta(n))<=args.rho ) & ...
          ( C(2) + xy(2)*tan(args.theta(n))>=args.rho ) & ...
          ( C(3) + xy(3)*tan(args.theta(n))<=args.rho ) & ...
          ( C(4) + xy(4)*tan(args.theta(n))>=args.rho ) ...
          );
    else
      valid = find( ...
          ( C(1)*cos(args.theta(n)) + xy(1)*sin(args.theta(n))<=args.rho ) & ...
          ( C(2)*cos(args.theta(n)) + xy(2)*sin(args.theta(n))>=args.rho ) & ...
          ( C(3)*cos(args.theta(n)) + xy(3)*sin(args.theta(n))<=args.rho ) & ...
          ( C(4)*cos(args.theta(n)) + xy(4)*sin(args.theta(n))>=args.rho ) ...
          );
    end
    
    sM( sIr( sub2ind( [sx,sy], repmat(n,numel(valid),1), valid ) ) ) = NaN;
    
  end
  
end

settings = args;

if (nargout>2)
  sM = reshape(sM(sIr), [sx sy] );
end
