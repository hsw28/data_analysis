function data = sdat_get(sdat,clust_ind,feature)

% data = sdat_get(sdat,clust_ind,feature) returns info from data field of
% an sdat clust or an array of sdat clusts

if(clust_ind == 0)
    if(numel(clust_ind) > 1)
        error('clust_ind must be either 0 or an array of positive ints.');
    else
        clust_ind = 1:numel(sdat.clust);
    end
end

if(any(clust_ind < 1))
    error('clust_ind must be 0 or an array of positive ints.');
end

% feature_ind = find(strcmp(feature,sdat.featurenames));
% if(numel(feature_ind) > 1)
%     warning(['Multiple features match name: ', feature,'. Using the first one.']);
%     feature_ind = feature_ind(1);
% end

if(numel(clust_ind) == 1)
    feature_ind = gh_dcbn(sdat.clust{clust_ind},feature);
    data = sdat.clust{clust_ind}.data(:,feature_ind);
else
    data = cell(size(clust_ind));
    for c = 1:numel(clust_ind)
        feature_ind = gh_dcbn(sdat.clust{clust_ind(c)},feature);
        data{c} = sdat.clust{clust_ind(c)}.data(:,feature_ind);
    end
end