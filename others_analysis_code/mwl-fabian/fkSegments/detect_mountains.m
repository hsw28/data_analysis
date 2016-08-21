function [segs, pks] = detect_mountains( varargin )
%DETECT_MOUNTAINS find segments containing peaks
%
%  segs=DETECT_MOUNTAINS(sig) detects mountains in vector sig and returns
%  the start and end indices.
%
%  segs=DETECT_MOUNTAINS(x,sig) detects the mountains in a signal as a
%  function of x and returns the starts and ends.
%
%  segs=DETECT_MOUNTAINS(...,parm1,val1,...) set optional parameters for
%  mountain detection. Valid parameters are:
%    threshold - threshold, either a single threshold or a lower and a
%                higher threshold. (default = 90% percentile of signal)
%    span_interval - maximum inter-segment interval for combining
%                    segments. (default = 0)
%    width_lim - exclude mountains based on width, either a scalar that
%                specifies the lower limit or a two element vector that
%                specifies lower and upper limits. (default = [])
%    order - order of operations, 1=apply upper threshold, 2=apply width
%            limits, 3=combine small intervals. (default = [1 2 3])
%
%  The general procedure is as follows:
%    1. find all stretches in the data that are above the lower
%       threshold.
%    2. eliminate mountains that never cross the upper threshold (if
%       exists)
%    3. eliminate mountains that are either too wide or too narrow.
%    4. combine mountains that are close together
%

%  Copyright 2005-2008 Fabian Kloosterman


options = struct( 'threshold', [], ...
                  'span_interval', 0, ...
                  'width_lim', [], ...
                  'order', [1 2 3] );

[options,other] = parseArgs(varargin, options );

if ~isempty(other)
  n = numel( other );
  
  if n==1
    
    sig = other{1};
    x = 1:numel(sig);
    convert = 0;
    
  elseif n==2
    
    x = other{1};
    sig = other{2};
    convert = 1;
    
  else
    
    error('detect_mountains:invalidArguments', ['Too many positional ' ...
                        'arguments'])
    
  end
  
else
  
  error('detect_mountains:invalidArguments', 'No signal');
  
end

if isempty(options.threshold)
  
  options.threshold = quantile( sig, 0.9 );
  
end


%find zero crossings
[p2n, n2p] = zerocrossing( sig - options.threshold(1) );

%convert to segments
segs = event2seg( n2p, p2n );

%convert indices to x
if convert
  segs = interp1( 1:numel(x), x, segs );
end

for k=1:numel(options.order)
  
  switch options.order(k)
    
    case 1

     %apply upper threshold
     if numel(options.threshold)>1
       segs = seg_filter( segs, x( sig>options.threshold(end) ), 1, Inf );
     end

   case 2
    %apply width limits
    if ~isempty(options.width_lim)
      duration = diff( segs, 1, 2);
      if isscalar(options.width_lim)
        valid = find( duration>=options.width_lim );
      else
        valid = find( duration>=options.width_lim(1) & ...
                      duration<=options.width_lim(end) );
      end
      segs = segs( valid, : );
    end
    
   case 3
    
    %combine segments with small intervals
    if ~isempty(options.span_interval) && options.span_interval>0
      tmp = segs';
      tmp = diff( tmp(:) );
      tmp = tmp(2:2:end);
      combi_segs = find( tmp<options.span_interval );
      combi_segs = [segs(combi_segs,1) segs(combi_segs+1,2)];
      
      segs = seg_or( segs, combi_segs );
    end
    
  end
  
end

if nargout>1
    
    %let's loop through all segments and find maximum
    if convert
        seg_idx = interp1( x(:), (1:numel(sig))', segs, 'nearest' );
    else
        seg_idx = round( segs );
    end
    
    nsegs = size(segs,1);
    
    pks = struct( 'x', NaN(nsegs,1), 'amp', NaN(nsegs,1) );
    
    for k=1:nsegs
        
        [m, mi] = max( sig( seg_idx(k,1):seg_idx(k,2) ) );
        
        pks.x(k) = x( seg_idx(k,1)-1+mi );
        pks.amp(k) = m;
    
    end
    
end