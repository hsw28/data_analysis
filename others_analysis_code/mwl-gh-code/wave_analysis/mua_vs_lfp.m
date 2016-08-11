function f = mua_vs_lfp(sdat,lfp,rat_conv_table,varargin)

% f = mau_vs_lfp(mua,lfp,rat_conv_table,[lfp_ref],[bouts]) plots multi-unit rates as a function of lfp phase and trode position.
% f is a figure
% sdat is an sdat
% rat_conv_table is a rat conv table
% lfp_ref is a cell array of channel labels that chooses the lfp to reference clusts against.  Give 1 value or n values, where n is the number of clusts in sdat
% -- leave lfp_ref blank and it will automatically be set to the local channel for each clust
% bouts is a 2xn matrix of times to start and stop accepting spikes
% bout_weights manages how bouts are averaged.  Leave blank to normalize by bout length
% disp_hists determines whether histograms are plotted
% disp_circ_means determines whether circular means are plotted
% min_t_maxwd and max_t_maxwd are sdat filtering parameters (to select on spikes by t_maxwd parm - a rough pyramidal vs. interneuron measure
% n_circ_hist_bin is the number of bins to use in circular (phase) histograms

p = inputParser();
p.addParamValue('lfp_ref',[],@isreal);
p.addParamValue('bouts',{[lfp.tstart;lfp.tend]},@(x) (size(x,1)) == 2);
p.addParamValue('bout_weights',[],@isreal);
p.addParamValue('disp_hists',true,@isreal);
p.addParamValue('disp_circ_means',true,@isreal);
p.addParamValue('min_t_maxwd',0,@isreal);
p.addParamValue('max_t_maxwd',100,@isreal);
p.addParamValue('n_circ_hist_bin',50,@isreal);
p.parse(varargin{:});


% fill out lfp_ref appropriately

lfp_ref = p.Results.lfp_ref;
if(not(iscell(lfp_ref)))
    tmp = lfp_ref;
    lfp_ref = cell(1);
    lfp_ref{1} = tmp;
end
if(numel(lfp_ref) == 1)
   % expand single ref_ind to all clusts
   this_ind = find(strcmp(lfp_ref{1},lfp.chanlabels));
   if(numel(this_ind)==0)
       error(['No lfp chanlabel matched: ', lfp_ref{1}]);
   elseif(numel(this_ind)>1)
       error(['Multiple lfp channels share the chanlabel: ', lfp_ref{1}]);
   else
       lfp_ref_ind = this_ind.*ones(1,numel(sdat.clust));
   end
elseif(numel(lfp_ref) ~= numel(sdat.clust))
    error(['Number of lfp_ref elements (', num2str(numel(lfp_ref)),') must equal 1 or number of clusts in sdat(',num2str(numel(sdat.clust))]);
else
    % different ref_inds for different clusts
    lfp_ref_ind = zeros(1,numel(lfp_ref));
    for n = 1:numel(lfp_ref)
        this_ind = find(strcmp(lfp_ref{n},lfp.chanlabels));
        if(numel(this_ind)<1)
            error(['No lfp chanlabel matched: ', lfp_ref{n}]);
        elseif(numel(this_ind>1))
            error(['Multiple lfp channels share the chanlabel: ', lfp_ref{n}]);
        else
            lfp_ref_ind(n) = this_ind;
        end
    end
end

new_sdat = sdat_filt_on_data(sdat,'t_maxwd','min_val',p.Results.min_t_maxwd,'max_val',p.Results.max_t_maxwd);

nbout = size(bouts,2);
circ_dist = zeros(nbout,p.Results.n_circ_hist_bin);
circ_mean_modulus = zeros(nbout,1);
circ_mean_argument = zeros(nbout,1);
circ_dist_bins = linspace(-pi,pi,p.Results.n_circ_hist_bin)
circ_dist_bin_centers = mod((circ_dist_bins + p.Results.n_circ_dist_bin/2) + pi, 2*pi) - pi;

for n = 1:nbout
    this_bout = bouts(:,n)';
    this_lfp = contwin(lfp,bouts(:,n)');
    ts = conttimestamp(this_lfp);
    new_sdat = sdatslice(new_sdat,'timewin',this_bout);
    [new_sdat, sdat_rates] = assign_rate_by_time(new_sdat,'timebins',ts(and(ts >= min(this_bout), ts <= max(this_bout))));
    disp('Size of sdat_rates:');
    size(sdat_rates)
    disp('Size of lfp:');
    size(this_lfp.data)
    for c = 1:nclust
        this_lfp_chan_ind = lfp_ref_ind(c);
        x_pos = conv_table.data{4,find(strcmp(conv_table.data(1,:),lfp.chanlabels{n}))};
        y_pos = conv_table.data{3,find(strcmp(conv_table.data(1,:),lfp.chanlabels{n}))};
    end
end