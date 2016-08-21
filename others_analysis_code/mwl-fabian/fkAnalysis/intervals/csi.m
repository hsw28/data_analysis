function c = csi(spike_times, spike_amp, interval)
%CSI calculate complex spike index
%
%  Syntax
%
%      c = csi( A [, spike_amp, interval])
%
%  Description
%
%    This function will calculate the complex spike index for the spike
%    train A. Spike_amp is an optional vector of amplitudes for each spike
%    in A (default spike amplitude = 1). The argument interval is a two
%    element vector with the minimum and maximum intervals that define a
%    burst (default = [0.003 0.015]).
%
%    If A is a cell array of n spike trains, then his function will return
%    a nxn matrix, where the diagonal represents the csi for each
%    individual spike train and element i,j represents the cross-csi of
%    spike train i with spike train j as a reference.
%
%    Note: csi seems to be rather sensitive to what amplitude you use, i.e
%    from experience I found that sometimes using just peak amplitude will
%    give you a lower csi value than using max height (which is computed as
%    peak - trough ).
%
%  Example
%
%      s1 = cumsum( rand(1,100) );
%     s2 = cumsum( rand(1,100) );
%     c = csi( {s1, s2}, [], [0.002 0.015]);
%  
%  See also ISI, BURSTDETECT, PLOT_CSI
%

% Copyright 2005-2005 Fabian Kloosterman



if (nargin<1)
    help(mfilename)
    return
end

% check spike_times argument, convert to cell array if necessary
if isnumeric(spike_times)
    spike_times = {spike_times};
elseif ~iscell(spike_times)
    error('Invalid spike_times')
end

% get number of spike event vectors
n_spike_vectors = numel(spike_times);

% check spike_amplitude argument
% if it is empty, set amplitude of all spikes to 1
% check whether amplitude vectors and spike time vectors have same length
% convert to cell array of necessary
if nargin<2 || isempty(spike_amp)
    for i = 1:n_spike_vectors
        spike_amp{i} = ones(numel(spike_times{i}), 1);
    end
elseif isnumeric(spike_amp) && n_spike_vectors==1
    if numel(spike_times{1}) ~= numel(spike_amp)
        error('Amplitude and spike time vectors have different lengths')
    else
        spike_amp = {spike_amp};
    end
elseif iscell(spike_amp) && numel(spike_amp)==n_spike_vectors
    for i=1:n_spike_vectors
        if numel(spike_amp{i})~=numel(spike_times{i})
            error('Amplitude and spike time vectors have different lengths')
        end
    end
else
    error('Invalid spike amplitude vector')
end


% check interval parameter
% by default spikes with pre or post intervals within 3-15 ms are
% considered part of a burst
if (nargin<3 || isempty(interval))
    min_int = 0.003;
    max_int = 0.015;
elseif( ~isfloat(interval) || length(interval)~=2)
    error('Invalid max and min intervals')
else
    min_int = interval(1);
    max_int = interval(2);
end

%loop through all spike time vectors and calculate csi and cross csi

c = zeros(n_spike_vectors);

for i=1:n_spike_vectors
     
    for j=1:n_spike_vectors
        
        if i~=j
            % find smallest isi and corresponding delta amplitude for each
            % spike
            [dt, idx] = isi(spike_times{i}, spike_times{j}, 'smallest');
            ii = find(~isnan(idx));
            dt = -dt(ii);
            da = spike_amp{i}(ii) - spike_amp{j}(idx(ii));
            
            % compute csi
            c(i,j) = calccsi(dt, da, max_int, min_int) ./ numel(spike_times{i});
            
        else
            % find smallest isi and corresponding delta amplitude for each
            % spike
            [dt, idx] = isi(spike_times{i}, 'smallest');
            ii = find(~isnan(idx));
            dt = -dt(ii);
            da = spike_amp{i}(ii) - spike_amp{j}(idx(ii));            
            
            %compute csi
            c(i,j) = calccsi(dt, da, max_int, min_int) ./ numel(spike_times{j});
        end
    end
    
end


function c = calccsi(dt, da, max_int, min_int)
%CALCCSI calculate complex spike index
%
%  USAGE
%  c = calccsi( dt, da, max_int, min_int)
%  
%  dt = vector of spike time intervals (can be negative in case of
%  pre-interval)
%  da = vector of amplitude intervals
%  max_int = maximal interval for inclusion in burst
%  min_int = minimum interval for inclusion in burst
%
%  c = complex spike index
%
%  ALGORITHM
%  the function finds
%   - all spikes that contribute positively to the csi
%   (i.e. spikes with their smallest inter spike interval <=max_int and
%   >=min_int and with amplitude <= (>) than the previous (next)
%   spike
%   - all spikes that contribute negatively to the csi
%   (i.e. spikes with their smallest inter spike interval < min_int or with
%   their smallest isi <=max_int and >=min_int and with amplitude >= (<)
%   than the previous (next) spike
%   csi is then calculated as: 100 * (pos - neg)

%find all valid intervals (i.e. interval smaller than or equal to max_int)
valid = (abs(dt) <= max_int);

%find intervals within refractory period
refract = (abs(dt) < min_int);

%find intervals for all quadrants
q1 = (da<=0 & dt>0); % post intervals with smaller amplitude
q2 = (da>0 & dt<0);  % pre intervals with larger amplitude
q3 = (da<=0 & dt<0); % pre intervals with smaller amplitude
q4 = (da>0 & dt>0);  % post intervals with larger amplitude

%count the number of intervals that contribute positively to CSI
%i.e. preceding intervals with da>0 and following intervals with da<0
%(complex burst) which are both valid and not in the refractory priod
pos = length( find ( (q1 | q2) & valid & ~refract ) );

%count the number of intervals that contribute negatively to CSI
neg = length( find ( (q3 | q4 | refract) & valid ) );

%calculate csi
c = 100 * (pos - neg);
