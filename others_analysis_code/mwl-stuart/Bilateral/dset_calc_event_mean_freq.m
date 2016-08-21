function [peakFreq] = dset_calc_event_mean_freq(data, firstTs, fs, eventWindows, varargin )
error('DEPRECATED FUNCTION');

args = dset_get_standard_args;
args = parseArgs(varargin, args);

dt = 1.0/fs;
ts = firstTs : dt : firstTs + (numel(data)-1 ) * dt;

[~, idx] = findpeaks(data);
% convert the peak indices to a logical vector so everything is lined up
peakIdx = false(size(data));
peakIdx(idx) = 1;
peakFreq = zeros(1, size(eventWindows,1));

for i=1:size(eventWindows,1)
   
    timeWin = eventWindows(i,:);
    dataIdx = (ts>= timeWin(1) & ts<=timeWin(2))';
    %select times that are in the window AND also peaks
    peakTimes = ts( peakIdx & dataIdx);
    peakFreq(i) = 1 / mean( diff( peakTimes ));
    
end


end

