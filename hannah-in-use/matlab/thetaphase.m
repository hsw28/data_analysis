function f = thetaphase(lfp, tme);

%input raw unfiltered LFP. filters in theta band returns times of peaks in theta

lfp = thetafilt(lfp);

%st = mean(lfp)+(1*std(lfp));
st = mean(lfp);

start = tme(1);


[pks,locs] = findpeaks(thetafilt(lfp), 2000, 'MinPeakDistance', .08, 'MinPeakHeight', st , 'WidthReference', 'halfprom');

f = locs+start;



