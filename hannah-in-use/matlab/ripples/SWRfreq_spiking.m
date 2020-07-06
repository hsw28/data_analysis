function [total_ripav_freq fasterslower firstsecond herzthresh p] = SWRfreq_spiking(lfp, lfp_time, ripplematrix, clusters, lag, freq_thresh)
  %outputs:
   %fasterslower = when you split ripples into a faster (hz) and slower half, the number of spikes from each cluster that spike in each half (summed across all ripples)
   %firstsecond = same as fasterslower but ripples are split into a first and second half
   %herzthresh = same as above but each half is categorized as slow or fast based on a threshold
   %p  =the p values for the above three cell group comparisions




if abs(length(lfp)-length(lfp_time))>10
  error('YOUR TIME DOES NOT MATCH YOUR LFP')
end

if lag<10 && lag>0
    error('YOU NEED TO ENTER LAG IN MS')
end



if (size(ripplematrix,1)) == 3
    ripplematrix = [ripplematrix(1,:); ripplematrix(3,:)]; %[times, rip num]
end

rip_firsthalf = [ripplematrix(1,:); ripplematrix(1,:)+(abs(ripplematrix(2,:)-ripplematrix(1,:))./2)];
rip_secondhalf = [ripplematrix(2,:)-(abs(ripplematrix(2,:)-ripplematrix(1,:))./2); ripplematrix(2,:)];






lfp_data = ripfilt(lfp);

faster = [];
faster_freq = [];
slower_freq = [];
faster_freq_spikes = [];
slower_freq_spikes = [];
first_spikes = [];
second_spikes = [];
freq_thresh_low = [];
freq_thresh_high = [];
total_ripav_freq = [];
low = 0;
high = 0;
for k=1:length(rip_firsthalf)

  [val,lfptime_start]=min(abs(lfp_time-ripplematrix(1,k)));
  [val,lfptime_end]=min(abs(lfp_time-ripplematrix(2,k)));
  totalrip = lfp_data(lfptime_start:lfptime_end);
  L = length(totalrip);
  [pks,locs] = findpeaks(totalrip, 2000, 'MinPeakDistance', .0025, 'MaxPeakWidth', .01);
  total_ripav_freq(end+1) = length(pks)/(L/2000);


  [val,lfptime_start]=min(abs(lfp_time-rip_firsthalf(1,k)));
  [val,lfptime_end]=min(abs(lfp_time-rip_firsthalf(2,k)));
  curLFP_first = lfp_data(lfptime_start:lfptime_end);

  [val,lfptime_start]=min(abs(lfp_time-rip_secondhalf(1,k)));
  [val,lfptime_end]=min(abs(lfp_time-rip_secondhalf(2,k)));
  curLFP_second = lfp_data(lfptime_start:lfptime_end);

  L = length(curLFP_first);
  [pks,locs] = findpeaks(curLFP_first, 2000, 'MinPeakDistance', .0025, 'MaxPeakWidth', .01);
  peaks_per_time_first = length(pks)/(L/2000);

  L = length(curLFP_second);
  [pks,locs] = findpeaks(curLFP_second, 2000, 'MinPeakDistance', .0025, 'MaxPeakWidth', .01);
  peaks_per_time_second = length(pks)/(L/2000);


  [first_order first_spikesinrip] = ripplespikes(rip_firsthalf(:,k), clusters, lag);
  [second_order second_spikesinrip] = ripplespikes(rip_secondhalf(:,k), clusters, lag);

  if peaks_per_time_first > peaks_per_time_second
    faster(end+1) = 1;
    faster_freq(end+1) = peaks_per_time_first;
    slower_freq(end+1) = peaks_per_time_second;
    faster_freq_spikes = [faster_freq_spikes; first_order];
    slower_freq_spikes = [slower_freq_spikes; second_order];
  elseif peaks_per_time_first < peaks_per_time_second
    faster(end+1) = 2;
    faster_freq(end+1) = peaks_per_time_second;
    slower_freq(end+1) = peaks_per_time_first;
    faster_freq_spikes = [faster_freq_spikes; second_order];
    slower_freq_spikes = [slower_freq_spikes; first_order];
  end

  if peaks_per_time_first <freq_thresh
    freq_thresh_low = [freq_thresh_low; first_order];
    low = low+1;
  else
    freq_thresh_high = [freq_thresh_high; first_order];
    high = high+1;
  end

  if peaks_per_time_second <freq_thresh
    freq_thresh_low = [freq_thresh_low; second_order];
    low = low+1;
  else
    freq_thresh_high = [freq_thresh_high; second_order];
    high = high+1;
  end


    first_spikes = [first_spikes; first_order];
    second_spikes = [second_spikes; second_order];
