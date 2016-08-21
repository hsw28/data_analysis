function inburst = burstdetect(event, varargin)
%BURSTDETECT detect bursts in spike train
%
%  Syntax
%
%      B = burstdetect( A [, amp])
%
%  Description
%
%    This function will detect all bursts in event times vector A. The
%    output vector B is 0 for non-burst events, 1 for the first event in a
%    burst, 3 for the last event in a burst and 2 for the other burst
%    events. The optional vector amp, containing amplitudes for the events
%    in A, is used to find complex spike bursts. That is, an additional
%    constraint of decreasing amplitudes is added to the burst detection.
%
%  Options
%
%      MinIsi = minimal inter spike interval for inclusion in burst
%            (default = 0.003)
%      MaxIsi = maximal interspike interval for inclusion in burst
%            (default = 0.015)
%      MinEvents = minimal number of events in burst (default = 2)
%      MaxEvents = maximal number of events in burst (default = Inf)
%
%  Example
%
%      e = cumsum( rand(100,1) );
%      ib = burstdetect( e, 'MinIsI', 0.002, 'MaxEvents', 10 );
%
%  See also ISI, BURSTFILTER, BURSTFILTERLEN
%

% Copyright 2005-2005 Fabian Kloosterman


% optional parameter / value arguments
Args = struct('MinIsi', 0.003, 'MaxIsi', 0.015, 'MinEvents', 2, 'MaxEvents', Inf);

if nargin<1
    help(mfilename)
    return
end

% check event times vector
if ~isnumeric(event)
    error('Invalid event vector')
end

%number of events
n = length(event);

if n==0
    inburst = [];
    return;
end

% parse parameter / value pairs and optional variable argument
[Args, other] = parseArgs(varargin, Args);

% check amplitude vector
if length(other)==1
  amp = other{1};
  if isnumeric(amp) && isscalar(amp)
    amp = ones(n,1)*amp;
  end
  if length(amp)~=n
    error('burstdetect:invalidArguments', 'Invalid amplitude vector.')
  end
elseif ~isempty(other)
  error('burstdetect:invalidArguments', 'Too many input arguments.')
else
    amp = [];
end

%find pre and post intervals
d_pre = abs(isi(event, 'pre'));
d_post = abs(isi(event, 'post'));

%initialize output
inburst = zeros(n,1);


%find bursts
if ~isempty(amp)
    % find pre and post amplitude differences
    a_pre = isi(amp, 'pre');
    a_post = isi(amp, 'post');

    % find first event in burst
    inburst( (d_pre>Args.MaxIsi | d_pre<Args.MinIsi | isnan(d_pre) | a_pre<0) & (d_post<=Args.MaxIsi & d_post>=Args.MinIsi) & a_post<=0 ) = 1;
    % find 2nd and following spikes in burst
    inburst( (d_pre<=Args.MaxIsi & d_pre>=Args.MinIsi) & (d_post<=Args.MaxIsi & d_post>=Args.MinIsi) & a_pre>=0 & a_post<=0 ) = 2;
    % find last spike in burst
    inburst( (d_post>Args.MaxIsi | d_post<Args.MinIsi | isnan(d_post) | a_post>0 ) & (d_pre<=Args.MaxIsi & d_pre>=Args.MinIsi) & a_pre>=0 ) = 3;   

else   
    % find first event in burst
    inburst( (d_pre>Args.MaxIsi | d_pre<Args.MinIsi | isnan(d_pre)) & (d_post<=Args.MaxIsi & d_post>=Args.MinIsi) ) = 1;
    % find 2nd and following spikes in burst
    inburst( (d_pre<=Args.MaxIsi & d_pre>=Args.MinIsi) & (d_post<=Args.MaxIsi & d_post>=Args.MinIsi) ) = 2;
    % find last spike in burst
    inburst( (d_post>Args.MaxIsi | d_post<Args.MinIsi | isnan(d_post) ) & (d_pre<=Args.MaxIsi & d_pre>=Args.MinIsi) ) = 3;
end



% find all bursts starts and ends
burststart = find( inburst==1 );
burstend = find( inburst==3 );

if isempty(burststart) || isempty(burstend)
    return
end

% find and remove incomplete bursts at start and end
if (burststart(1)>burstend(1))
    inburst(burstend(1))=0;
    burstend(1) = [];
end
if (burstend(end)<burststart(end))
    inburst(burststart(end))=0;
    burststart(end) = [];
end

% determine number of events in every burst
nevents = burstend - burststart + 1;
invalidbursts = find(nevents<Args.MinEvents | nevents>Args.MaxEvents);

%to get rid of invalid burst for now do a loop, until we've figured out a
%better way of doing it
for i = 1:length(invalidbursts)
    
    inburst(burststart(invalidbursts(i)):burstend(invalidbursts(i))) = 0;
    
end

