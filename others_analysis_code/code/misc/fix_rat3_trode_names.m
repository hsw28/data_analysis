function sdat = fix_rat3_trode_names(sdat)

nclust = numel(sdat.clust)

swap_from = {'T01','T02','T03','T04','T05','T06','T07','T08','T09','T10','T11','T12','T13','T14','T15','T16','T17','T18'};
swap_to = {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18'};

for m = 1:nclust
    from_log = strcmp(sdat.clust{m}.trode,swap_from);
    if(~isempty(from_log))
        sdat.clust{m}.comp = swap_to{find(from_log)};
        sdat.clust{m}.trode = swap_to{find(from_log)};
    end
end
    