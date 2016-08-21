function seg = seg_check(seg)
%SEG_CHECK check list of segments, remove invalid segments if necessary
%
%  seg=SEG_CHECK(seg) checks validaty of the segments and removes any
%  invalid segments.
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if (nargin<1)
    help(mfilename)
    return
end

if (size(seg,2) ~= 2) || (size(seg,1)<1 || ~isnumeric(seg))
    error('seg_check:invalidSegments','Invalid or empty list of segments')
end

%remove zero and negative length segments
invalid = find(seg(:,1)>=seg(:,2));
if length(invalid)>0
    seg(invalid, :) = [];
    disp(['SEG_CHECK: removed ' num2str(length(invalid)) ' invalid segments.'])
end
