function new_sdat = sdat_filt_on_data(old_sdat,featurename,varargin)

% new_sdat = sdat_filt_on_data(old_sdat,featurename,varargin)
% removes all spikes that don't meet specified filter criteria
% old_sdat is the old sdat
% featurename is the name of the feature to filter on
% min_val is the min acceptable value
% max_val is the max acceptable value
% units is the min/max measure unit
% -- data for filtering on same units as data field in clust
% -- stdev for filtering on stdevs from clust mean
% keep_empty_clusts retains clusts even if all spikes have been removed
% plot_data subplots the before/after effect

p = inputParser();
p.addParamValue('min_val',[],@isreal);
p.addParamValue('max_val',[],@isreal);
p.addParamValue('units','data',@(x) any(strcmp(x,{'data','stdev'})));
p.addParamValue('keep_empty_clusts',true,@islogical);
p.addParamValue('plot_data',false,@islogical);
p.parse(varargin{:});

new_sdat = old_sdat;

nclust = numel(new_sdat.clust);
keep_clust = zeros(1,nclust);
if(p.Results.plot_data)
    figure;
end
for n = 1:nclust
    data_ind = gh_dcbn(new_sdat.clust{n},featurename);
    if(strcmp(p.Results.units,'data'))
        data_min = p.Results.min_val;
        data_max = p.Results.max_val;
    else
        data_min = mean(new_sdat.clust{n}.data(:,data_ind)) - p.Results.min_val .* std(new_sdat.clust{n}.data(:,data_ind));
        data_max = mean(new_sdat.clust{n}.data(:,data_ind)) + p.Results.max_val .* std(new_sdat.clust{n}.data(:,data_ind));
    end
    keep_ind = and(new_sdat.clust{n}.data(:,data_ind) >= data_min, new_sdat.clust{n}.data(:,data_ind) <= data_max);
    new_sdat.clust{n}.stimes = new_sdat.clust{n}.stimes(keep_ind);
    new_sdat.clust{n}.nspike = numel(new_sdat.clust{n}.stimes);
    new_sdat.clust{n}.data = new_sdat.clust{n}.data(keep_ind,:);
    keep_clust(n) = new_sdat.clust{n}.nspike > 0;
    if(p.Results.plot_data)
        bins = linspace(min(old_sdat.clust{n}.data(:,data_ind)),max(old_sdat.clust{n}.data(:,data_ind)),50);
        counts_old = histc(old_sdat.clust{n}.data(:,data_ind),bins);
        counts_new = histc(new_sdat.clust{n}.data(:,data_ind),bins);
        subplot(nclust,2,(n-1)*2+1); bar(bins,counts_old); ylim([0 100000]);
        subplot(nclust,2,(n-1)*2+2); bar(bins,counts_new); ylim([0 100000]);
    end
end

%new_sdat = sdatslice(new_sdat,'index',keep_clust);