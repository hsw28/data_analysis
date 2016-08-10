function clust1 = newemptyclust()
% this function is a template for clust structures

clust1.name = []; % semi-descriptive, unique name, should involve trode
clust1.from_tt_file = []; % orig tt file
clust1.from_parm_file = []; % orig pxyabw file
clust1.nspike = [];
clust1.comp = []; % computer source of clust (eg a1, a2, ..., i2)
clust1.trode = []; % trode name cluster came from
clust1.aploc = []; % ap position of that trode
clust1.mlloc = []; % ml position of that trode
clust1.stimes = []; % spike time vector
clust1.csi = []; % csi calculation .csi.info  , .csi.x, .csi.f (xs,values)
clust1.field = []; % .field.info, [.field.x .field.y] or [.field.segs] .field.rates
clust1.theta_phase_dist = []; % .theta_phase_dist.info .theta_phase_dist.th .theta_phase_dist.rate
clust1.theta_modulation = []; % modulation score
clust1.gamma_phase_dist = []; % same as above
clust1.waveforms = []; % nsamp by 4 by nspike array
clust1.replay_membership = []; % vector of numbered replays involving this clust
clust1.spatial_info = []; % spatial information score .spatial_info.units .spatial_info.value
clust1.featurenames = []; % cell array of feature names
clust1.data = []; % nspike x nparam param array for cluster
clust1.is_noise_clust = []; % is this cluster a noise cluster?
clust1.mean_rate = []; % mean firing rate of cluster
clust1.peak_rate = []; % peak firing rate .peak_rate.info .peak_rate.value
clust1.rate_by_time = []; % firing rate as function of time. cd_cont cdat format
clust1.is_interneuron = []; % is it an interneuron?
clust1.is_pyramidal_cell = []; % pyramidal cell?
clust1.co_spikers = []; % cell_array of names of co-spiking clusters
clust1.autocorr = []; % .autocorr.dt .autocorr.rate
clust1.epochs = []; % cell array of epoch names in which this cluster has spikes
clust1.last_update = []; % time of last parameter update (b/c these values might get outdated)
clust1.cluster_score = []; % cluster score from xclust3
clust1.history_log = []; % cell array of change descriptors
clust1.cl2mat_info = []; % struct for mwl2mat info
clust1.userdata = []; % in case I missed anything :)
return