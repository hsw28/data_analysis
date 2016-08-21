function [c, t] = calc_rolling_corr(ts, sig1, sig2)

if isrow(sig1)
    sig1 = sig1';
end
if isrow(sig2)
    sig2 = sig2';
end

Fs = timestamp2fs(ts);
dt = 2;
dSamp = floor(Fs * dt);

sigLen = numel(sig1);
rem = mod(sigLen, dSamp);

sig1 = sig1(1:end-rem);
sig2 = sig2(1:end-rem);
ts = ts(1:end-rem);

sig1 = reshape(sig1, dSamp, (sigLen-rem)/dSamp);
sig2 = reshape(sig2, dSamp, (sigLen-rem)/dSamp);
ts = reshape(ts, dSamp, (sigLen-rem)/dSamp);
t = ts(1,:);

c = corr_col(sig1, sig2);