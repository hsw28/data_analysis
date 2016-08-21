function varargout = seg_filter(segments, events, n_min, n_max)
%SEG_FILTER select segments
%
%  seg=SEG_FILTER(segments,events) returns all segments that contain at
%  least one event.
%
%  seg=SEG_FILTER(segments,events,nmin) returns all segments that
%  contains at least nmin events.
%
%  seg=SEG_FILTER(segments,events,nmin,nmax) returns all segments that
%  contains at least nmin and at most nmax events.
%
%  [seg,i]=SEG_FILTER(...) also returns the indices of the returned
%  segments in the original segments list. I.e. seg=segments(i,:).
%

%  Copyright 2005-2008 Fabian Kloosterman

if (nargin<2)
    help(mfilename)
    return
end

if (size(segments,2) ~= 2) || (size(segments,1)<1 || ~isnumeric(segments))
    error('seg_filter:invalidSegments', 'First argument is an invalid or empty list of segments')
end

if ~isnumeric(events)
    error('seg_filter:invalidArgument', 'Second argument is invalid event time vector')
end

if (nargin<3 || isempty(n_min))
    n_min = 1;
end

if (nargin<4 || isempty(n_max))
    n_max = n_min;
end

idx = [];

%loop through all segments
for s = 1:size(segments,1)
    n = length(find(events>=segments(s,1) & events<=segments(s,2)));
    if (n>=n_min && n<=n_max)
        idx(end+1) = s;
    end
end

varargout{1} = segments(idx, 1:2);

if nargout>1
    varargout{2} = idx;
end
