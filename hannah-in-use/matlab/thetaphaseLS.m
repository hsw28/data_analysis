function f = thetaphaseLS(lfp);

%input raw unfiltered LFP. returns times of peaks


%st = mean(lfp)+(2*std(lfp));
st = mean(lfp);


[pks,locs] = findpeaks(thetafilt(lfp), 2000, 'MinPeakDistance', .08, 'MinPeakHeight', st , 'WidthReference', 'halfprom');

f = locs;



