function f = rasterplot(spikematrix, start_time, end_time, num)
% num =1 if putting in a structure, num = 2 if putting in a spike matrix. matrix should be a matrix where [num of cells, spike times]


if num ==1
	clustname = (fieldnames(spikematrix))
	numclust = length(clustname)
	f = figure;
	hold all;
	numoftrains = numclust;
	for k = 1:numclust
		    name = char(clustname(k));
				spikePos = spikematrix.(name);
				ind = find(spikePos > start_time & spikePos <= end_time);
				spikePos = spikePos(ind);
				for cellCount = 1:length(spikePos)
						line([spikePos(cellCount), spikePos(cellCount)], [k-0.4 k+0.4], 'color', [0 0 0]);
				end
  end
ylim([0 numclust+1]);
end




%%%%%%%%%%%%%
if num ==2
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

    end
end

ylim([0 size(spikematrix, 1)+1]);
end
