function stats = computePCAClusterStats(baseDir, ttList, nChan)
%%
[clId, data] = load_pca_clusters_for_day(baseDir,nChan);

nTT = numel(data);

if nargin==1 || isempty(ttList)
    ttList = 1:nTT;
end

stats = repmat(struct( 'nSpike', [],'lRatio', []), 1, nTT);

warning off; %#ok suppress mahal warning about precision

for iTT = ttList
    
    clustId = clId{iTT};
    
    if isempty(clId{iTT})
        continue;
    end
    
    amp = data{iTT}( :, 1:4 );
    
    nClust = max(clustId);
   
    lr = nan(nClust,1);
    ns = nan(nClust,1);
    
    for iCl = 1:nClust
        
        clIdx = clustId == iCl;
        
        ns(iCl) = nnz(clIdx);
        
        if ns(iCl)<4
            continue;
        end
        [ lr(iCl) ] = lRatio(amp, clustId == iCl);
        
    end
    stats(iTT).nSpike = ns;
    stats(iTT).lRatio = lr;
    
end
warning on; %#ok


stats = stats(ttList);

%%
end