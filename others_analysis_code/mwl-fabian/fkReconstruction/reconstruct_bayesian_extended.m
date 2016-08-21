function E=reconstruct_bayesian_extended(ratemaps,spikecounts,varargin)
%RECONSTRUCT_BAYESIAN_EXTENDED extended poisson model reconstruction
%
%  e=RECONSTRUCT_BAYESIAN_EXTENDED(ratemaps,spikecounts,...)
%
%  This function was written by Zhe Chen (Sage) zhe.sage.chen@gmail.com
%


options = struct('normalization', 'sum');
[options,other, remainder] = parseArgs(varargin,options); %#ok

sz = size(ratemaps);
nt = size(spikecounts,2);

%collapse dimensions 2...n
if numel(sz)>2
  ratemaps = reshape( ratemaps, [prod(sz(1:(end-1))) sz(end)] );
end

C = ones(size(ratemaps,1),1)./size(ratemaps,1); % to be estimated (sum to 1)

%R = data.spikecount; %/data.timebin;

E = zeros(size(ratemaps,1),nt);

for t=1:nt

  % EM algorithm (assumed if it is a constant)
  for k=1:50
    tmp = bsxfun( @times,ratemaps,C);
    P = bsxfun( @rdivide, tmp, sum(tmp,1) );
    C = (P * spikecounts(:,t) ) / (sum(spikecounts(:,t))+eps);
    
    % local smoothing of C
    C = conv2(C,[0.1 0.2 0.4 0.2 0.1],'same');
    %C = C/sum(C); % normalized to 1
  end
    
  % gradient ascent 
  % problem 1: nonnegative 
  % problem 2: scaling <r> = F*C (equality) 
  
  for k=1:20
    tmp = ratemaps'*C;
    tmp(isnan(tmp)) = 0;
    tmp=tmp+eps;
    alpha = ones(sz(end),1);
    for i=1:sz(2)
      if spikecounts(i,t) == 0; 
        alpha(i) = 1e-5;
      else                
        funct = @(a)(spikecounts(i,t).*log(a) - a.*tmp(i));
        alpha(i) = fzero(funct,1e-4,optimset('Display','off','FunValCheck','off'));
      end
    end
    alpha(isnan(alpha)) = 0;
    grad = ratemaps * (spikecounts(:,t)./tmp) - sum(ratemaps*alpha);      
    newC = C + 0.001 * grad; % gradient ascent       
    newC(newC<0) = 0; newC(isnan(newC)) = 0;
    if sum(newC)>0; C = newC; end
         
  end
  %C = conv2(C,[0.1 0.2 0.4 0.2 0.1],'same');

  E(:,t) = C;
  C = ones(size(ratemaps,1),1)./size(ratemaps,1); %reset
end

%normalize
E = normalize(E,1,options.normalization,1);

%"uncollapse" dimensions
if numel(sz)>2
  E = reshape(E, [sz(1:(end-1)) nt] );
end


