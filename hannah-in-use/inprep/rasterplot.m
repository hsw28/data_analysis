function [] = rasterplot(spikematrix)
% spike matrix should be a matrix where [num of cells, spike times]
% modified heavily from https://praneethnamburi.wordpress.com/2015/02/05/simulating-neural-spike-trains/

if size(spikematrix,1) > size(spikematrix,2)
	spikematrix = spikematrix';
end

hold all;
numoftrains = size(spikematrix,1);
for i = 1:numoftrains
    spikePos = spikematrix(i, :);
    for cellCount = 1:length(spikePos)
        plot([spikePos(cellCount) spikePos(cellCount)], ...
            [i-0.4 i+0.4], 'k');
    end
end

ylim([0 size(spikematrix, 1)+1]);
