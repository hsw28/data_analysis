function [pks, settings] = radon_peaks( M, varargin )
%RADON_PEAKS find peaks in radon transform (rectangular neighborhood)
%
%  peaks=RADON_PEAKS(m)
%
%  peaks=RADON_PEAKS(m,parm1,val1,...)
%   theta - 
%   rho - 
%   threshold - 
%   nhoodtheta - 
%   nhoodrho - 
%   npeaks - 
%
%  [peaks,options]=RADON_PEAKS(...)
%


if nargin<1 || isempty(M)
  help(mfilename)
  return
end

%M should be of size ntheta x nrho

args = struct( 'theta', [], ...
               'rho', [], ...
               'threshold', [], ...
               'nhoodtheta', [], ...
               'nhoodrho', [], ...
               'npeaks', Inf ...
               );

args = parseArgs(varargin, args);

[sx, sy] = size( M );

cr = [0 2*pi];

if isempty(args.theta)
  args.theta = 1:sx;
  cr = [1 sx];
elseif numel(args.theta)~=sx
  error('radon_peaks:invalidArgument', 'Incorrect length of theta vector')
end
if isempty(args.rho)
  args.rho = 1:sy;
elseif numel(args.rho)~=sy
  error('radon_peaks:invalidArgument', 'Incorrect length of rho vector')
end

args.rho = args.rho(:);
args.theta = args.theta(:);

if isempty(args.nhoodtheta)
  args.nhoodtheta = (max(args.theta)-min(args.theta) ) ./ 10;
end

if isempty(args.nhoodrho)
  args.nhoodrho = (max(args.rho)-min(args.rho) ) ./ 10;
end

if isempty(args.threshold)
  args.threshold = 0.75.*max(M(:));
end

if isempty(args.npeaks)
  args.npeaks = Inf;
end

done = false;
pks = [];

Mold = M;

while ~done
  
  [dummy, max_idx] = max( M(:) ); %#ok
  [p,q] = ind2sub([sx sy], max_idx);
  
  p = p(1); q = q(1);
  
  nhood = Mold( max(1,(p-1)):min(sx,(p+1)), max(1,(q-1)):min(sy,(q+1)) );
  
  if (M(p,q) >= args.threshold)
    
    if all( nhood(:)<=M(p,q) )
      pks(end+1,:) = [args.theta(p), args.rho(q), M(p,q)];
    end
  
    if args.nhoodtheta==0
      theta_idx = p;
    else
      theta_idx = circ_inrange(args.theta, args.theta(p)+[-1 1].* ...
                               (args.nhoodtheta), cr);
    end
    if args.nhoodrho==0
      rho_idx = q;
    else
      rho_idx = inrange(args.rho, args.rho(q)+[-1 1].*(args.nhoodrho));
    end
    M( theta_idx, rho_idx ) = -Inf;
    
    done=(size(pks,1)==args.npeaks);
    
  else
    
    done=true;
    
  end
  
end
% $$$ 
% $$$ indx = find( imregionalmax( M ) );
% $$$ indx = indx( M(indx)>args.threshold );
% $$$ [p,q] = ind2sub( [sx, sy], indx );
% $$$ pks = [args.theta(p) args.rho(q)];


settings = args;
