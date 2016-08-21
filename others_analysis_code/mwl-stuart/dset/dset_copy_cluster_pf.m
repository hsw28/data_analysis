function clOut = dset_copy_cluster_PF(clIn, clOut)
%DSET_COPY_CLUSTER_PF - copys the placefields from one cluster struct to
%another, the clustId and tetrode fields are compared and if they are equal
%then the pf data is copied, clusters without matches are removed


inTetrode = {clIn.tetrode};
inCluster = {clIn.clustId};

outTetrode = {clOut.tetrode};
outCluster = {clOut.clustId};


emptyIdx = false(size(clOut));
for i = 1:numel(clOut)
    fn1 = @(x) eq(x, outTetrode{i});
    fn2 = @(x) eq(x, outCluster{i});
    % compare the tetrode and clustID values
    idx = find(cellfun(fn1, inTetrode) & cellfun(fn2, inCluster));
    
    %record index of empty comparisons
    if isempty(idx)
        emptyIdx(i) = true;
        continue;
    end
    
    %copy the placefield (pf) and placefield edges
    clOut(i).pf = clIn(idx).pf;
    clOut(i).pf_edges = clIn(idx).pf_edges;
end

%remove clusters without a match
clOut = clOut(~emptyIdx);