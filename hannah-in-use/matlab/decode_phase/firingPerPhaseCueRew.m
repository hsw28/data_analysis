function thingy = firingPerPhaseCueRew(time, cueOn, spike, t)
%finds firing per phase, cue and reward times only
% timestamps, cuetimes, cluster data, and window size (in seconds). must fit evenly into 8
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


%t is the number of seconds you want to divide cue and reward INTO
%find how many segments that is in 8 seconds
%then permute through all cue and reward times, adding seconds as you go
interval = 2000*t;
segments = 8/t;
cueRates = zeros(1, segments);
rewRates = zeros(1, segments);
k = 1;


while k <=segments
	j=1;
	spikesegmentCue = 0;
	spikesegmentRew = 0;
	while j <=length(cueOnindex)

    
		currentCueTime = time(cueOnindex(j)+(interval*(k-1)):(cueOnindex(j)+(interval*k)));
		currentRewTime = time(foodOnindex(j)+(interval*(k-1)):(foodOnindex(j)+(interval*k)));
		spikesCue = intersect(currentCueTime, spike);
		spikesRew = intersect(currentRewTime, spike);
		spikesegmentCue = spikesegmentCue+length(spikesCue);
		spikesegmentRew = spikesegmentRew+length(spikesRew);
		j = j+1;
	end
	cueRates(1,k) = spikesegmentCue./(t*length(cueOn));
	rewRates(1,k) = spikesegmentRew./(t*length(cueOn));
	k = k+1;
end




%then rates in order so all cue, all reward, post reward, intertrial

thingy = [cueRates'; rewRates'];
