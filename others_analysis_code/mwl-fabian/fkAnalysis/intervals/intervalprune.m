function [event, ind] = intervalprune(event, minint)
%INTERVALPRUNE remove unwanted intervals from event time vector
%
%  Syntax
%
%      [A, i] = intervalprune( A [, minint] )
%
%  Description
%
%    This function will remove all events from A which follow another event
%    within minint (default = 0.003). The output vector i contains the
%    indices into the original input array of the removed events.
%
%  Example
%
%      e = cumsum( rand(100,1) );
%      new_e = interval_prune( e, 0.1 );
%
%  See also ISI
%

% Copyright 2005-2005 Fabian Kloosterman

if (nargin<1)
    help(mfilename)
    return
end

% check event time vector
if ~isnumeric(event)
    error 'Invalid event vector.'
end

% check minint argument
if nargin<2 || isempty(minint)
    minint = 0.003;
end

% compute intervals
d = diff(event);

% find intervals smaller than minint
ind = find(d<minint) + 1;

% remove corresponding spikes
event(ind) = [];