function f = accelVsFiringRateNew(time, accelORvel, firingdata, binsize)
%binsize in cm/sec or cm/sec2
%finds occupancy per velocity, then finds spikes per velocity
%divies spikes per velocity by occupancy per velocity to get normalized spikes per velocity

%DO I WANT TO SMOOTH VEL??
%DO WE WANT A THRESHOLD FOR LOW OCCUPANCY

mintime = accelORvel(2,1);
maxtime = accelORvel(2,end);

[c indexmin] = (min(abs(time-mintime)));
[c indexmax] = (min(abs(time-maxtime)));
time = time(indexmin:indexmax);

[c indexmin] = (min(abs(firingdata-mintime)));
[c indexmax] = (min(abs(firingdata-maxtime)));
firingdata = firingdata(indexmin:indexmax);


spikevel = assignvelOLD(firingdata,accelORvel);
minvel = min(spikevel(1,:));
maxvel = max(spikevel(1,:));


%bin speed into 3cm/sec bins
binnum = ceil((maxvel-minvel)./binsize) %4cm/sec bins

[spikepervel edges] = histcounts(spikevel, binnum); %fassign velocities to each spike time
assvel = assignvel(time, accelORvel);
[velcounts, edges] = histcounts(assvel(1,:), edges); % find velocity distribution

figure
subplot(4,1,1)
centers = (edges(1:end-1) + edges(2:end))/2;
velcounts = velcounts/2000;
bar(centers, velcounts)
title('|Velocity| Occupancy')
xlabel('|Velocity| (cm/s)')
ylabel('Time (s)')


subplot(4,1,2)
centers = (edges(1:end-1) + edges(2:end))/2;
bar(centers, spikepervel)
title('Spike Count as a Function of |Velocity|')
xlabel('|Velocity| (cm/s)')
ylabel('Spike Count')


%divide spiking per each velocity by how much time in each velocity
normspike = spikepervel./velcounts;
%f = normspike;
subplot(4,1,3:4)
centers = (edges(1:end-1) + edges(2:end))/2;
%bar(centers, normspike)
hold on
scatter(centers, normspike)


threshold = sum(spikepervel)*.01
[c thresholdindex]= min(abs(threshold-spikepervel));
vline(centers(thresholdindex))

threshold = sum(spikepervel)*.001
[c thresholdindex2]= min(abs(threshold-spikepervel));
vline(centers(thresholdindex2))

x = centers(1:thresholdindex);
y = normspike(1:thresholdindex);

coeffs = polyfit(x, y, 1);
slope = coeffs(1);
polydata = polyval(coeffs,x);
sstot = sum((y - mean(y)).^2);
ssres = sum((y - polydata).^2);
rsquared = 1 - (ssres / sstot); % get r^2 value


stats = fitlm(x,y);
pval = stats.Coefficients.pValue(2);

y = polyval(coeffs,x);
plot(x, y) % best fit line


str1 = {'slope' slope, 'p value' pval, 'r2 value' rsquared};
text(1,max(normspike)*.75,str1)

str2 = {'1% |Velocity|', 'occupancy threshold'};
str3 = {'0.1% |Velocity|', 'occupancy threshold'};
text(centers(thresholdindex),max(normspike)*.75,str2);
text(centers(thresholdindex2),max(normspike)*.75,str3);

title('Firing Rate as a function of |Velocity|')
xlabel('|Velocity| (cm/s)')
ylabel('Spike Rate (spikes/sec)')
