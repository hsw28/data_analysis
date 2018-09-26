function f = findripMUA(posData, clusters, time)
%outputs ripple start times. also have ripple end times if need later. do not have peaks right now

velthreshold = 10;
vel = velocity(posData);

spikenames = (fieldnames(clusters));
spikenum = length(spikenames);

%combine all structure data
allspikes = [];
for k=1:spikenum
  spikename = char(spikenames(k));
  unit = clusters.(spikename);
  allspikes = allspikes(unit, allspikes);
end
allspikes = sort(allspikes);

assvelspikes = assignvelOLD(allspikes, vel);
slowspikeindex = find(assvelspikes <= velthreshold);
slowspikes = allspikes(slowspikeindex) %these are all the spikes that happen when animal is stopped

assvel = assignvel(time, vel);
slowvel = find(assvel(2,:) <= velthreshold);
slowtime = assvel(1,slowvel);

%to get bins of 1ms, it will be 2 timestamps
numspikes = [];
while k <= slowtime-1;
    currenttime = slowtime(k:k+1);
    intime = ismember(allspikes, currenttime);
    intime = find(intime==1);
    intime = size(intime);
    numspikes(end+1) = intime;
    k = k+1;
end

meanrate = mean(numspikes); %mean number of spikes per 1ms
stddev = std(numspikes); %std dev of spikes
lotsofspikes = meanrate+(stddev*3); %three standard devs above mean-- this is what we want for ripple detection

starttime = [];
endtime = [];
peaktime = [];
while k <= slowtime-1;
  currenttime = slowtime(k:k+1);
  intime = ismember(allspikes, currenttime);
  intime = find(intime==1);
  intime = size(intime);
  i = k;
  j = k;
  if intime >= lotsofspikes %detected event
  %  riptime = (riptime, currenttime); %adds current time to ripple times
      while i>0
        lesstime = slowtime(i-1:i);
        intimeless = ismember(allspikes, lesstime);
        intimeless = find(intimeless==1);
        intimeless = size(intimeless);
        if size(intimeless) > meanrate+(.5*stddev) % looks to see when value returns to half a std dev above mean, this is the start of the ripple time
            i=i-2;
        else
           starttimetemp = lesstime(1);
           i = 0;
        end
      end
      while j < slowtime-1 % looks to see when value returns to half a std dev above mean, this is the end of the ripple time
        moretime = slowtime(j:j+1);
        inmoretime = ismember(allspikes, moretime);
        inmoretime = find(inmoretime==1);
        inmoretime = size(inmoretime);
        if size(intimeless) > meanrate+(.5*stddev)
          j = j+1;
        else
        endtimetemp = moretime(2)
        j = slowtime;
        end
      end
      if endtimetemp - starttimetemp >= .03 %making sure meets length
        starttime(end+1) = starttimetemp;
        endtime(end+1) = endtimetemp;
      end
    end
  k = j+1;
end
