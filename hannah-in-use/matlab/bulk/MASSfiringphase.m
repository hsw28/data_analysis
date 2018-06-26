function f = firingphase(spikestructure, thetapeaktimes, timevector, vel, bins)
%ONLY DOES FOR ONE DATE AT A TIME BUT MULTIPLE CLUSTERS
% INPUT PEAKTIMES FROM THETAPHASE.m. THERE YOU CAN DETERMINE HIGH THETA, LOW THETA, ETC
%input peak times, cell firing, time vector, vel
%bins is in number of degrees per bin (ex 60 for sixty degrees per bin)

%finds theta peak closest peak to cell firing for LS LFP
% plots histogram
%
% returns [phase, time]



tme = timevector;
peaktimes = thetapeaktimes;
%determines peaks of theta
%peaktimes = thetaphase(lfp, tme, above);
%troughtimes = thetaphase(lfp.*-1, tme, above);

phase = [];
ftimes = [];
test = 0;


vel = assignvel(timevector, vel);

indx = find(vel(1,:)>6);
goodtimes = timevector(indx);
goodtimes = goodtimes';

spikenames = (fieldnames(spikestructure));
spikenum = length(spikenames);

for k = 1:spikenum
name = char(spikenames(k))
firingtimes = spikestructure.(name);
i = 1;
phase = [];
spikess = [];
while i<= length(firingtimes)
  z = find(abs(firingtimes(i)-goodtimes)<.005);
  if length(z)<1 % velocity is too low so go to next firing
    i = i+1;
  elseif length(z)>=1 % velocity is good
    [c closestpeakindx] = min(abs(peaktimes-firingtimes(i)));
    %360 . (t -to)/(tl - to), where t is the time of the event to and tl are the times of the preceding and following peaks of the filtered reference EEG signa
        if firingtimes(i)-peaktimes(closestpeakindx) > 0 & closestpeakindx<length(peaktimes)  %if the closest peak is before the spike, the spike - the peak will be positive
            prepeak = peaktimes(closestpeakindx);
            postpeak = peaktimes(closestpeakindx+1);
        elseif firingtimes(i)-peaktimes(closestpeakindx) <= 0 & closestpeakindx>1 %if the after peak is before the spike, the spike - the peak will be positive
            prepeak = peaktimes(closestpeakindx-1);
            postpeak = peaktimes(closestpeakindx);
            %take care of spike = peak at bottom
        else
           prepeak = peaktimes(closestpeakindx);
           postpeak = peaktimes(closestpeakindx+1);
        end

        %now find phase
        %peaks should be > .08 apart but less than .17 (or they should be equal to zero)
        if postpeak-prepeak >= .08 && postpeak-prepeak<=.17
            phase(end+1) = 360*(firingtimes(i)-prepeak)/(postpeak-prepeak);
            spikess(end+1) = firingtimes(i);
        end

        %taking care of spike on peak now
        if firingtimes(i)-peaktimes(closestpeakindx) == 0 %spike is on peak
            phase(end+1) = 0;
            spikess(end+1) = firingtimes(i);
        end
      i = i+1;
    end

end
f = [phase; spikess];
figure;
bincount = 360/bins;
histogram(phase, bincount, 'BinWidth', bins)
xlim([0 360]);
title('char(spikenames(k))')
end





ylabel('Number of Cells')
xlabel('Theta Phase')
