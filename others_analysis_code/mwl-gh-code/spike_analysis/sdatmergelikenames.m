function new_sdat = sdatmergelikenames(old_sdat)

i = 1;
end_i = numel(old_sdat.clust);
while(i < end_i)
    same_index = i;
    for j = [1:numel(old_sdat.clust)]
        if(strcmp(old_sdat.clust{i}.name,old_sdat.clust{j}.name))
            same_index = [same_index,j];
        end
    end
    same_index = unique(same_index);
    if( numel(same_index) > 1)
        old_sdat = sdatflatten(old_sdat,'index',same_index,'inplace',true);
    end
    i = i + 1;
    end_i = numel(old_sdat.clust);
end
new_sdat = old_sdat;
return