end

(freq_thresh_low);
(freq_thresh_high);

clustname = (fieldnames(clusters));
numclust = length(clustname);
num_each_cell_slower_faster= [];
num_each_cell_first_second = [];
num_each_cell_threshold = [];
for k=1:numclust
  length_faster = (length(find(faster_freq_spikes==k)));
  length_slower = (length(find(slower_freq_spikes==k)));
  %if length_faster > 0 | length_slower > 0
    num_each_cell_slower_faster = [num_each_cell_slower_faster, [length_faster; length_slower]];
%  end

  length_first = (length(find(first_spikes==k)));
  length_second = (length(find(second_spikes==k)));
  %if length_first > 0 | length_second > 0
    num_each_cell_first_second = [num_each_cell_first_second, [length_first; length_second]];
%  end

  length_first = (length(find(freq_thresh_low==k)));
  length_second = (length(find(freq_thresh_high==k)));
  %if length_first > 0 | length_second > 0
    num_each_cell_threshold = [num_each_cell_threshold, [length_first; length_second]];
  %end

end

%fasterslower = [faster_freq; slower_freq];
%firstsecond = [first_spikes; second_spikes];
%herzthresh = num_each_cell_threshold;

fprintf('average spikes per ripple, comparing slower faster half')
[m p n stats]= ttest(num_each_cell_slower_faster(1,:)./length(rip_firsthalf), num_each_cell_slower_faster(2,:)./length(rip_firsthalf));
p
fprintf('average spikes per ripple, comparing first second half')
[m p n stats] = ttest(num_each_cell_first_second(1,:)./length(rip_firsthalf), num_each_cell_first_second(2,:)./length(rip_firsthalf));
p
fprintf('average spikes per ripple, comparing thresholds')
num_each_cell_threshold_per = num_each_cell_threshold;
num_each_cell_threshold_per(1,:) = num_each_cell_threshold_per(1,:)./low;
num_each_cell_threshold_per(2,:) = num_each_cell_threshold_per(2,:)./high;
[m p n stats] = ttest(num_each_cell_threshold_per(1,:), num_each_cell_threshold_per(2,:));
p

%'cell by cell comparision of total spiking'
% this isnt exactly right rn bc doesnt take into account multiple spikes in one ripple, but its approx
p_slowerfaster = [];
p_firstsecond = [];
p_herzthresh =[];
for k = 1:length(num_each_cell_slower_faster)
  blank_slower = zeros(1,length(rip_firsthalf));
  blank_slower(1:num_each_cell_slower_faster(1,k)) = 1;
  blank_faster = zeros(1,length(rip_firsthalf));
  blank_faster(1:num_each_cell_slower_faster(2,k)) = 1;
  [m p n stats] = ttest2(blank_slower, blank_faster);
  p_slowerfaster(end+1) = p;

  blank_first = zeros(1,length(rip_firsthalf));
  blank_first(1:num_each_cell_first_second(1,k)) = 1;
  blank_second = zeros(1,length(rip_firsthalf));
  blank_second(1:num_each_cell_first_second(2,k)) = 1;
  [m p n stats] = ttest2(blank_first, blank_second);
  p_firstsecond(end+1) = p;

  blank_low = zeros(1,low);
  blank_low(1:num_each_cell_threshold(1,k)) = 1;
  blank_high = zeros(1,high);
  blank_high(1:num_each_cell_threshold(2,k)) = 1;
  [m p n stats] = ttest2(blank_low, blank_high);
  p_herzthresh(end+1) = p;
end

low
high

p = [p_slowerfaster; p_firstsecond; p_herzthresh];


fasterslower = num_each_cell_slower_faster./length(rip_firsthalf);
firstsecond = num_each_cell_first_second./length(rip_firsthalf);
herzthresh = num_each_cell_threshold;

size(num_each_cell_slower_faster);
size(num_each_cell_first_second);
