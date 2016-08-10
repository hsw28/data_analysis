function [new_sdat nc_index] = assign_is_noise_cluster(sdat,varargin)

% This function looks at cluster scores and assigns is_noise_clust field in
% sdat based on matches to score (which should be scalar in {1,2,3,4,5}

% An alternative I want to implement at some point is a cell-by-cell gui
% for each cell, projections are plotted and user says noise or not-noise
% Same principle should work for interneurons

p = inputParser;
p.addParamValue('noise_cluster_score',[],@isreal);
p.addParamValue('user_guided',false,@islogical);
p.parse(varargin{:});
opt = p.Results

nclust = numel(sdat.clust);
nspike_warning = 5000;

nc_index = [];

if(not(xor(not(isempty(opt.noise_cluster_score)),opt.user_guided)))
    error('Must provide either user_guided true or noise_cluster_score.');
end

if(not(isempty(opt.noise_cluster_score)))
for i = 1:nclust
    sdat.clust{i}.is_noise_clust = 0;
    if (ischar(sdat.clust{i}.cl2mat_info.source.Cluster))
        if(and(...
            not(isempty(strfind(sdat.clust{i}.cl2mat_info.source.Cluster,num2str(opt.noise_cluster_score)))),...
            numel(sdat.clust{i}.cl2mat_info.source.Cluster)==10))
            
            sdat.clust{i}.is_noise_clust = 1;
            disp(['Cluster ', sdat.clust{i}.name, ' is a noise cluster.']);
            nc_index = [nc_index,i];
        end
    end
    if (not(sdat.clust{i}.is_noise_clust == 1))
        if(numel(sdat.clust{i}.stimes)>nspike_warning)
            disp(['Cluster ', sdat.clust{i}.name,' exceeded ', num2str(nspike_warning),...
                ' spikes, but was not called noise cluster.']);
            sdat.clust{i}.is_noise_clust = 0;
        end
    end
end
end

new_sdat = sdat;