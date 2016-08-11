function dists_mat = get_anatomical_region_dists(fieldClusts, field_cells, trode_groups, varargin)


group_names = cmap(@(x) x.name, trode_groups);
dists_mat = zeros(numel(group_names),numel(group_names));
for r = 1:numel(fieldClusts)
    for c = 1:numel(fieldClusts)
        if r == c
            dists_mat(r,c) = NaN;
        else
            dists_mat(r,c) = lfun_area_pair_code(fieldClusts{r}, ...
                                                              fieldClusts{c},...
                                                              trode_groups);
        end
    end
end
end

function r = lfun_area_pair_code(cellA, cellB, trode_groups)
indA = group_of_trode(trode_groups, cellA.comp,'return_val','ind');
indB = group_of_trode(trode_groups, cellB.comp,'return_val','ind');
if (numel(indA) == 1 && numel(indB) == 1)
    r = indB - indA;
else
    error('lfun_area_pair_code:too_many_matches',...
        'Cell matched O or mulitple trode group areas');
end
end