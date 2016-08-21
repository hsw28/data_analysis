function [rippleTs, events, allPeakTs, params, rippleBand, ripEnvelope] = detect_ripples(ts, x, varargin)

timestampCheck(ts);
ind = 1:numel(ts);

Fs = 1 / (ts(2) - ts(1));

args.high_thold = 7;
args.low_thold = 4;
parseArgs(varargin, args);


% Create the filter and filter the signal
b = getfilter(Fs, 'ripple', 'win');
rippleBand = filtfilt(b, 1, x);

% mean correct
rippleBand = rippleBand - mean(rippleBand);

%compute the envelope of the signal
ripEnvelope = abs( hilbert( rippleBand ));

%threshold for burst segments
thH = std(ripEnvelope)*args.high_thold;
thL = std(ripEnvelope)*args.low_thold;

high_seg = logical2seg(ind, ripEnvelope>=thH);
low_seg = logical2seg(ind, ripEnvelope>=thL);

[~, n] = inseg(low_seg, high_seg);

events = low_seg(logical(n),:);

duration = diff(events,[],2);
duration = duration / Fs;
validIdx = duration > .01 & duration < .1;

events = events(validIdx,:);

% find the peak voltage within the ripple candidate window
findMaxEnvFunc = @(x,y) max( rippleBand(x:y) );
[~, peakIdx] = arrayfun(findMaxEnvFunc, events(:,1), events(:,2) );

peakIdx = peakIdx + events(:,1) - 1;

rippleTs = ts(peakIdx);


% find ALL of the peaks of the spindle oscillation within the spindle window
getAllPeaks = @(x,y) findpeaks( rippleBand(x:y) );
[~, allPeaks] = arrayfun(getAllPeaks, events(:,1), events(:,2), 'UniformOutput', 0);
for i = 1:numel(allPeaks)
    allPeaks{i} = allPeaks{i} + events(i,1) -1;
end
allPeaks = cellfun(@transpose, allPeaks, 'UniformOutput', 0);
allPeaks = [allPeaks{:}];
allPeakTs = ts(allPeaks);

events = ts(events);

params.bandpass_filter = b;
params.highThreshold = thH;
params.lowThreshold = thL;



end
