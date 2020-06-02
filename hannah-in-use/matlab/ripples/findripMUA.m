function f = findripMUA(time, posData, clusters, timewin)
%timewin is in ms
%outputs ripple start times. also have ripple end times if need later. do not have peaks right now
if timewin<=3
  error('I think you entered time in seconds not in ms')
end

timewinsec = timewin/1000;
timewin = (timewin/1000*2000);
velthreshold = 5;

posData = fixpos(posData);
vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
velnum = vel(1,:);
velav = bintheta(velnum, timewinsec, 0, 2000);



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


allspikes = cutclosest(vel(2,1), vel(2,end), allspikes, allspikes);
tm = 1;
i=1;
highvel = 0;
numspikes = 0;
timewin2 = 15;
goodspikes = [];

binnum = floor(length(time)./timewin);
[binnedspikesnum, edges] = histcounts(allspikes,binnum);
[timebins, timeedges] = histcounts(time,binnum);

binnedspikesnum = smoothdata(binnedspikesnum, 'gaussian', 4);

%goodbin = [];
%numspikes = [];
%n = 1;
%for n=1:length(velav)
%  if velav(n)<velthreshold
%    numspikes(end+1) = binnedspikesnum(n);
%  end
%end

meanrate = mean(binnedspikesnum)
stddev = std(binnedspikesnum)
lotsofspikes = (meanrate+(stddev*2))


starttime = [];
endtime = [];
peaktime = [];
k=2;
count = 0;
while k <= length(binnedspikesnum)
  i = k;
  j = k;


  if binnedspikesnum(k) >= lotsofspikes %&  length(find((vel(round((k-1)*timewin+1):round(k*timewin))))<velthreshold)==timewin;

      while i>=1 %& round(i*timewin)<length(vel)
        if binnedspikesnum(i) > meanrate+(.5*stddev) & i>1 %& length(find((vel(round((i-1)*timewin+1):round(i*timewin))<velthreshold)))==timewin  %looks to see when value returns to half a std dev above mean, this is the start of the ripple time
            i=i-1;
        else
           starttimetemp = edges(i+1);
           break;
        end
      end

      while j <= length(binnedspikesnum) % looks to see when value returns to half a std dev above mean, this is the end of the ripple time
        if binnedspikesnum(j) > meanrate+(.5*stddev) %& length(find((vel(round((j-1)*timewin+1):round(j*timewin))<velthreshold)))==timewin;
          j = j+1;
        else
        endtimetemp =  edges(j+1);
          break;
        end
      end

endtimetemp - starttimetemp;

      if endtimetemp - starttimetemp >= .03 && endtimetemp - starttimetemp <= .1 %making sure meets length
        starttime(end+1) = starttimetemp;
        endtime(end+1) = endtimetemp;
      end
    end
  k = j+1;
end


f = [unique(starttime); unique(endtime)];
