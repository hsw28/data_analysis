function [ripples,peakTimes] = eegRipples(rippleEnv, minPeak, baseCutoff, minLength, bridgeWidth, adequate_local_min, min_peak_dist)
% eegRipples (filteredEeg, minPeak, baseCutoff, minLength, bridgeWidth)
% returns [cellarray of time intervals corresponding to ripples,
%          array of ripple peak times]

%minPeakDistSamps = ceil( min_peak_dist / rippleEnv.samplerate );

segCrit = seg_criterion('peak_min',minPeak,'cutoff_value',baseCutoff,...
    'min_width_pre_bridge',minLength,'bridge_max_gap',bridgeWidth,'adequate_local_min',adequate_local_min, 'min_peak_dist',min_peak_dist);

rippleEnv = contmap(@(x) mean(x,2), rippleEnv);

ripples = gh_signal_to_segs(rippleEnv, segCrit);

peakTimes = cellfun(@(interval) l_peak_in(rippleEnv, interval), ripples);

end

function peakTime = l_peak_in(cdat, interval)
cdat = contwin(cdat,interval);
ts = conttimestamp(cdat);
peakTime = ts( cdat.data == max(cdat.data) );
peakTime = peakTime(1);
end