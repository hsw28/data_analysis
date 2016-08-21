function [stats] = computeClusterStats(clId, features)
%%
nTT = numel(clId);
stats = repmat(struct( 'nSpike', [],'lRatio', []), 1, nTT);

warning off; %#ok suppress mahal warning about precision
for iTT = 1:nTT
   
    if isempty(clId{iTT}) || isempty(features{iTT})
        stats(iTT).lRatio = nan;
        stats(iTT).nSpike = nan;
        continue;
    end
    
    clustId = clId{iTT};
    
    feat = features{iTT};
    
    nClust = max(clustId);
   
    lr = nan(nClust,1);
    ns = nan(nClust,1);
    
    for iCl = 1:nClust
        
        clIdx = clustId == iCl;
        
        ns(iCl) = nnz(clIdx);
       
        if  ns(iCl) > size(feat,2)
            lr(iCl)  = calc_l_ratio(feat, clustId == iCl);
        else
            lr(iCl) = nan;
        end
        
    end
    
    stats(iTT).nSpike = ns;
    stats(iTT).lRatio = lr;
    
end
warning on; %#ok
%%
end