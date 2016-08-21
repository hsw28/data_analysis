function [ripple_times, max_times, maxPower, rips, ripPower, rip, params ] = find_rip_burst(eeg, fs, first_ts, varargin)
%FIND_RIP_BURST finds burst in the ripple band and returns time windows
%containing those bursts.
%
% [burst_window] = FIND_RIP_BURST(eeg_signal, eeg_ts, sample_frequency)
% returns a nx2 matrix containing the start and stop time of each burst. 
%
% [burst max_times] = FINd_RIP_BURST(...) returns the timestamp of the peak
% value of the ripple envelope
%
% [burst max_times rips] = FIND_RIP_BURST(...)  returns the unfilted EEG
% traces that fall within the burst_window
%
% [busrt_window max_times rips params] = FIND_RIP_BURST(...) returns params which
% contains the parameters used to calculate the bursts, parameters include:
% the high and low thresholds, the filtered ripple data, the filter used
% and the crossing times for each threshold.
%
% [....] = FIND_RIP_BURST(..., param, value,...) params can be: high_std,
% and low_std
%
% Bursts are found as: any time the envelope crosses high_std*standard
% deviations above the mean a peak time is taken, then all data around
% those points that are also above low_std*standard deviations are defined
% as a ripple burst.  
%
% Stuart Layton, August 2009, MIT

st = first_ts;

nSamp = numel(eeg);
dt = 1.000 / fs;

ts = st:dt:st + (nSamp-1)*dt;
args.high_thold = 7;
args.low_thold =  2;
args.min_burst_len = .01;

args = parseArgs(varargin, args);


%disp('1');
rip_filt = getfilter(fs, 'ripple', 'win');

%disp('Filtering raw eeg for ripples...');
disp('Filtering for ripples');
    
    
rip = filtfilt(rip_filt, 1, eeg);
rip = rip - mean(rip);

disp('Calculating ripple envelope');

h = abs(hilbert(rip));
%h = h - mean(h);

high_seg = logical2seg(ts, h>=args.high_thold * std(h));
low_seg = logical2seg(ts, h>=args.low_thold * std(h));


[b n] = inseg(low_seg, high_seg);

bursts = low_seg(logical(n),:);
bursts = bursts(diff(bursts,1,2)>args.min_burst_len, :);

for i=1:size(bursts,1)
    % if the burst occurs in the last 2 seconds of the experiment ignore it
    if bursts(i,2) + 2 > ts(end)
        continue;
    end
    
    ripple_times(i,:) = bursts(i,:);
    idx = ts>= bursts(i,1) & ts<=bursts(i,2);
    rips{i} = eeg(idx);
    ripPower(i) = sum(rip(idx).*rip(idx));
    [~, peakIdx] = max(rips{i});
    max_times(i) = round( ts( find(idx,1,'first') + peakIdx - 1 )); % subtract offset
    maxPower(i) = eeg(find(idx,1,'first') + peakIdx - 1).^2;
end

params.filter = rip_filt;
params.high_threshold = args.high_thold;
params.low_threshold = args.low_thold;
params.low_threshold_crossings = low_seg;
params.high_threshold_crossings = high_seg;
params = orderfields(params);


end
