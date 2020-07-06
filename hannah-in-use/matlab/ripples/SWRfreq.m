function f = SWRfreq(lfp, lfp_time, ripplematrix)
%returns average frequency for SWR

if abs(length(lfp)-length(lfp_time))>10
  error('YOUR TIME DOES NOT MATCH YOUR LFP')
end


if (size(ripplematrix,1)) == 3
    ripplematrix = [ripplematrix(1,:); ripplematrix(3,:)]; %[times, rip num]
end



lfp_data = ripfilt(lfp);

total_ripav_freq = [];
for k=1:length(ripplematrix)

  [val,lfptime_start]=min(abs(lfp_time-ripplematrix(1,k)));
  [val,lfptime_end]=min(abs(lfp_time-ripplematrix(2,k)));
  totalrip = lfp_data(lfptime_start:lfptime_end);
  L = length(totalrip);
  [pks,locs] = findpeaks(totalrip, 2000, 'MinPeakDistance', .0025, 'MaxPeakWidth', .01);
  total_ripav_freq(end+1) = length(pks)/(L/2000);

end

f = total_ripav_freq;
