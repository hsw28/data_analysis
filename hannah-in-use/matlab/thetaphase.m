function f = thetaphase(lfp, timevector, above, thetaband, vel);

  % for theta band: input 0 for all theta bands, 1 for low theta, 2 for high theta

%input raw unfiltered LFP. filters in theta band returns times of peaks in theta
% input for above is how many st devs above mean you want peak to be to be counted




[cc indexmin] = min(abs(vel(2,1)-timevector));
[cc indexmax] = min(abs(vel(2,end)-timevector));
timevector = timevector(indexmin:indexmax);
lfp = lfp(indexmin:indexmax);


if thetaband == 0
  lfp = thetafilt412(lfp);
elseif thetaband == 1
  lfp = lowtheta(lfp);
elseif thetaband == 2
  lfp = hightheta(lfp);
end

st = mean(lfp)+(above*std(lfp));


start = timevector(1);


%[pks,locs] = findpeaks(lfp, 2000, 'MinPeakDistance', .08, 'MinPeakHeight', st , 'MinPeakWidth', .08, 'MaxPeakWidth', .17);
[pks,locs] = findpeaks(lfp, 2000, 'MinPeakDistance', .08, 'MinPeakHeight', st, 'MaxPeakWidth', .17);



%uncomment next line if you want to show peaks on a graph
%findpeaks(thetafilt(lfp), 2000, 'MinPeakDistance', .08, 'MinPeakHeight', st , 'WidthReference', 'halfprom', 'Annotate', 'extents');


f = locs+start;
