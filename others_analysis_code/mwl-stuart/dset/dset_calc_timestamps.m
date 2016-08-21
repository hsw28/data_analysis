function ts = dest_calc_timestamps(first_ts, num_ts, fs)
% DSET_CALC_TIMESTAMPS - Calculates a vector of timestamps given 1st ts, nTs, and Fs

if ~isscalar(first_ts)
    error('First timestap should be a scalar');
elseif ~isscalar(num_ts) || num_ts <= 0
    error('N Timestamps should be a positive scalar');
elseif ~isscalar(fs) || fs<=0
    error('Sampling frequency should be a positive scalar');
end

    st = first_ts;
    dt = 1.000 / fs;
    ts = st:dt:st + (num_ts-1)*dt;

end