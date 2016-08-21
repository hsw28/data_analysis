function [fr_total, fr] = firingrate( events, segments)
%FIRINGRATE calculate mean firing rate
%
%  Syntax
%
%      f = firingrate( events, segments )
%

% input is cell array of spike trains and optional matrix of segments

if nargin<1
    help( mfilename )
    return
end

if isnumeric(events)
    events = {events};
end

if ~iscell(events)
    error('Invalid events')
end

n_events = numel(events);

if nargin<2 || isempty(segments)
    segments = [-Inf Inf];
    %calculate segment lengths
    for k = 1:n_events
        sl(k,1) = max( events{k}(:) ) - min( events{k}(:) );
    end
elseif size(segments,2) ~= 2
    error('Invalid segments matrix')
else
    %calculate segment lengths
    sl = diff(segments,1,2); 
end

%select segments
selection = seg_select( segments, events );

%get number of events in each segment for each event series
n = cellfun( 'prodofsize', selection );

%calculate each firing rate for each event series per segment
fr = n ./ repmat( sl, 1, n_events );

%calculate total mean firing rate for each event series
fr_total = sum(n) ./ sum(sl);
