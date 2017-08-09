function thingy = accelVsFiringRate(time, accelORvel, firingdata, t)
% Takes pos data, timestamps, cluster data, and window size (in seconds)
% Produces plots that relate Firing Rate in window to acceleration
% in window
% length of the time window is determined by actual sampling rate and
% integer # of window samples. There is a print statement that returns
% window length in seconds
% can also use for velocity

% close all;
% time = lfpmaze19.timestamp*7.75e-2;
% firingdata = [mazet19c3;mazet19c4;mazet29c1]*7.75e-2;
% t = .1736;

if size(time, 2) < size(time, 1)
	time = time';
end

if size(accelORvel, 2) < size(accelORvel, 1)
	accelORvel = accelORvel';
end

if size(accelORvel, 2) > size(firingdata, 1)
	firingdata = firingdata';
end

start = min(time);
ending = max(time);

r = mua_rate(firingdata,start,ending,t);
%info = thetaPowerVsTime(lfpdata,time,L,L);
rate = r(2,:);
fastest = max(rate);
m = length(rate);

acceldata = (assignvel(time,accelORvel));
length(acceldata);
length(time);
avg_accel = zeros(m,1);
for i = 1:m
    avg_accel(i) = mean(acceldata((time > start+t*(i-1)) & (time < start+t*i)));
end
% length(powers)



figure
scatter(avg_accel,rate/t)

xlabel('Average Acceleration');
ylabel('Firing rate/Sec.');
average = zeros(fastest+1,1);
deviation = zeros(fastest+1,1);
threshold = .01 * length(rate);

for i = 0:fastest
     subset = avg_accel(rate == i);
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
xlabel('Average Acceleration');
ylabel('Firing rate/Sec.');
lsline
% figure
% scatter(deviation, (0:fastest)/t)
% xlabel('Deviation of Theta Power Ratio');
% ylabel('Firing rate');
%thingy = [average,deviation,(0:fastest)'/t];

thingy = [average, (0:fastest)'/t];
