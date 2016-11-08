function [] = plotRaster(spikeMat, tVec)
% spikeMat is spikes and tVec is time vector
% xlabel('Time (ms)');
% ylabel('Trial Number')
%
% started from https://praneethnamburi.wordpress.com/2015/02/05/simulating-neural-spike-trains/

hold all;
for trialCount = 1:size(spikeMat,1)
    spikePos = tVec(spikeMat(trialCount, :));
    for spikeCount = 1:length(spikePos)
        plot([spikePos(spikeCount) spikePos(spikeCount)], ...
            [trialCount-0.4 trialCount+0.4], 'k');
    end
end
ylim([0 size(spikeMat, 1)+1]);
