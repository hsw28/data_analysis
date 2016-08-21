function plot_bilateral_ripple_band_xcorr(data)

figure;

nSamp = size(data.xcorrIpsi,1);

ts = ((1:nSamp) - round(nSamp/2)) * 1/1500;


plot(ts, mean(data.xcorrIpsi,2),'r', ts, mean(data.xcorrCont,2),'g', 'linewidth', 2);