function spikes = makeSpikes(timeStepS, spikesPerS, durationS, numTrains)
%makes poisson units

if (nargin < 4)
    numTrains = 1;
end
times = [0:timeStepS:durationS];
spikes = zeros(numTrains, length(times));
for train = 1:numTrains
    vt = rand(size(times));
    spikes(train, :) = (spikesPerS*timeStepS) > vt;
end
