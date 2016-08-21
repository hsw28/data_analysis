function seg = seg_not(varargin)
%SEG_NOT logical NOT on segment lists
%
%  seg=SEG_NOT(seg1,seg2,...) performs the logical NOT operation on the
%  lists of segments.
%
%  seg=SEG_NOT(seg1,seg2,...,'Limits',lim) specifies the outer limits for
%  the NOT operation (default = [-Inf Inf])
%

%  Copyright 2005-2008 Fabian Kloosterman

Args = struct('Limits', [-Inf Inf]);

%check input arguments
if (nargin<1)
    help seg_not
    return
end

try
    [Args,other] = parseArgs(varargin, Args);
catch
    error('seg_not:invalidArguments', 'Error parsing arguments')
end

if isempty(other)
    error('seg_not:invalidSegments','No segments')
end

seg = seg_or(other{:});

if isempty(Args.Limits)
    Args.Limits = [min(seg(:)) max(seg(:))];
end

seg = seg_and(seg, Args.Limits)';

nseg = size(seg, 2);

seg = reshape( [Args.Limits(1);seg(:);Args.Limits(2)], 2, nseg+1 )';

if all(seg(1,:) == [Args.Limits(1) Args.Limits(1)])
    seg(1,:) = [];
end
if all(seg(end,:) == [Args.Limits(2) Args.Limits(2)])
    seg(end,:) = [];
end
