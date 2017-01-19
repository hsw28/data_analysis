function result = slidingWindowCorr(signal,time,L,R)
% Plots the max autocorrelation value calculated for a window of specified
% length accross time
% signal = spike train data or other stuff
% time = lfp.timestamp*7.75
% L = window length, ex 2000
% R = decimation rate (how many samples to skip between windows), ex 25
%    R = L is abutted windows, DO NOT MAKE R > L
Q = length(signal);
M = floor(Q/R)-ceil(L/R)+1;
autocorr = zeros(M,2*L-1);
for x = 1:M
    subset = signal((x-1)*R+1:x*R+L-R);
    autocorr(x,:) = xcorr(subset,'biased')';
end
time = time(1:R:M*R);
result = [time' autocorr];

figure;
plot(time, max(autocorr,[],2));
xlabel('Time (s)');
ylabel('Correlation');