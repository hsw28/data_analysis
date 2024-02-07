
function varargout=psth(varargin)
%PSTH peri-stimulus time histogram
%
% all inputs must be in ROWS
%
%  h=PSTH(trigger,events) returns the psth for the events, given the in
%  the interval [-1 1] around the trigger events. The number of bins in
%  the histogram is 51. The trigger should be a sorted vector, the events
%  can be either a sorted vector or a cell array of sorted vectors. In the
%  latter case, the result is a array.
%
%  [h,lags]=PSTH(...) returns the lags used for the histogram.
%
%  [h,lags,n]=PSTH(...) returns the number of valid triggers.
%
%  h=PSTH(trigger,events,parm1,val1,...) sets optional parameters. Valid
%  parameters are:
%   lags - vector of bins for histogram
%   segments - list of segments
%   normalization - 'coef', 'none', 'rate'
%

% Default options
bins = 15; % Default number of bins
options = struct('lags', linspace(-1.4286, 0.7143, bins + 1), ...
                 'segments', [], ...
                 'normalization', 'none'); % No normalization for summed PSTH

% Parse input arguments and options
[options, other, remainder] = parseArgs(varargin, options);

% Validate input
if isempty(other)
    error('psth:invalidArguments', 'No trigger provided');
end

trigger = other{1};
if numel(other) >= 2
    events = other{2};
else
    events = trigger; % For auto-correlation
end

% Ensure numeric and double precision
trigger = double(trigger);
if isnumeric(events)
    events = {double(events)}; % Convert to cell array for consistency
end

% Validate events
for k = 1:numel(events)
    if ~isnumeric(events{k})
        error('psth:invalidArgument', 'Invalid events provided');
    end
    events{k} = double(events{k}); % Ensure double precision
end

% Validate lags
if ~isnumeric(options.lags) || ~isvector(options.lags) || numel(options.lags) < 2 || ~issorted(options.lags)
    error('psth:invalidArgument', 'Invalid lags');
end

% Prepare output histogram
nlags = numel(options.lags) - 1;
h = zeros(1, nlags);

% Accumulate event counts for each trigger
for i = 1:numel(trigger)
    for k = 1:numel(events)
        % Calculate relative times and bin them
        eventTimes = events{k} - trigger(i);
        validEvents = eventTimes(eventTimes >= options.lags(1) & eventTimes <= options.lags(end));
        bins = histc(validEvents, options.lags);
        h = h + bins(1:end-1); % Sum counts and ignore last bin edge count
    end
end

% Set outputs
varargout{1} = h;
varargout{2} = options.lags(1:end-1); % Return bin edges as lags
varargout{3} = numel(trigger); % Number of triggers

% Apply normalization if specified
switch options.normalization
    case 'coef'
        varargout{1} = varargout{1} / numel(trigger);
    case 'rate'
        binWidth = diff(options.lags(1:2));
        varargout{1} = varargout{1} / (numel(trigger) * binWidth);
end



function [options, other, remainder] = parseArgs(args, defaults)
% Placeholder for argument parsing function
% You should replace this with actual argument parsing logic
options = defaults;
other = args(1:2);
remainder = args(3:end);
