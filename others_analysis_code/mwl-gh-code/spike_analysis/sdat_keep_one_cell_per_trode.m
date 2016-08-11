function new_sdat = sdat_keep_one_cell_per_trode(sdat)

new_sdat = sdat;
new_sdat.clust = {};

for n = 1:numel(sdat.clust)
    
    if( ~any( strcmp( sdat.clust{n}.comp, lfun_list_names(new_sdat) )) )        
        new_sdat.clust{end+1} = sdat.clust{n};
    end
    
end

new_names = lfun_list_names(new_sdat);
if( numel(new_names) ~= numel(unique(new_names)) )
    error('lfun_list_sdat:nonunique_results',...
        'Impossible case - nonunique results.');
end

new_sdat.nclust = numel(new_sdat.clust);

end



function names = lfun_list_names(sdat)

names = cellfun(@(x) x.comp, sdat.clust, 'UniformOutput', false);

end