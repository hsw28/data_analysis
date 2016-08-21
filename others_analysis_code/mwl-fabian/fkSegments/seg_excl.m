function seg = seg_excl(segments, varargin)
%SEG_EXCL logical EXCLUSIVE operation on segment lists
%
%  seg=SEG_EXCL(seg1,seg2,...) peforms the logical EXCL operation on the
%  segments passed in. The segments in seg2 and up are excluded from
%  those in seg1. I.e. the operation is: seg1 AND NOT [seg2, seg3,...].
%

%  Copyright 2005-2008 Fabian Kloosterman

if (nargin<1)
    help(mfilename)
    return
end

if (nargin<2)
    try
        seg = seg_check(segments);
        return
    catch
        error('seg_excl:InvalidSegments', 'Invalid segments')
    end
end

seg = seg_and( segments, seg_not( varargin{:} ) );

