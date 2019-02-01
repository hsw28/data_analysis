function thingy = accelVsFiringRate(time, accelORvel, firingdata, t, varargin)
% Takes pos data, timestamps, cluster data, and window size (in seconds)
% Produces plots that relate Firing Rate in window to acceleration
% in window
% length of the time window is determined by actual sampling rate and
% integer # of window samples. There is a print statement that returns
% window length in seconds
% can also use for velocity
%if you want a subset of times, put the INDEX values in varargin

% close all;
% time = lfpmaze19.timestamp*7.75e-2;
% firingdata = [mazet19c3;mazet19c4;mazet29c1]*7.75e-2;
% t = .1736;


%MAKE INTO TIME STAMPS AND NOT RAW time

starttime = accelORvel(2,1);
endtime = accelORvel(2,end);
starttime = find(abs(t.(timeformateddate)-starttime) < .001);
endtime = find(abs(t.(timeformateddate)-endtime) < .001);
starttime = starttime(1,1);
endtime = endtime(1,1);
t = [t(starttime:endtime)];

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

if length(varargin) > 0
	r = [];
	mat = cell2mat(varargin);
	z = 2;
	y = 1;
	while z<length(mat)
		if mat(z)-mat(z-1) < t*2000
			z = z+1;
		else
			newr = mua_rate(firingdata,time(y),time(z),t);
			y = z;
			z = z+1;
			r = [r, newr];
		end
	end
else
r = mua_rate(firingdata,start,ending,t);
end


%info = thetaPowerVsTime(lfpdata,time,L,L);
rate = r(2,:);
fastest = max(rate);
m = length(rate);
length(rate);

acceldata = (assignvel(time,accelORvel));
acceldata = acceldata(1,:);

if length(varargin) > 0
	acceldata = acceldata(1, mat);
	time = time(mat);
end

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
ylabel('Firing rate/half Sec.');

%figure
%histogram(avg_accel)

%[bootstat,bootsam] = bootstrp(10000,@corr,avg_accel,(rate/t)');
%figure
%histogram(bootstat)

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
ylabel('Firing rate/half Sec.');




%h = vertcat(avg_accel', (rate/t));
%values = hist3(h');
%imagesc(values.')
%colorbar
%axis equal
%axis xy

average = zeros(fastest+1,1);
deviation = zeros(fastest+1,1);
threshold = .05 * length(rate);
%threshold = .01 * length(firingdata);


newvel = [];
newrate = [];
StdError=[];
boots = []
bootmean =[];
singlerate = [];
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
				%newvel = vertcat(newvel,subset);
				%nr = ones(length(subset), 1).*i;
				%newrate = vertcat(newrate,nr);
			%COMMENT IN FOR BOOTSTRAP
				stats = bootstrp(250,@(x)[mean(x)],subset);
				boots = vertcat(boots, stats);
				nr = ones(250, 1).*i.*2;
				newrate = vertcat(newrate,nr);
				bootmean(end+1) = mean(boots);
				singlerate(end+1) = i;


     end
		 StdError(end+1) = std(subset)./sqrt(length(subset));
end




figure
scatter(boots, newrate);
xlabel('Bootstrapped average velocities');
ylabel('Firing rate/half Sec.');
%hold on
%scatter(bootmean, singlerate, 'o')

coeffs = polyfit(bootmean, singlerate, 1);
slope = coeffs(1); % get slope of best fit line
intercept = coeffs(2);
% Get fitted values
polydata = polyval(coeffs,bootmean);
sstot = sum((singlerate - mean(singlerate)).^2);
ssres = sum((singlerate - polydata).^2);
rsquared = 1 - (ssres / sstot) % get r^2 value

%COMMENT IN FOR BOOTSTRAP
%stats = fitlm(boots,newrate);
%bootstrap_pval = stats.Coefficients.pValue;


% figure
% errorbar((0:fastest)/t,average,deviation,'o')
% xlabel('Firing rate');
% ylabel('Average Theta Power Ratio');

figure

%errorbar((0:fastest)/t, average, StdError, 'o')
errorbar(average, (0:fastest)/t, StdError, 'horizontal', 'o')

xlabel('Average Velocity');
ylabel('Firing rate/half Sec.');

%COMMENT BACK
figure
scatter(average,(0:fastest)/t)
%xlabel('Average Velocity');
%ylabel('Firing Rate/Sec.');
%lsline

thingy = [average, (0:fastest)'/t];

x = thingy(:,1);
actualvals = find(~isnan(x));
x = x(actualvals);
y = thingy(:,2);
y = y(actualvals);

coeffs = polyfit(x, y, 1);
slope = coeffs(1); % get slope of best fit line
intercept = coeffs(2);
% Get fitted values
polydata = polyval(coeffs,x);
sstot = sum((y - mean(y)).^2);
ssres = sum((y - polydata).^2);
rsquared = 1 - (ssres / sstot) % get r^2 value

stats = fitlm(x,y);
pval = stats.Coefficients.pValue(2)
