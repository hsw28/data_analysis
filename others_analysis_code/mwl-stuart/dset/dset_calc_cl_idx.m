function [lIdx, rIdx, bIdx] = dset_calc_cl_idx(dset)
    
    lIdx = strcmp({dset.clusters.hemisphere}, 'left');
    rIdx = strcmp({dset.clusters.hemisphere}, 'right');

    if sum(lIdx) > sum(rIdx)
        clIdx{1} = lIdx;
        clidx{2} = rIdx;
    else
        clIdx{1} = rIdx;
        clIdx{2} = lIdx;
    end

    bIdx = lIdx | rIdx;


end