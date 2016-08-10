function new_sdat = gh_fix_compname(sdat)

for i = 1:numel(sdat.clust)
    this_name = sdat.clust{i}.comp;
    if(strcmp(this_name(1),'g'))
        this_name(1) = 'e';
    end
    sdat.clust{i}.comp = this_name;
end

new_sdat = sdat;