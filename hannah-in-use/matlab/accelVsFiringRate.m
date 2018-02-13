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


%MAKE INTO TIME STAMPS AND NOT RAW time

if size(time, 2) < size(time, 1)
	time = time';
end

if size(accelORvel, 2) < size(accelORvel, 1)
	accelORvel = accelORvel';
end

if size(accelORvel, 2) > size(firingdata, 1)
	firingdata = firingdata';
end

start = min(accelORvel(2,:));
ending = max(accelORvel(2,:));

r = mua_rate(firingdata,start,ending,t);
%info = thetaPowerVsTime(lfpdata,time,L,L);
rate = r(2,:);
fastest = max(rate);
m = length(rate);
length(rate);

acceldata = (assignvel(time,accelORvel));
acceldata = acceldata(1,:);
length(acceldata);
length(time);
avg_accel = zeros(m,1);
time = time(1:length(acceldata));
for i = 1:m

    avg_accel(i) = mean(acceldata((time > start+t*(i-1)) & (time < start+t*i)));

end
% length(powers)


%COMMENT BACK
figure
scatter(avg_accel, rate/t)
xlabel('Average Velocity');
ylabel('Firing Rate/Sec.');

%figure
%size(avg_accel)
%size(rate/t)
%heatscatter((avg_accel), (rate/t)')

figure
Apts = linspace(min(avg_accel), max(avg_accel), 300);
sApts = max(avg_accel)
Rpts = linspace(min(rate/t), max(rate/t), 100);
sRpts = max(rate/t)
N = histcounts2((rate/t)', (avg_accel), Rpts, Apts);
imagesc(Apts, Rpts, N);
colorbar
caxis([2 80])
%axis equal;
set(gca, 'XLim', Apts([1 ceil(end)]), 'YLim', Rpts([1 ceil(end)]), 'YDir', 'normal');
xlabel('Average Velocity');
ylabel('Firing Rate/Sec.');



%h = vertcat(avg_accel', (rate/t));
%values = hist3(h');
%imagesc(values.')
%colorbar
%axis equal
%axis xy

average = zeros(fastest+1,1);
deviation = zeros(fastest+1,1);
threshold = .01 * length(rate);
%threshold = .01 * length(firingdata);



StdError=[];
for i = 0:fastest
     subset = avg_accel(rate == i);
		 length(subset);
     if length(subset) < threshold
         average(i+1) = NaN;
         deviation(i+1) = NaN;
     else
			 	subset=(subset(~isnan(subset)));
        average(i+1) = mean(subset);
        %deviation(i+1) = std(subset,1);
     end
		 StdError(end+1) = std(subset)./sqrt(length(subset));
end

average

% figure
% errorbar((0:fastest)/t,average,deviation,'o')
% xlabel('Firing rate');
% ylabel('Average Theta Power Ratio');

figure

%errorbar((0:fastest)/t, average, StdError, 'o')
errorbar(average, (0:fastest)/t, StdError, 'horizontal', 'o')

xlabel('Average Velocity');
ylabel('Firing rate/Sec.');

%COMMENT BACK
figure
scatter(average,(0:fastest)/t)
%xlabel('Average Velocity');
%ylabel('Firing Rate/Sec.');
%lsline



thingy = [average, (0:fastest)'/t];
