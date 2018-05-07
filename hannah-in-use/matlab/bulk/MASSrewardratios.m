function f = MASSrewardratios(spikestructure, time, entrytime, n)
  %use clusterimport.m create spike structures
  %input time vector and entry time vector from rewardtimes.m
  % n is time around entry time in seconds you want data
  %outputs

if size(entrytime,2)>1
   entrytime = entrytime(:,1);
end



% group timestructure
entrytime;
timebefore = entrytime-n;
timein = entrytime+n;
entryindex = [];
beforeindex = [];
inindex = [];
for k=1:length(entrytime)
    [c before] = min(abs(time-timebefore(k)));
    [c entry] = min(abs(time-entrytime(k)));
    [c in] = min(abs(time-timein(k)));
    beforeindex(end+1) = before;
    entryindex(end+1) = entry;
    inindex(end+1) = in;
end




%finding times
k = 1;
before = 0;
in = 0;
beforetime = [];
intime = [];
while k <= length(entrytime)
    before = time(beforeindex(k):entryindex(k));
    in = time(entryindex(k):inindex(k));

    beforetime = horzcat(beforetime, before);
    intime = horzcat(intime, in);

    k = k +1;
end

output = {'cluster'; 'num of spikes';'before spikes/s'; 'in spikes/s'; 'in change'};

% time to go through the clusters
%determine how many spikes
spikenames = (fieldnames(spikestructure));
spikenum = length(spikenames);
spikesbefore = [];
spikesin = [];
newdata = [];
output = [];
for k = 1:spikenum
    name = char(spikenames(k));
    currentspike = spikestructure.(name);

    spikesbefore = intersect(currentspike, beforetime);
    spikesin = intersect(currentspike, intime);

    %finding rates
    rateBEFORE = length(spikesbefore)/(n*length(entrytime));
    rateIN = length(spikesin)/(n*length(entrytime));

    %finding difference from baseline
    changeIN = rateIN/rateBEFORE;

    %makes output vector
    newdata = {name; length(currentspike); rateBEFORE; rateIN; changeIN};

    output = horzcat(output, newdata);

  end

% outputs chart with spike name, number of spikes, slope, and r2 value
  f = output';
