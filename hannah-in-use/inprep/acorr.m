function f = acorr(x);
%finds autocorrelation of a sequence for periodicity

x = x-mean(x);
fs = 2000;
t = (0:length(x)-1)/fs;

[autocor,lags] = xcorr(x,fs*10,'coeff');

f = figure;
plot(lags/fs,autocor)
xlabel('Lag (Sec)')
ylabel('Autocorrelation')
