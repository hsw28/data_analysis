function [segments,idx] = seg_filterlen( segments, minlen, maxlen )
%SEG_FILTERLEN filters segments on length
%
%  seg=SEG_FILTERLEN(segments,minlen) returns the segments that have at
%  least a length of minlen.
%
%  seg=SEG_FILTERLEN(segments,minlen) returns the segments that have at
%  least a length of minlen and at most a length of maxlen.
%
%  [seg,i]=SEG_FILTERLEN(...) also returns the indices of the filtered
%  segments into the original segments list. I.e. seg=segments(i,:)
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

if nargin<2 || isempty(minlen)
    return
end

if nargin<3 || isempty(maxlen)
    maxlen = Inf;
end

d = diff(segments,1,2);

idx = find( d>=minlen & d<=maxlen );
segments = segments( idx, : );
