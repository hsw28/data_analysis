function f = findripMUA(time, vel, clusters, timewin)
%timewin is in ms
%outputs ripple start times. also have ripple end times if need later. do not have peaks right now
if timewin<1
  error('I think you entered time in seconds not in ms')
end

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
goodspikes = [];
vel = smoothdata(vel, 'gaussian', 90);
allspikes = cutclosest(time(1), time(end), allspikes, allspikes);
binnum = floor(length(time)./timewin);
[binnedspikesnum, edges] = histcounts(allspikes,binnum);
velav = bintheta(vel, timewinsec, 0, 2000);
[timebins, timeedges] = histcounts(time,binnum);


goodbin = [];
numspikes = [];
n = 1;
for n=1:length(velav)
  if velav(n)<velthreshold
    numspikes(end+1) = binnedspikesnum(n);
  end
end

meanrate = mean(numspikes)
stddev = std(numspikes)
lotsofspikes = meanrate+(stddev*3.5)


starttime = [];
endtime = [];
peaktime = [];
k=2;
count = 0;
while k <= length(velav)
  i = k;
  j = k;
  if binnedspikesnum(k) >= lotsofspikes &  length(find((vel(round((k-1)*timewin+1):round(k*timewin))))<velthreshold)==timewin;
      while i>1
        if binnedspikesnum(i) > meanrate+(.5*stddev) & length(find((vel(round((i-1)*timewin+1):round(i*timewin))<velthreshold)))==timewin  %looks to see when value returns to half a std dev above mean, this is the start of the ripple time
            i=i-1;
        else
           starttimetemp = edges(i+1);
           break
        end
      end

      while j <= length(velav) % looks to see when value returns to half a std dev above mean, this is the end of the ripple time
        if binnedspikesnum(j) > meanrate+(.5*stddev) & length(find((vel(round((j-1)*timewin+1):round(j*timewin))<velthreshold)))==timewin;
          j = j+1;
        else
        endtimetemp =  edges(j+1);
          break
        end
      end

      if endtimetemp - starttimetemp >= .03 && endtimetemp - starttimetemp <= .1 %making sure meets length
        starttime(end+1) = starttimetemp;
        endtime(end+1) = endtimetemp;
      %end
      end
    end
  k = j+1;
end


f = [unique(starttime); unique(endtime)];
