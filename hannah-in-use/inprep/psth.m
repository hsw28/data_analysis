function varargout=psth(varargin)
%PSTH peri-stimulus time histogram
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

%get options
options = struct('lags', linspace(-1,1,52), ...
                 'segments', [], ...
                 'normalization', 'none');

[options, other, remainder] = parseArgs( varargin, options );

%check input arguments
if isempty(other)
  error('psth:invalidArguments', 'No trigger')
end

trigger = other{1};

if numel(other)>=2
  events = other{2};
else
  events = trigger; %auto correlation
end

if ~isnumeric(trigger)
  error('psth:invalidArgument', 'Invalid trigger')
else
  trigger = double(trigger);
end

if isnumeric(events)
  events = {double(events)};
elseif iscell(events)
  for k=1:numel(events)
    if ~isnumeric(events{k})
      error('psth:invalidArgument', 'Invalid events')
    else
      events{k}=double(events{k});
    end
  end
else
  error('psth:invalidArgument', 'Invalid events')
end
  
if ~isnumeric(options.lags) || ~isvector(options.lags) || ...
      numel(options.lags)<2 || ~issorted(options.lags)
  error('psth:invalidArgument', 'Invalid lags')
end

n = numel(events);
nlags = numel(options.lags) - 1;
minlag = options.lags(1);
maxlag = options.lags(end);


varargout{1} = zeros(n, nlags+1);

for k=1:n

	[tmp,nev] = eventcorr(trigger, events{k}, [minlag maxlag], 'segments', options.segments, remainder{:});
    if ~isempty(tmp)
        varargout{1}(k,:) = histc(tmp, options.lags );
    end
end
  
varargout{1}(:,end)=[];

ntriggers = numel( find( ~isnan(nev) ) );

if nargout>1
    varargout{2} = options.lags;
end

if nargout>2
  varargout{3} = ntriggers;
end

switch options.normalization
 case 'coef'
  varargout{1} = varargout{1}./ntriggers;
 case 'rate'
  varargout{1} = bsxfun( @rdivide, varargout{1}, ntriggers.*diff(options.lags(:))' );
end
