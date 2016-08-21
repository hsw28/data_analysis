function seg = event2seg(on, off, varargin)
%EVENT2SEG create a list of segments from two event series
%
%  seg=EVENT2SEG(on_event,off_event) construct segments that start at
%  on_event times and end at off_event times.
%
%  seg=EVENT2SEG(on_event,off_event,parm1,val1,...) specifiy additional
%  parameter/value options. Valid parameters are:
%   GreedyStart - true/false, if more than one ON event occurs without an
%    OFF event, then when GreedyStart is true (false) the first (last) ON
%    event is taken as the start of the segment.
%   GreedyEnd - tru/false, if more than one OFF event occurs without an
%    ON event, then when GreedyEnd is true (false) the last (first) OFF
%    event is taken as then end of the segment.
%


%  Copyright 2005-2007 Fabian Kloosterman

Args = struct('GreedyStart', false, 'GreedyEnd', false);

if nargin<2
    help(mfilename)
    return
end

if ~isnumeric(on) || ~isnumeric(off)
    error('Invalid on / off event series.')
end

Args = parseArgs(varargin, Args);

on = on(:);
off = off(:);

events = [on(:) ; off(:)];

eventid = [ones(length(on),1) ; -ones(length(off),1)];

[events, isort] = sort(events);

eventid = eventid(isort);

diff_eventid = diff( eventid );

%if GreedyStart then remove all on-event blocks, except the first event in
%the block
if Args.GreedyStart
    invalid = find( diff_eventid == 0 & eventid(2:end)==1 ) + 1;
else
    invalid = find( diff_eventid == 0 & eventid(1:end-1)==1 );
end

%if GreedyEnd then remove all off-event blocks, except the last event in
%the block
if Args.GreedyEnd
    invalid = [invalid ; find( diff_eventid == 0 & eventid(1:end-1)==-1 ) ];
else
    invalid = [invalid ; find( diff_eventid == 0 & eventid(2:end)==-1 ) + 1 ];
end    

events(invalid) = [];
eventid(invalid) = [];
    
%find all on/off event pairs

seg = find(diff( eventid ) == -2);

seg = [events(seg(:)) events(seg(:)+1)];

