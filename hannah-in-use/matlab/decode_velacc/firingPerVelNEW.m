function f = firingPerVelNEW(time, accelORvel, firingdata, vbin);

mintime = accelORvel(2,1);
maxtime = accelORvel(2,end);

[c indexmin] = (min(abs(time-mintime)));
[c indexmax] = (min(abs(time-maxtime)));
time = time(indexmin:indexmax);

[c indexmin] = (min(abs(firingdata-mintime)));
[c indexmax] = (min(abs(firingdata-maxtime)));
firingdata = firingdata(indexmin:indexmax);

spikevel = assignvelOLD(firingdata,accelORvel);

%bin speed into  bins
assvel = assignvel(time, accelORvel);
edges = vbin;
edges(end+1) = max(assvel(1,:));



spikepervel = histcounts(spikevel, edges); %fassign velocities to each spike time
velcounts = histcounts(assvel(1,:), edges); % find velocity distribution

velcounts = velcounts/2000;
normspike = spikepervel./velcounts;

%{
threshold = sum(velcounts)*.01;
sum01 = 0;
k = 0;
while sum01 < threshold
  sum01 = sum01+velcounts(end-k);
  k = k+1;
end
thresholdindex = length(velcounts)-k+1;

normspike(thresholdindex:end) = mean(normspike);
%}


%%%
f = normspike;
%centers = (edges(1:end-1) + edges(2:end))/2;
%bar(centers, normspike)
%figure
%scatter(centers, normspike)
