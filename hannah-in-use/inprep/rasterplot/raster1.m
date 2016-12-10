function [] = plotRaster(spikematrix)
% spike matrix should be a matrix where [num of cells, spike times]
% started from https://praneethnamburi.wordpress.com/2015/02/05/simulating-neural-spike-trains/

hold all;
for cellCount = 1:numoftrains
    spikePos = tm(numoftrains(cellCount, :));
    for cellCount = 1:length(spikePos)
        plot([spikePos(cellCount) spikePos(cellCount)], ...
            [trialCount-0.4 trialCount+0.4], 'k');
    end
end

ylim([0 size(spikematrix, 1)+1]);
