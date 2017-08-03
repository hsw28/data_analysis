function thingy = powerVsFiringRate(lfpdata,time, firingdata, L)
% Takes LFP data, timestamps, cluster data, and window size (in samples)
% Produces plots that relate Firing Rate in window to relative Theta Power
% in window
% length of the time window is determined by actual sampling rate and
% integer # of window samples. There is a print statement that returns
% window length in seconds


% close all;
% lfpdata = lfpmaze19.data;
% time = lfpmaze19.timestamp*7.75e-2;
% firingdata = mazet22c1*7.75e-2;
% L = 350;
start = min(time);
ending = max(time);
Fs = length(lfpdata)/(ending-start);
t = L/Fs
r = mua_rate(firingdata,start,ending,t);
info = thetaPowerVsTime(lfpdata,time,L,L);
rate = r(2,:);
times = info(:,1);
powers = info(:,2);
fastest = max(rate);
% length(rate)
% length(powers)
figure
scatter(powers,rate/t)
xlabel('Theta Power Ratio');
ylabel('Firing rate/Sec.');
average = zeros(fastest+1,1);
deviation = zeros(fastest+1,1);
threshold = .01 * length(rate);
for i = 0:fastest
     subset = powers(rate == i);
     if length(subset) < threshold
         average(i+1) = NaN;
         deviation(i+1) = NaN;
     else
        average(i+1) = mean(subset);
        deviation(i+1) = std(subset,1);
     end
end

% figure
% errorbar((0:fastest)/t,average,deviation,'o')
% xlabel('Firing rate');
% ylabel('Average Theta Power Ratio');

figure
scatter(average,(0:fastest)/t)
xlabel('Average Theta Power Ratio');
ylabel('Firing rate/Sec.');
lsline
% figure
% scatter(deviation, (0:fastest)/t)
% xlabel('Deviation of Theta Power Ratio');
% ylabel('Firing rate/Sec');
thingy = [average,deviation,(0:fastest)'/t];
