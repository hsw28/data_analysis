function f = velVsFiringRateNew(time, accelORvel, firingdata, binsize)
%binsize in cm/sec or cm/sec2-- RIGHT NOW SET AS ONE DEFAULT
%finds occupancy per velocity, then finds spikes per velocity
%divies spikes per velocity by occupancy per velocity to get normalized spikes per velocity

%DO I WANT TO SMOOTH VEL??
%DO WE WANT A THRESHOLD FOR LOW OCCUPANCY

binsize = 2;
mintime = accelORvel(2,1);
maxtime = accelORvel(2,end);

[c indexmin] = (min(abs(time-mintime)));
[c indexmax] = (min(abs(time-maxtime)));
time = time(indexmin:indexmax);

[c indexmin] = (min(abs(firingdata-mintime)));
[c indexmax] = (min(abs(firingdata-maxtime)));
firingdata = firingdata(indexmin:indexmax);




%assvel = assignvel(time, accelORvel);   %COMMENT OUT
%spikevel = assignvelOLD(firingdata,assvel); %COMMENT OUT
spikevel = assignvelOLD(firingdata,accelORvel);
minvel = min(spikevel(1,:));
maxvel = max(spikevel(1,:));


%bin speed into  bins
binnum = ceil((maxvel-minvel)./binsize);

[spikepervel edges] = histcounts(spikevel, binnum); %fassign velocities to each spike time
assvel = assignvel(time, accelORvel);
[velcounts, edges] = histcounts(assvel(1,:), edges); % find velocity distribution

%figure
%subplot(5,2,1)
%subplot(3,2,1)
centers = (edges(1:end-1) + edges(2:end))/2;
velcounts = velcounts/2000;
%bar(centers, velcounts);
%title('|Velocity| Occupancy', 'FontSize',16)
%xlabel('|Velocity| (cm/s)', 'FontSize',14)
%ylabel('Time (s)', 'FontSize',14)
%set(gca,'TickDir','out');


%subplot(5,2,2)
%subplot(3,2,2)
centers = (edges(1:end-1) + edges(2:end))/2;
bar(centers, spikepervel);
%title('Spike Count as a Function of |Velocity|','FontSize',16)
%xlabel('|Velocity| (cm/s)','FontSize',14)
%ylabel('Spike Count','FontSize',14)
%set(gca,'TickDir','out');


%divide spiking per each velocity by how much time in each velocity
normspike = spikepervel./velcounts;
%f = normspike;
%subplot(5,2,3:6)
%centers = (edges(1:end-1) + edges(2:end))/2;
%hold on
%scatter(centers, normspike)


threshold = sum(velcounts)*.05;
sum01 = 0;
k = 0;
while sum01 < threshold
  sum01 = sum01+velcounts(end-k);
  k = k+1;
end
threshold01 = centers(end-k+1);
thresholdindex = length(velcounts)-k+1;
%vline(threshold01);


threshold = sum(velcounts)*.05;
sum02 = 0;
k = 0;
while sum02 < threshold
  sum02 = sum02+velcounts(end-k);
  k = k+1;
end
threshold001 = centers(end-k+1);
%vline(threshold001);


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
%plot(x, y) % best fit line



%str2 = {'1% |Velocity|', 'occupancy threshold'};
%str3 = {'0.1% |Velocity|', 'occupancy threshold'};
%text(threshold01,max(normspike)*.75,str2);
%text(threshold001,max(normspike)*.75,str3);

%itle('Firing Rate as a function of |Velocity|')
%ylabel('Spike Rate (spikes/sec)')
%set(gca,'TickDir','out');



%subplot(3,2,3:6)

currentcenters= centers(1:thresholdindex);
currentnormspike = normspike(1:thresholdindex);
scatter(currentcenters, currentnormspike, '.k');
hold on
if pval <= .05
  plot(x, y, 'r', 'LineWidth', 1.5) % best fit line
else
  plot(x, y, 'black', 'LineWidth', 1.5) % best fit line
end
%str1 = {'slope' slope, 'p value' pval, 'r2 value' rsquared};
str1 = {'p value' pval, 'r2 value' rsquared};
%text(25,max(currentnormspike)*.9,str1,'FontSize',12);
%title('Firing Rate as a function of |Velocity| within 99% Occupancy','FontSize',16)
%xlabel('|Velocity| (cm/s)','FontSize',14)
%ylabel('Spike Rate (spikes/sec)','FontSize',14)
%set(gca,'TickDir','out');

f = [slope; rsquared; pval];
