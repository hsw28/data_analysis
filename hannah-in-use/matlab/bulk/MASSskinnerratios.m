function f = MASSskinnerratios(spikestructure, time, cueOn)
  %use clusterimport.m create spike structures
  %input time vector and vector of cue times



% group timestructure
cueOn;
foodOn = cueOn+8;
foodEnd = foodOn+8;
cueOnindex=[];
foodOnindex=[];
foodEndindex=[];
for k=1:length(cueOn)
    [c cueindex] = min(abs(time-cueOn(k)));
    [c foodindex] = min(abs(time-foodOn(k)));
    [c endindex] = min(abs(time-foodEnd(k)));
    cueOnindex(end+1) = cueindex;
    foodOnindex(end+1) = foodindex;
    foodEndindex(end+1) = endindex;
end

if length(cueOnindex) ~= length(foodOnindex) | length(foodOnindex) ~= length(foodEndindex) | length(cueOnindex) ~= length(cueOn)
  length(cueOnindex)
  length(foodOnindex)
  length(foodEndindex)
    warning('your lengths are wonky')
end

%finding times
k = 1;
cueOnly = [];
timecueOnly = 0;
reward = [];
timereward = 0;
intertrial = [];
timeintertrial = 0;
while k <= length(cueOnindex)
    cue = time(cueOnindex(k):foodOnindex(k));
    timecueOnly = timecueOnly + (cue(end)-cue(1));
    cueOnly = horzcat(cueOnly, cue);
    food = time(foodOnindex(k):foodEndindex(k));
    timereward = timereward + (food(end)-food(1));
    reward = horzcat(reward, food);

    %THIS USED TO MAKE ALL TIMES THE INTERTRIAL SPIKE RATE, I THINK WE ONLY WANT 8 SEC
    %if k == 1
    %    base = time(1:foodOnindex(k));
    %else
    %    base = time(foodOnindex(k-1):foodOnindex(k));
    %end
    %timeintertrial = timeintertrial + (base(end)-base(1));
    %intertrial = horzcat(intertrial, base);

    %NEW
        base = time(cueOnindex(k)-16000:cueOnindex(k));
        timeintertrial = timeintertrial + (time(cueOnindex(k))-time(cueOnindex(k)-16000));
        intertrial = horzcat(intertrial, base);



k = k +1;
end
% now you have all times for intertrial, cueOnly, and reward, and how long each is in seconds

output = {'cluster'; 'num of spikes';'base spikes/s'; 'cue spikes/s'; 'cue change'; 'R spikes/s'; 'R change'};

% time to go through the clusters
%determine how many spikes
spikenames = (fieldnames(spikestructure));
spikenum = length(spikenames);

for k = 1:spikenum
    name = char(spikenames(k));
    currentspike = spikestructure.(name);

    spikesIntertrial = intersect(currentspike, intertrial);
    spikesCue = intersect(currentspike, cueOnly);
    spikesReward = intersect(currentspike, reward);

    %finding rates
    rateIntertrial = length(spikesIntertrial)/timeintertrial;
    rateCue = length(spikesCue)/timecueOnly;
    rateReward = length(spikesReward)/timereward;

    %finding difference from baseline
    changeCue = rateCue/rateIntertrial;
    changeReward = rateReward/rateIntertrial;

    %makes output vector
    newdata = {name; length(currentspike); rateIntertrial; rateCue; changeCue; rateReward; changeReward};

    output = horzcat(output, newdata);

  end

% outputs chart with spike name, number of spikes, slope, and r2 value
  f = output';
