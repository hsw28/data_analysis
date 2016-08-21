function sws = detect_sws(ts, lfp)

timestampCheck(ts);
fs = timestamp2fs(ts);

thetaFilt = getfilter(fs, 'theta', 'win');
deltaFilt = getfilter(fs, 'slow', 'win');

theta = filtfilt(thetaFilt, 1, lfp);
delta = filtfilt(deltaFilt, 1, lfp);

k = make_smoothing_kernel(fs);

thetaEnv = abs(hilbert(theta));
deltaEnv = abs(hilbert(delta));

ratio = thetaEnv ./ deltaEnv;
ratioSm = conv(ratio, k, 'same');

sws = logical2seg( ratioSm <= ( mean(ratioSm) +  3 * std(ratioSm) ) );

end



function k = make_smoothing_kernel(Fs, nStd)

if nargin == 1
    nStd = 1;
end

n = round(Fs);
k = normpdf(-n:n, 0, nStd * Fs/6);

end