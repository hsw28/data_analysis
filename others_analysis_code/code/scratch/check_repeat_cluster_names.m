function check_repeat_cluster_names(sdat)

n_clust = length(sdat.clust);
name_list = cell(1,n_clust);
for n = 1:n_clust
    name_list{n} = sdat.clust{n}.name;
end

for n = 1:n_clust
    tmp_list = name_list;
    tmp_list{n} = []; % this doesn't fully delete tmp_list{n}.  It literally assigns to tmp_list{n} the empty set
    repeat_ind = find(strcmp(sdat.clust{n}.name,tmp_list));
    if(~isempty(repeat_ind))
        disp(['Match between index: ', num2str(n),'  and index:', num2str(repeat_ind)]);
        disp(['Name 1: ',sdat.clust{n}.name,'   Name 2: ', tmp_list{repeat_ind(1)}]);
    end
end
    