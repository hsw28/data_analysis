function f = accelVsFiringRateNew(time, accelORvel, firingdata, binsize)
%binsize in cm/sec or cm/sec2
%finds occupancy per velocity, then finds spikes per velocity
%divies spikes per velocity by occupancy per velocity to get normalized spikes per velocity
assvel = (assignvel(time,accelORvel));
minvel = min(assvel(2,:));
maxvel = max(assvel(2,:));

%bin speed into 3cm/sec bins
figure
binnum = ceil((maxvel-minvel)./binsize); %4cm/sec bins
[velcounts, edges] = histcounts(assvel(2,:), binnum);
subplot(1,3,1)
centers = (edges(1:end-1) + edges(2:end))/2;
bar(centers, velcounts)
title('Velocity Occupancy')
xlabel('Speed (cm/s)')
ylabel('Time (s)')

%assign velocities to each spike time
spikevel = assignvel(firingdata,accelORvel);
[spikepervel edges2] = histcounts(spikevel(2,:), binnum, edges); %find spiking for each velocity
subplot(1,3,2)
centers = (edges(1:end-1) + edges(2:end))/2;
bar(centers, spikepervel)
title('Spike Count as a Function of Velocity')
xlabel('Speed (cm/s)')
ylabel('Spike Count')


%divide spiking per each velocity by how much time in each velocity
normspike = spikepervel./velcounts;
f = normspike;
subplot(1,3,3)
centers = (edges(1:end-1) + edges(2:end))/2;
bar(f, spikepervel)
title('Firing Rate as a function of speed')
xlabel('Speed (cm/s)')
ylabel('Spike Rate (spikes/sec)')
