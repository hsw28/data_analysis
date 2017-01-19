function info = thetaPowerVsTime(lfpdata,time,L,R)
% lfpdata = lfp.data
% time = lfp.timestamp*7.75
% L = window length
% R = decimation rate (how many samples to skip between windows
%    R = L is abutted windows, DO NOT MAKE R > L
% info = [timestamps, power_ratio_vector]
Q = length(lfpdata);

Fs = 2000;
N = 2^(nextpow2(L)+1);
M = floor(Q/R)-ceil(L/R)+1;
window = chebwin(L,60);
U = sum(window.^2)/L;
spectro = zeros(M,1);
freq = Fs*(0:N/2)/N;
times = (6 < freq) & (freq < 12);
for x = 1:M
    subset = lfpdata((x-1)*R+1:x*R+L-R);
    subset = subset - mean(subset);
    data = subset.*window;
    Y = fft(data,N);
    P2 = (Y.*conj(Y))/(L*U);
    P1 = P2(1:N/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    PTheta = sum(P1(times));
    Ptotal = sum(P1);
    P3 = PTheta/Ptotal;
    spectro(x,1) = P3;
end

time = time(1:R:M*R);
info = [time', spectro];
% figure;
% plot(time,spectro);
% xlabel('Time (s)');
% ylabel('Theta Power Ratio');