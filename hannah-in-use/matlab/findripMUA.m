function f = findripMUA(time, posData, clusters, timewin)
%timewin is in ms
%outputs ripple start times. also have ripple end times if need later. do not have peaks right now
%for awake periods only as uses position data to get non moving times

timewin = (timewin/1000*2000)-1;
velthreshold = 10;
vel = velocity(posData);

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

assvelspikes = assignvelOLD(allspikes, vel);
slowspikeindex = find(assvelspikes <= velthreshold);
slowspikes = allspikes(slowspikeindex); %these are all the spikes that happen when animal is stopped



assvel = assignvel(time, vel);
slowvel = find(assvel(1,:) <= velthreshold);
slowtime = assvel(2,slowvel);


[c mintime] = min(abs(assvel(2,1)-allspikes));
[c maxtime]= min(abs(assvel(2,end)-allspikes));
allspikes = allspikes(mintime-1:maxtime+1);

%to get bins of 1ms, it will be 2 timestamps
numspikes = [];
k =1;
while k <= length(slowtime)-timewin
    currenttime = slowtime(k:k+timewin);
    intime = ismember(allspikes, currenttime);
    intime = find(intime==1);
    intime = length(intime);
    numspikes(end+1) = intime;
    k = k+timewin;
end
%f = numspikes;
meanrate = mean(numspikes); %mean number of spikes
stddev = std(numspikes); %std dev of spikes
lotsofspikes = meanrate+(stddev*3); %three standard devs above mean-- this is what we want for ripple detection

starttime = [];
endtime = [];
peaktime = [];
k=1;
while k <= length(slowtime)-timewin;
  currenttime = slowtime(k:k+timewin);
  intime = ismember(allspikes, currenttime);
  intime = find(intime==1);
  intime = length(intime);
  i = k;
  j = k;
  if intime >= lotsofspikes %detected event
  %  riptime = (riptime, currenttime); %adds current time to ripple times
      while i>1
        lesstime = slowtime(i-timewin:i);
        intimeless = ismember(allspikes, lesstime);
        intimeless = find(intimeless==1);
        intimeless = length(intimeless);
        if (intimeless) > meanrate+(.5*stddev) % looks to see when value returns to half a std dev above mean, this is the start of the ripple time
            i=i-timewin;
        else
           starttimetemp = lesstime(end);
           break
        end
      end
      while j < length(slowtime)-timewin % looks to see when value returns to half a std dev above mean, this is the end of the ripple time
        moretime = slowtime(j:j+timewin);
        inmoretime = ismember(allspikes, moretime);
        inmoretime = find(inmoretime==1);
        inmoretime = length(inmoretime);
        if (inmoretime) > meanrate+(.5*stddev)
          j = j+timewin;
        else
        endtimetemp = moretime(1);
          break
        end
      end
      if endtimetemp - starttimetemp >= .03 %making sure meets length
        starttime(end+1) = starttimetemp;
        endtime(end+1) = endtimetemp;
      end
    end
  k = j+timewin;
end

f = [unique(starttime), unique(endtime)]
