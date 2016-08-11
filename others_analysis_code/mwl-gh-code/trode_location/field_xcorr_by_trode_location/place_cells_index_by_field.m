function fieldClusts = place_cells_index_by_field(place_cells,fieldSources)

pcNames = cmap(@(x) x.name, place_cells.clust);
inds = zeros(1,numel(fieldSources));
for n = 1:numel(inds)
        inds(n) = find(strcmp(fieldSources{n},pcNames),1,'first');
end
place_cells.clust = place_cells.clust(inds);
fieldClusts = place_cells.clust;