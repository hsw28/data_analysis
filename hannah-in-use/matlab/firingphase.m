function f = firingphase(firingtimes, thetapeaktimes, timevector, vel, bins)
% INPUT PEAKTIMES FROM THETAPHASE.m. THERE YOU CAN DETERMINE HIGH THETA, LOW THETA, ETC
%input peak times, cell firing, time vector, vel
%bins is in number of degrees per bin (ex 60 for sixty degrees per bin)

%finds theta peak closest peak to cell firing for LS LFP
% plots histogram
%
% returns [phase, time]

if size(firingtimes,2)>size(firingtimes,1)
    firingtimes = firingtimes';
end


tme = timevector;
peaktimes = thetapeaktimes;
%determines peaks of theta


phase = [];
ftimes = [];


vel = assignvel(timevector, vel);
assvelspikes = assignvelOLD(firingtimes, vel);
indx = find(assvelspikes(1,:)>20);
goodspikes = firingtimes(indx);


i = 1;
phase = [];
spikess = [];
while i<= length(goodspikes)
    [c closestpeakindx] = min(abs(peaktimes-goodspikes(i)));
    %360 . (t -to)/(tl - to), where t is the time of the event to and tl are the times of the preceding and following peaks of the filtered reference EEG signa
        if goodspikes(i)-peaktimes(closestpeakindx) >= 0 & closestpeakindx<length(peaktimes)  %if the closest peak is before the spike, the spike - the peak will be positive
            prepeak = peaktimes(closestpeakindx);
            postpeak = peaktimes(closestpeakindx+1);
        elseif goodspikes(i)-peaktimes(closestpeakindx) < 0 & closestpeakindx>1 %if the after peak is before the spike, the spike - the peak will be positive
            prepeak = peaktimes(closestpeakindx-1);
            postpeak = peaktimes(closestpeakindx);
            %take care of spike = peak at bottom
        else
          prepeak = NaN;
          postpeak = NaN;
        end
        %now find phase
        %peaks should be > .08 apart but less than .17 (or they should be equal to zero)
        if postpeak-prepeak >= .08 && postpeak-prepeak<=.17
            phase(end+1) = 360*(goodspikes(i)-prepeak)/(postpeak-prepeak);
            spikess(end+1) = goodspikes(i);
        end

        %taking care of spike on peak now
        if goodspikes(i)-peaktimes(closestpeakindx) == 0 %spike is on peak
            phase(end+1) = 0;
            spikess(end+1) = goodspikes(i);
        end
      i = i+1;
    end



f = [phase; spikess];
figure;

bincount = 360/bins;
histogram(phase, bincount, 'BinWidth', bins, 'Normalization', 'probability')
xlim([0 360]);

ylabel('Number of Cells')
xlabel('Theta Phase')
