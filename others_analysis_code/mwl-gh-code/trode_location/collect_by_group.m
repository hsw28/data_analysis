function outData = collect_by_group(inData, trode_groups)

outData = inData;
outData.clust = {};


% group sdat
for g = 1:numel(trode_groups)
    
    groupName   = trode_groups{g}.name;
    groupTrodes = trode_groups{g}.trodes;
    
    groupClusts = sdatslice(inData, 'names', groupTrodes);
    outData.clust{g} = groupClusts.clust{1};
    outData.clust{g}.stimes = [];
    for n = 1:numel(groupTrodes)
        outData.clust{g}.stimes = [outData.clust{g}.stimes, groupClusts.clust{n}.stimes];
        outData.clust{g}.data = [outData.clust{g}.data; groupClusts.clust{n}.data];
    end
    [outData.clust{g}.stimes,i] = sort(outData.clust{g}.stimes);
    outData.clust{g}.data = outData.clust{g}.data(i,:);

end