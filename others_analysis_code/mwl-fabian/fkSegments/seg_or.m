function seg = seg_or(varargin)
%SEG_OR logical OR on segment lists
%
%  seg=SEG_OR(seg1,seg2,...) performs logical OR operation on lists of
%  segments.
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
narg = length(varargin);
if (narg<1)
    help(mfilename)
    return
end

s = zeros([0,2]);

for i = 1:narg
    if ~isempty(varargin{i}) && (size(varargin{i}, 2)~=2) % | (size(varargin{i}, 1)<1)
        error('seg_or:invalidSegment', ['Expecting a nx2 matrix of segment start and end times (n>0). Error in argument ' num2str(i)])
    elseif ~isempty(varargin{i})
        s = [s ; varargin{i}];
    end
end

s = seg_sort(s);

if isempty(s)
    seg = [];
    return;
end

seg_stack = s(1,:);

if size(s, 1)>1
    for i = 2:length(s)
        if ( seg_stack(end,2) < s(i,1) ) %non-overlapping segments
            seg_stack(end+1,:) = s(i, :);
        elseif ( seg_stack(end,2) >= s(i,1) ) %& ( seg_stack ) %partially overlapping
            seg_stack(end,2) = max( s(i,2), seg_stack(end,2) );
        end
    end
end

seg = seg_stack;
    
        
