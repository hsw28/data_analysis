function f = sdat_vs_lfp(sdat,lfp_r,rat_conv_table,varargin)

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
p.addParamValue('lfp_ref',cell(0),@iscell);
p.addParamValue('bouts',[lfp_r.raw.tstart;lfp_r.raw.tend],@(x) (size(x,1)) == 2);
p.addParamValue('bout_weights',[],@isreal);
p.addParamValue('disp_hists',true,@isreal);
p.addParamValue('disp_circ_means',true,@isreal);
p.addParamValue('min_t_maxwd',0,@isreal);
p.addParamValue('max_t_maxwd',100,@isreal);
p.addParamValue('n_circ_hist_bin',20,@isreal);
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
   this_ind = find(strcmp(lfp_ref{1},lfp_r.raw.chanlabels));
   if(numel(this_ind)==0)
       error(['No lfp chanlabel matched: ', lfp_ref{1}]);
   elseif(numel(this_ind)>1)
       error(['Multiple lfp channels share the chanlabel: ', lfp_ref{1}]);
   else
       lfp_ref_ind = this_ind.*ones(1,numel(sdat.clust));
   end
elseif(and((numel(lfp_ref) ~= numel(sdat.clust)),numel(lfp_ref) > 1))
    error(['Number of lfp_ref elements (', num2str(numel(lfp_ref)),') must equal 1 or number of clusts in sdat(',num2str(numel(sdat.clust)),')']);
else
    % different ref_inds for different clusts, number of 
    lfp_ref_ind = zeros(1,numel(sdat.clust));
    for n = 1:numel(lfp_ref)
        this_ind = find(strcmp(lfp_ref{n},lfp.chanlabels));
        if(numel(this_ind)<1)place_cells_smooth2
            error(['BNo lfp chanlabel matched: ', lfp_ref{n}]);
        elseif(numel(this_ind>1))
            error(['Multiple lfp channels share the chanlabel: ', lfp_ref{n}]);
        else
            lfp_ref_ind(n) = this_ind;
        end
    end
end

lfp_ref
lfp_ref_ind

new_sdat = sdat_filt_on_data(sdat,'t_maxwd','min_val',p.Results.min_t_maxwd,'max_val',p.Results.max_t_maxwd);

bouts = p.Results.bouts;

% process eeg
total_timewin = [min(min(bouts)),max(max(bouts))];
%small_lfp = contwin(lfp,total_timewin+[-10 10]);
%small_lfp = lfp;
%[lfp_theta, lfp_phase, lfp_env] = gh_theta_filt(small_lfp);
%lfp_theta = contwin(lfp_theta,total_timewin);
%lfp_phase = contwin(lfp_phase,total_timewin);
%if(any(isnan(lfp_phase.data)))
%    beep
%    disp('have nans in phase');
%end
%lfp_env = contwin(lfp_env,total_timewin);
%lfp_theta.samplerate
%figure;
%gh_plot_cont(lfp_theta);
%figure;gh_plot_cont(lfp_phase);
%figure;gh_plot_cont(lfp_env);
lfp_r = contwin_r(lfp_r,total_timewin);
lfp_theta = lfp_r.theta;
lfp_phase = lfp_r.phase;
lfp_env = lfp_r.env;

nbout = size(bouts,2);
circ_dist = zeros(nbout,p.Results.n_circ_hist_bin);
circ_mean_modulus = zeros(nbout,1);
circ_mean_argument = zeros(nbout,1);
circ_dist_bins = linspace(-pi,pi,p.Results.n_circ_hist_bin);
circ_dist_bin_centers = mod((circ_dist_bins + p.Results.n_circ_hist_bin/2) + pi, 2*pi) - pi;

nclust = numel(sdat.clust);
for n = 1:nbout
    this_bout = bouts(:,n)';
    this_phase = contwin(lfp_phase,bouts(:,n)');
    ts = conttimestamp(this_phase);
    %new_sdat = sdatslice(new_sdat,'timewin',this_bout);
    [sdat, sdat_rates] = assign_rate_by_time(new_sdat,'timebins',ts(and(ts >= min(this_bout), ts <= max(this_bout))));
    sdat = sdatslice(sdat,'timewin',this_bout);
    %[sdat, sdat_rates] = assign_rate_by_time(sdat,'timebins',ts(and(ts >= min(this_bout), ts <= max(this_bout))));
    %figure; plot(diff(ts(and(ts>= min(this_bout), ts <= max(this_bout)))),'.'); title('ts');
    
%    figure;
%    gh_plot_cont(sdat_rates);
    disp('Size of sdat_rates:');
    size(sdat_rates)
    disp('Size of lfp:');
    size(this_phase.data)
    f = figure();
    set(f,'NextPlot','add');
    g = figure();
    %hold(f,'on');
%    figure(11);
    for c = 1:nclust
        figure(f);
        this_lfp_chan_ind = lfp_ref_ind(c);
        x_pos = rat_conv_table.data{6,find(strcmp(rat_conv_table.data(1,:),sdat.clust{c}.comp))};
        y_pos = rat_conv_table.data{5,find(strcmp(rat_conv_table.data(1,:),sdat.clust{c}.comp))};
        %figure;
        %subplot(2,1,1); plot(lfp_phase.data(:,this_lfp_chan_ind)); title('From sdat_vs_lfp');
        %subplot(2,1,2); plot(sdat_rates.data(:,c));
        [counts] = gh_whistc(lfp_phase.data(:,this_lfp_chan_ind),sdat_rates.data(:,c),circ_dist_bins,'means',true,'means_count_zeros',true);
        counts = counts(1:end-1);
        gh_add_polar(circ_dist_bins(1:end-1)',(counts./max(counts)).^1,'max_r',0.25,'pos',[x_pos,y_pos],'plot_circ_mean',true);
        set(gca,'NextPlot','add');
        %hold on;
        plot(x_pos,y_pos,'O');
        
        figure(g);
        subplot(nclust/2+1,2,c);
        bar(circ_dist_bins(1:end-1), counts);
        %counts
    end
    
    %new_sdat = sdatslice(new_sdat,'timewin',this_bout);
    %new_sdat = assign_theta_phase(new_sdat,'eeg_theta_phase',this_phase,'power_threshold',0.02,'bout_chan',this_lfp_chan_ind);
    %new_sdat.data
    
end