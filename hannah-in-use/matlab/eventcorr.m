function varargout=eventcorr(trigger,events,lags,varargin)
%EVENTCORR event correlation
%
%  t=EVENTCORR(trigger,events,lags) returns the relative times
%  within the interval defined by lags of all events surrounding the
%  trigger times. Both trigger and event vectors need to be sorted. The
%  events can also be a sorted array of segment start and end times.
%
%  t=EVENTCORR(...,'param',val,...) Specifies optional
%  parmeter/value pairs. Valid parameters are:
%   segments - correlation restricted to all trigger events that
%              are within the specified segments. The function
%              takes into account the interval lags, such that
%              trigger events that are too close too a segment
%              boundary are excluded. Default segments = [-Inf
%              Inf].
%   indices - 0/1 if 1 returns the indices of the events
%             surrounding the trigger events, rather than relative
%             times (default = 0).
%   biased - 0/1 if 1 does not exclude triggers that are too close
%            to segment boundaries (default = 0).
%
%  [...,n]=EVENTCORR(...) returns the vector n containing the number of
%  relative times for each trigger event.
%

if nargin<3
    help(mfilename)
    return
end

options = struct('segments', [-Inf Inf], 'indices', 0, 'biased', 0 );
options = parseArgs( varargin, options );

if ~isnumeric(trigger) || ~isvector(trigger)
    error('eventcorr:invalidArgument', 'Invalid trigger vector')
end

if ~isnumeric(events)
    error('eventcorr:invalidArgument', 'Invalid events vector')
end

if ~isnumeric(lags) || ~isequal( [1 2], size(lags) ) || diff(lags)<=0
    error('eventcorr:invalidArguments', 'Invalid lags vector')
end

%[size(trigger) size(events), lags, size(options.segments), size(options.indices)]
[varargout{1:nargout}] = eventcorr_c( trigger, events, lags(1), lags(2), ...
                              options.segments, options.indices, ...
                              options.biased );

if ~isvector(events) && ~options.indices
    varargout{1} = varargout{1}';
end
                          