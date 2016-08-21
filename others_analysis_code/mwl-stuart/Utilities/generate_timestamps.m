function tstamps = generate_timestamps(tstart, n, arg)
% [timestamps] = GENERATE_TIMESTAMPS(tStart, nSamp, [tEnd/Fs])
% returns a vector of timestamps starting with tstart, ending with tend and
% of length n

if (arg < tstart)
    fs = arg;
    delta_t = 1.000/fs;
    tstamps = ( tstart + (1 : n) .* delta_t )';
else
    tend = arg;
    delta_t = (tend-tstart)/n;
    tstamps = tstart:delta_t:tend-delta_t;
end
