function info = spectralPowerVsTime(lfpdata,time,L,R,bins,smoothfactor)
% Plots the power of frequency bands specified in bins against time with
% the option of smoothing data for more general trends
% lfpdata = lfp.data
% time = lfp.timestamp*7.75
% L = window length, ex 2000
% R = decimation rate (how many samples to skip between windows), ex 25
%    R = L is abutted windows, DO NOT MAKE R > L
% bins = bin edges, ex [4 7 10 12];
% smoothfactor = # of samples to smooth (input to smooth function), ex 2001
% info = [timestamps, power_ratio_vector]
Q = length(lfpdata);

Fs = 2000;
N = 2^(nextpow2(L)+2);
M = floor(Q/R)-ceil(L/R)+1;
window = chebwin(L,60);
U = sum(window.^2)/L;
spectro = zeros(M,8);
freq = Fs*(0:N/2)/N;
for x = 1:M
    subset = lfpdata((x-1)*R+1:x*R+L-R);
    subset = subset - mean(subset);
    data = subset.*window;
    Y = fft(data,N);
    P2 = (Y.*conj(Y))/(L*U);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    for y = 1:(length(bins)-1)
        times = (bins(y) < freq) & (freq < bins(y+1));
        spectro(x,y) = mean(P1(times));
    end
end

for y = 1:(length(bins)-1)
        spectro(:,y) = smooth(spectro(:,y),smoothfactor);
end
time = time(1:R:M*R);
info = [time', spectro];
figure;
semilogy(time,spectro);
xlabel('Time (s)');
ylabel('Power');
