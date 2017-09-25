function f = rasterplot(spikematrix)
% spike matrix should be a matrix where [num of cells, spike times]


if size(spikematrix,1) > size(spikematrix,2)
	spikematrix = spikematrix';
end

f = figure;
hold all;
numoftrains = size(spikematrix,1);
for i = 1:numoftrains
    spikePos = spikematrix(i, :);
    for cellCount = 1:length(spikePos)
		line([spikePos(cellCount), spikePos(cellCount)], [i-0.4 i+0.4], 'color', [0 0 0]);
%        plot([spikePos(cellCount) spikePos(cellCount)], ...
%            [i-0.4 i+0.4], 'k');
    end
end

ylim([0 size(spikematrix, 1)+1]);
