function f = LStrigger(time, vel, clusters, timewin)
%timewin is in ms


timewinsec = timewin/1000;
timewin = (timewin/1000*2000);
velthreshold = 5;

spikenames = (fieldnames(clusters));
spikenum = length(spikenames);

%combine all structure data
allspikes = [];
for k=1:spikenum
  spikename = char(spikenames(k));
  unit = clusters.(spikename);
  allspikes = vertcat(allspikes, unit);
end
allspikes = sort(allspikes);


assvel = assignvel(time, vel);
vel = assvel(1,:);
time = assvel(2,:);
allspikes = cutclosest(time(1), time(end), allspikes, allspikes);
tm = 1;
i=1;
highvel = 0;
numspikes = 0;
timewin2 = 15;
numspikes = [];
goodspikes = [];
vel = smoothdata(vel, 'gaussian', 90);

allspikes = cutclosest(time(1), time(end), allspikes, allspikes);
binnum = floor(length(time)./timewin);
[binnedspikesnum, edges] = histcounts(allspikes,binnum);

velav = bintheta(vel, timewinsec, 0, 2000);
[timebins, timeedges] = histcounts(time,binnum);

size(velav)
size(binnedspikesnum)


goodbin = [];
numspikes = [];
n =1;
%while n <= 1:length(vel)./timewin
%  if length(find(vel(n:n+timewin)<velthreshold))==timewin
for n=1:length(velav)
  if velav(n)<velthreshold
    numspikes(end+1) = binnedspikesnum(n);
  end
  n = n+timewin;
end

figure
histogram(numspikes)

meanrate = mean(numspikes);
stddev = std(numspikes);
lotsofspikes = meanrate+(stddev*2);


starttime = [];
endtime = [];
peaktime = [];
peakamount = [];

k=1;
count = 0;
while k <= length(velav)
  i = k;
  j = k;
  if binnedspikesnum(k) >= lotsofspikes & length(find(vel((k-1)*timewin+1:k*timewin)<velthreshold))==timewin

      while i>1
        if binnedspikesnum(i) > meanrate+(.5*stddev) & length(find(vel((i-1)*timewin+1:i*timewin)<velthreshold))==timewin;% looks to see when value returns to half a std dev above mean, this is the start of the ripple time
            i=i-1;
        else
           %starttimetemp = edges(i+1);
           break
        end
      end

      while j <= length(velav) % looks to see when value returns to half a std dev above mean, this is the end of the ripple time
        if binnedspikesnum(j) > meanrate+(.5*stddev) & length(find((vel(((j-1)*timewin+1):(j*timewin))<velthreshold)))==timewin;
          j = j+1;
        else
        %endtimetemp =  edges(j+1);
          break
        end
      end

      %finding peak
      [M,pki]  = max(binnedspikesnum(i+1:j-1));
      peaktime(end+1)= timeedges(i+1+pki);
      peakamount(end+1)= M;
      %end

    end
  k = j+1;
end

f = [peaktime; peakamount];
%f = unique(peaktime);
