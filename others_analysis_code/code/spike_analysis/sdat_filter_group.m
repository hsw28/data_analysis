function s = sdat_filter_group(sdat,trode_groups,groupName)
a = 1;
cNames      = cmap(@(x) x.comp, sdat.clust);
cGroups     = cmap(@(x) trode_group(x,trode_groups), cNames);
cGroupNames = cmap(@(x) x.name, cGroups);
keep = strcmp(groupName,cGroupNames);

s = sdat;
s.clust = s.clust(keep);
s.nclust = numel(s.clust);
