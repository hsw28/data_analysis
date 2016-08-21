function r = unifrnd_seg( seg, varargin )
%UNIFRND_SEG uniformly sampled random numbers from a set of segments
%
%  r=UNIFRND_SEG(segs) returns a number sampled randomly from a set of
%  segments. Segs is a nx2 matrix.
%
%  r=UNIFRND_SEG(segs,m,n,...) returns an array of size [m,n,...] with
%  randomly sampled numbers from the segments.
%
%  r=UNIFRND_SEG(segs,[m,n,...]) same as above
%
%  See also UNIFRND
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
  help(mfilename)
  return
end

if ndims(seg)~=2 || size(seg,2)~=2
  error('unifrnd_seg:invalidArguments','Invalid segments')
end

% calculate segment lengths and cumulative sum
d =  diff( seg, 1, 2);
cs = cumsum([0; d]);

% concatenate segments
s = sum( d );

% draw randomly from concatenated segments
rtemp = unifrnd(0,s,varargin{:});

r = zeros(size(rtemp) );

%undo concatenation
for k=1:size(seg,1)
    
    idx = (rtemp>=cs(k) & rtemp<cs(k+1));
    
    r( idx ) = rtemp( idx ) + seg(k,1) - cs(k);
    
end
