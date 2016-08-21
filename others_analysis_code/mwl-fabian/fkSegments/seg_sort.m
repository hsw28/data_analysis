function [seg, ind] = seg_sort( seg )
%SEG_SORT sort a list of segments on the segment start time
%
%  seg=SEG_SORT(segments) sorts segments based on start time
%
%  [seg,i]=SEG_SORT(segments) also returns the indices of the sorted
%  segments into the original segment list. I.e. seg=segments(i,:).
%

%  Copyright 2005-2008 Fabian Kloosterman


%check input argument
if (nargin~=1)
    help seg_sort
    return
end

if isempty( seg )
    ind = [];
    return
end
    

if (size(seg, 2) ~= 2) || (size(seg,1)<1)
    error('seg_sort:invalidSegments', 'Expecting a nx2 matrix of segment start and end times (n>0)')
end

%sort

[seg(:,1), i] = sort(seg(:,1));
seg(:,2) = seg(i,2);

if (nargout>1)
    ind = i;
end
