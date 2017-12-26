function result = slidingWindowCorr(signal1, signal2,time,L,R)
% Plots the max correlation value calculated for a window of specified
% length accross time
% signal = spike train data or other stuff
% time = lfp.timestamp*7.75
% L = window length, ex 2000
% R = decimation rate (how many samples to skip between windows), ex 25
%    R = L is abutted windows, DO NOT MAKE R > L

Q = length(signal1);
M = floor(Q/R)-ceil(L/R)+1;
autocorr = zeros(M,2*L-1);
for x = 1:M
    subset1 = signal1((x-1)*R+1:x*R+L-R);
    subset2 = signal2((x-1)*R+1:x*R+L-R);
    %autocorr(x,:) = max(corr(subset1', subset2));
    cr = (corr(subset1', subset2));
    autocorr(x,:) = max(cr(1,:));
end
time = time(1:R:M*R);
result = [time' max(autocorr,[],2)];

figure;
size(time)
plot(time, max(autocorr,[],2));
xlabel('Time (s)');
ylabel('Correlation');
