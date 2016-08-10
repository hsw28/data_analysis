function c = contchans_trode_group(cdat,trode_groups,groupName)

cGroups     = cmap(@(x) trode_group(x,trode_groups), cdat.chanlabels);
cGroupNames = cmap(@(x) x.name, cGroups);
keepInds    = find(strcmp(groupName,cGroupNames));

c = contchans(cdat,'chans',keepInds);