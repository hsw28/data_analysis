function [event, idx] = burstfilter(event, burst, action)
%BURSTFILTER isolate, remove or reduce bursts in event time list
%
%  Syntax
%
%      [Aout, i] = burstfilter(Ain, B, action)
%
%  Description
%
%    This function will remove events in vector Ain, depending on whether
%    they are part of a burst, as specified by burst vector B. The action
%    that is performed can be one of:
%      'remove' : remove all events in burst
%      'isolate' : remove all events NOT in a burst
%      'reduce' : remove burst events, except for the first one
%      'isolatereduce' : remove all events, except for the first event in
%        a burst
%
%    The output vector i contains indices into Ain of the events that were
%    retained.
%
%  Example
%
%      e = cumsum( rand(100,1) );
%     ib = burstdetect( e );
%     new_e = burstfilter(e, ib, 'isolate');
%
%  See also BURSTDETECT, BURSTFILTERLEN
%

% Copyright 2005-2005 Fabian Kloosterman


if nargin<2
    help(mfilename)
    return
end

% check input arguments
if ~isnumeric(event) || ~isnumeric(burst) || length(event)~=length(burst)
    error('Invalid arguments.')
end

if nargin<3 || isempty(action)
    action = 'reduce';
end


switch action
    case 'reduce'
        % remove all spikes in bursts except first
        idx = find( burst <= 1);
        event = event(idx);
    case 'remove'
        % remove all spikes in burst
        idx = find( burst == 0 );
        event = event( idx );
    case 'isolate'
        % remove all spikes not part of burst
        idx = find( burst ~= 0 );
        event = event( idx );
    case 'isolatereduce'
        % retain only first spikes in burst
        idx = find( burst == 1 );
        event = event( idx );
end