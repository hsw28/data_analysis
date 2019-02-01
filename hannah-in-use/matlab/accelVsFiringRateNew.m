function f = accelVsFiringRateNew(time, accelORvel, firingdata, binsize)
%binsize in cm/sec or cm/sec2. RIGHT NOW SET AS TEN DEFAULT
%finds occupancy per velocity, then finds spikes per velocity
%divies spikes per velocity by occupancy per velocity to get normalized spikes per velocity

%DO I WANT TO SMOOTH VEL??
%DO WE WANT A THRESHOLD FOR LOW OCCUPANCY


binsize = 5;
mintime = accelORvel(2,1);
maxtime = accelORvel(2,end);

[c indexmin] = (min(abs(time-mintime)));
[c indexmax] = (min(abs(time-maxtime)));
time = time(indexmin:indexmax);

[c indexmin] = (min(abs(firingdata-mintime)));
[c indexmax] = (min(abs(firingdata-maxtime)));
firingdata = firingdata(indexmin:indexmax);

newtime = time(1):1/30:time(end);
accelORvel = assignvel(newtime, accelORvel);

spikevel = assignvelOLD(firingdata,accelORvel);
minvel = min(spikevel(1,:));
maxvel = max(spikevel(1,:));


%bin speed into  bins
binnum = ceil((maxvel-minvel)./binsize);

[spikepervel edges] = histcounts(spikevel, binnum); %fassign velocities to each spike time
assvel = assignvel(time, accelORvel);
[velcounts, edges] = histcounts(assvel(1,:), edges); % find velocity distribution

figure
subplot(3,2,1)
centers = (edges(1:end-1) + edges(2:end))/2;
velcounts = velcounts/2000;
bar(centers, velcounts);
title('Acceleration Occupancy','FontSize',16)
xlabel('Acceleration (cm/s^2)', 'FontSize',14)
ylabel('Time (s)','FontSize',14)
set(gca,'TickDir','out');

subplot(3,2,2)
centers = (edges(1:end-1) + edges(2:end))/2;
bar(centers, spikepervel);
title('Spike Count as a Function of Acceleration','FontSize',16)
xlabel('Acceleration (cm/s^2)','FontSize',14)
ylabel('Spike Count','FontSize',14)
set(gca,'TickDir','out');


%divide spiking per each velocity by how much time in each velocity
normspike = spikepervel./velcounts;
%f = normspike;
%subplot(5,2,3:6)
%centers = (edges(1:end-1) + edges(2:end))/2;
%bar(centers, normspike)
%hold on
%scatter(centers, normspike)


threshold = sum(velcounts)*.05
sum01 = 0;
k = 0;
while sum01 < threshold
  sum01 = sum01+velcounts(end-k)+velcounts(k+1);
  k = k+1;
end
  k;
  knew = min(abs(centers(end-k-1)), abs(centers(k)));

if knew-300>200
  knew = 300
end
[c posk] = min(abs(centers(:)-knew));
[c negk] = min(abs(centers(:)-(-1*knew)));
pk = max(posk, negk);
nk = min(posk, negk);
posthreshold01 = centers(pk);
negthreshold01 = centers(nk);
%posthreshold02 = centers(end-k-1)
%negthreshold02 = centers(k)
%negthresholdindex = k;
%posthresholdindex = length(velcounts)-k+1;
negthresholdindex = nk;
posthresholdindex = pk;
vline(posthreshold01);
vline(negthreshold01);


threshold = sum(velcounts)*.05;
sum02 = 0;
k = 0;
while sum02 < threshold
  sum02 = sum02+velcounts(end-k)+velcounts(k+1);
  k = k+1;
end
posthreshold001 = centers(end-k-1);
negthreshold001 = centers(k);
%vline(posthreshold001);
%vline(negthreshold001);


%str2 = {'1% Acceleration', 'occupancy threshold'};
%str3 = {'0.1% Acceleration', 'occupancy threshold'};
%text(negthreshold01,max(normspike),str2);
%text(negthreshold001,max(normspike)*.6,str3);
%text(posthreshold01,max(normspike),str2);
%text(posthreshold001,max(normspike)*.6,str3);

title('Spike Count as a function of Acceleration')
ylabel('Spike Count')
set(gca,'TickDir','out');

subplot(3,2,3:6)
currentcenters= centers(negthresholdindex:posthresholdindex);
currentnormspike = normspike(negthresholdindex:posthresholdindex);
scatter(currentcenters, currentnormspike);
hold on
%for positive values
[c center0index] = min(abs(centers-0));
posx = centers(center0index:posthresholdindex);
posy = normspike(center0index:posthresholdindex);
coeffs = polyfit(posx, posy, 1);
posslope = coeffs(1);
polydata = polyval(coeffs,posx);
sstot = sum((posy - mean(posy)).^2);
ssres = sum((posy - polydata).^2);
posrsquared = 1 - (ssres / sstot); % get r^2 value
stats = fitlm(posx,posy);
pospval = stats.Coefficients.pValue(2);
y = polyval(coeffs,posx);
plot(posx, y, 'LineWidth', 2) % best fit line
%str1 = {'pos slope' posslope, 'pos p value' pospval, 'pos r2 value' posrsquared};
str1 = {'pos p value' pospval, 'pos r2 value' posrsquared};
pospval
%text(currentcenters(end)-150,max(currentnormspike)*.5,str1, 'FontSize',13);

%for negative values
[c center0index] = min(abs(centers-0));
negx = centers(negthresholdindex:center0index);
negy = normspike(negthresholdindex:center0index);
coeffs = polyfit(negx, negy, 1);
negslope = coeffs(1);
polydata = polyval(coeffs,negx);
sstot = sum((negy - mean(negy)).^2);
ssres = sum((negy - polydata).^2);
negrsquared = 1 - (ssres / sstot); % get r^2 value
stats = fitlm(negx,negy);
negpval = stats.Coefficients.pValue(2);
y = polyval(coeffs,negx);
plot(negx, y, 'LineWidth', 2) % best fit line
%str1 = {'neg slope' negslope, 'neg p value' negpval, 'neg r2 value' negrsquared}
str1 = {'neg p value' negpval, 'neg r2 value' negrsquared};
negpval
 %text(currentcenters(3),max(currentnormspike)*.5,str1,'FontSize',13);

title('Firing Rate as a function of Acceleration within 99% Occupancy','FontSize',16)
xlabel('Acceleration (cm/s^2)','FontSize',14)
ylabel('Spike Rate (spikes/sec)','FontSize',14)
set(gca,'TickDir','out');


%%% BELOW IS FOR ALL< WHICH IS NOT PLOTTED RIGHT NOW
allx = centers(negthresholdindex:posthresholdindex);
ally = normspike(negthresholdindex:posthresholdindex);
coeffs = polyfit(allx, ally, 1);
allslope = coeffs(1);
polydata = polyval(coeffs,allx);
sstot = sum((ally - mean(ally)).^2);
ssres = sum((ally - polydata).^2);
allrsquared = 1 - (ssres / sstot); % get r^2 value
stats = fitlm(allx,ally);
allpval = stats.Coefficients.pValue(2);
y = polyval(coeffs,allx);




f = [negslope; negrsquared;  negpval; posslope; posrsquared; pospval; allslope; allrsquared; allpval];
