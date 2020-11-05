function thingy = firingPerPhase(time, cueOn, spike, t)
% timestamps, cuetimes, cluster data (either as single spike or a structure), and window size (in seconds). must fit evenly into 8
%window size determines how many seconds to break cue/reward time into ONLY, not intertrial interval
% outputs average firing rate per velocity/acc

% group timestructure


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


%finding times for intertrial
k = 1;
cueOnly = [];
reward = [];
intertrial = [];
timeintertrial = 0;
postcue = [];
timepostcue = 0;
while k <= length(cueOnindex)
    cue = time(cueOnindex(k):foodOnindex(k));
    cueOnly = horzcat(cueOnly, cue);
    food = time(foodOnindex(k):foodEndindex(k));
    reward = horzcat(reward, food);

		%define start time as first cue starting
		if k == 1
				starting = cueOnindex(k);
				timepostcue = time(foodEndindex(k):foodEndindex(k)+2000);
		else

				%using 18000 (9 seconds) here so you an also get the one second after where firing peaks
				timeintertrial = timeintertrial + (time(cueOnindex(k))-time(foodEndindex(k-1))); %length of time
				base = time(foodEndindex(k-1):cueOnindex(k)); %timestamps
				intertrial = horzcat(intertrial, base); %totaltimestamps

				%time post cue is just number of trials * 1 second
		end

k = k +1;
end




%t is the number of seconds you want to divide cue and reward INTO
%find how many segments that is in 8 seconds
%then permute through all cue and reward times, adding seconds as you go
interval = 2000*t;
segments = 8/t;
cueRates = zeros(1, segments);
rewRates = zeros(1, segments);



structure = isa(spike,'struct');
double = isa(spike,'double');

k = 1;

if structure == 1
clustname = (fieldnames(spike))
numclust = length(clustname);
numofbins = ((8/t)*2)+1;
fxmatrix = zeros(numclust, numofbins);
size(fxmatrix)
j = 1;
while j <= numclust
    name = char(clustname(j));
    k=1;
    z=1;
    while k <=segments
    	z=1;
    	spikesegmentCue = 0;
    	spikesegmentRew = 0;
    	while z <=length(cueOnindex)

    		currentCueTime = time(cueOnindex(z)+(interval*(k-1)):(cueOnindex(z)+(interval*k)));
    		currentRewTime = time(foodOnindex(z)+(interval*(k-1)):(foodOnindex(z)+(interval*k)));
    		%spikesCue = intersect(currentCueTime, spike.(name));
    		%spikesRew = intersect(currentRewTime, spike.(name));

        spikesCue = ismember(spike.(name), currentCueTime);
        spikesCue = find(spikesCue==1);
        spikeCuetest = find(spikesCue==1);

    		spikesRew = ismember(spike.(name), currentRewTime);
        spikesRew = find(spikesRew==1);
        length(spikesCue);

    		spikesegmentCue = spikesegmentCue+length(spikesCue);
    		spikesegmentRew = spikesegmentRew+length(spikesRew);
    		z = z+1;
    	end
    	cueRates(1,k) = spikesegmentCue./(t*length(cueOn));
    	rewRates(1,k) = spikesegmentRew./(t*length(cueOn));
    	k = k+1;
    end

%spikesIntertrial = intersect(spike.(name), intertrial);

spikesIntertrial = ismember(spike.(name), intertrial);
spikesIntertrial = find(spikesIntertrial==1);

intertrialRate = length(spikesIntertrial)./timeintertrial;
fxmatrix(j,:) = vertcat(cueRates', rewRates', intertrialRate);
j = j +1;
end

thingy = fxmatrix;
end


if double == 1
while k <=segments
	j=1;
	spikesegmentCue = 0;
	spikesegmentRew = 0;
	while j <=length(cueOnindex)

		currentCueTime = time(cueOnindex(j)+(interval*(k-1)):(cueOnindex(j)+(interval*k)));
		currentRewTime = time(foodOnindex(j)+(interval*(k-1)):(foodOnindex(j)+(interval*k)));
    %spikesCue = intersect(currentCueTime, spike.(name));
    %spikesRew = intersect(currentRewTime, spike.(name));

    spikesCue = ismember(spike.(name), currentCueTime);
    spikesCue = find(spikesCue==1);
    spikesRew = ismember(spike.(name), currentRewTime);
    spikesRew = find(spikesRew==1);


		spikesegmentCue = spikesegmentCue+length(spikesCue);
		spikesegmentRew = spikesegmentRew+length(spikesRew);
		j = j+1;
	end
	cueRates(1,k) = spikesegmentCue./(t*length(cueOn));
	rewRates(1,k) = spikesegmentRew./(t*length(cueOn));
	k = k+1;
end
%spikesIntertrial = intersect(spike.(name), intertrial);

spikesIntertrial = ismember(spike.(name), intertrial);
spikesIntertrial = find(spikesIntertrial==1);

intertrialRate = length(spikesIntertrial)./timeintertrial;
thingy = [cueRates'; rewRates'; intertrialRate];
end
%intertrial spike rate is easy to get bc not segmenting it



%spikesPostfood = intersect(spike, postcue);




%then rates in order so all cue, all reward, post reward, intertrial
