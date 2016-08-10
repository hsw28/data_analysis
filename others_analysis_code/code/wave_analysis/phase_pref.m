function [pref_list] = phase_pref(units,eeg_r,rat_conv_table,varargin)
% PHASE_PREF takes sdat, eeg_r, and rat conv table
% returns phase_list - a cell array of trode_phase_pref structs
% each trode_phase_pref struct contains summary stats:
%  --trial-long clumped mean phase for all cells on that tetrode (theta)
%  --trial-long clumped phase variance for all cells (kappa)
%  -trial-long mean within-cell mean phases (theta)
%  -trial-long mean within-cell phase variances (kappa)
%  --timebinned clumped mean phase (theta by time)
%  --timebinned clumped phase variance (kappa by time)
%  -timebinned mean within-cell mean phases (theta by time)
%  -timebinned mean within-cell phase variance (kappa by time)
%  -trial long clumped phase histogram
%  -trial long within-cell mean phase pref histogram (one count per cell)
%  --one unit_phase_pref struct for each unit on that trode, containing
%     --trial-long phase pref (theta)
%     --trial-long phase variance (kappa)
%     --timebinned phase pref (theta by time)
%     --timebinned phase variance (kappa by time)
%
%  THETA and KAPPA are the circular mean and circular concentration parameters
%  of the von mises distribution.  Reporting these statistics may be more
%  effcient than reporting timecourses for each bin in circular histograms?

p = inputParser();
p.addParamValue('cdat_chan',[]);
p.addParamValue('timewin',[eeg_r.raw.tstart,eeg_r.raw.tend]);
p.addParamValue('fav_eeg',1);
p.addParamValue('do_timecourses',true,@islogical); % won't implement this until I'm convinced the structs are really too big
p.addParamValue('timebin_edges', eeg_r.raw.tstart:0.25:eeg_r.raw.tend );
p.addParamValue('w',[]); % w circular bin count for circ_vmpar calls
p.addParamValue('d',[]); % d bin centers for circ_vmpar calls
p.addParamValue('power_threshold',0.1); % power threshold for call to assign_theta_phase
p.addParamValue('verbose',false);
p.parse(varargin{:});
opt = p.Results;

if(sum(strcmp(units.clust{1}.featurenames,'phase_for_phase_pref')) < 1)
    disp('Assigning theta phase');
    units = assign_theta_phase(units,eeg_r,'power_threshold',opt.power_threshold,...
        'featurename','phase_for_phase_pref','cdat_chan',opt.cdat_chan);
end

pref_list = [];
pref_list.n_trode_phase_pref = 0;
pref_list.ts_edges = opt.timebin_edges;
pref_list.ts = opt.timebin_edges(2:end)+opt.timebin_edges(1:end-1) ./2; % 
opt.ts = pref_list.ts;

%%% First go through the sdat list making skeleton trode_phase_pref structs
%%% and populating them with unit_phase_pref structs

nclust = numel(units.clust);
for k = 1:nclust
    trode_name = units.clust{k}.trode;
    [trode_phase_pref,ind] = lfun_get_trode(trode_name,pref_list,rat_conv_table);
    if(opt.verbose)
        disp(['trode name: ', trode_name,'   got ind: ', num2str(ind)]);
    end
    trode_phase_pref.n_unit = trode_phase_pref.n_unit + 1;
    trode_phase_pref.unit_phase_pref(trode_phase_pref.n_unit) = lfun_add_unit(units.clust{k},opt);
    pref_list.trode_phase_pref(ind) = trode_phase_pref;
    pref_list.n_trode_phase_pref = numel(pref_list.trode_phase_pref);
end

%%% Next we'll go through the trode list and compute the trode-wide stats
for k = 1:pref_list.n_trode_phase_pref
    n_unit = pref_list.trode_phase_pref(k).n_unit;
    all_stimes = [];
    all_phases = [];
    for j = 1:n_unit
        all_stimes = [all_stimes, pref_list.trode_phase_pref(k).unit_phase_pref(j).stimes];
        all_phases = [all_phases, pref_list.trode_phase_pref(k).unit_phase_pref(j).phases];
    end
    [pref_list.trode_phase_pref(k).clumped_mean_phase, pref_list.trode_phase_pref(k).clumped_phase_kappa] = ...
        lfun_circ_vmpar(all_phases,opt);
    pref_list.trode_phase_pref(k).clumped_circ_var = circ_var(all_phases);
    
    pref_list.trode_phase_pref(k).clumped_mean_by_t = zeros(1,numel(opt.ts));
    pref_list.trode_phase_pref(k).clumped_kappa_by_t = zeros(1,numel(opt.ts));
    for h = 1:numel(opt.ts)
        this_phases = all_phases(and(all_stimes >= opt.timebin_edges(h), all_stimes < opt.timebin_edges(h+1)));
        [pref_list.trode_phase_pref(k).clumped_mean_by_t(h), pref_list.trode_phase_pref(k).clumped_kappa_by_t(h)] =...
            lfun_circ_vmpar(this_phases,opt);
    end
end

function [trode_phase_pref, ind] = lfun_get_trode(trode_name,pref_list,rat_conv_table)
% if trode_name matches any trode_name from pref list, return that
% trode_phase_pref struct.  Otherwise, make a skeletal one and return it.
% also return the ind of the trode_phase_pref, or n_trode_phase_pref + 1 if
% new
trode_phase_pref = [];
ind = [];
for k = 1:pref_list.n_trode_phase_pref
    if(strcmp(pref_list.trode_phase_pref(k).trode_name,trode_name))
        ind = k;
        trode_phase_pref = pref_list.trode_phase_pref(k);
    end
end
if(isempty(trode_phase_pref))
    % set up skeletal trode_phase_pref
    trode_phase_pref.trode_name = trode_name;
    trode_phase_pref.n_unit = 0;
    ap_ind = find(strcmp('brain_ap',rat_conv_table.label));
    ml_ind = find(strcmp('brain_ml',rat_conv_table.label));
    name_ind = find(strcmp('comp',rat_conv_table.label));
    rat_conv_table.data(name_ind,:);
    trode_ind = find(strcmp(rat_conv_table.data(name_ind,:),trode_name));
    trode_phase_pref.brain_ap = rat_conv_table.data{ap_ind,trode_ind};
    trode_phase_pref.brain_ml = rat_conv_table.data{ml_ind,trode_ind};
    % specify the new location to add the returned trode_phase_pref
    ind = pref_list.n_trode_phase_pref + 1;
end


function unit_phase_pref = lfun_add_unit(clust,opt)
unit_phase_pref.unit_name = clust.name;
stime_index = strcmp(clust.featurenames,'time');
phase_index = strcmp(clust.featurenames,'phase_for_phase_pref');
if(isempty(stime_index))
    error('could not find spike times in sdat');
end
stimes = clust.data(:,stime_index);
phases = clust.data(:,phase_index);
good_ind = ~isnan(phases);
unit_phase_pref.stimes = stimes(good_ind)';
unit_phase_pref.phases = phases(good_ind)';

if(~isempty(unit_phase_pref.phases))
    [unit_phase_pref.trial_long_phase_pref, unit_phase_pref.trial_long_phase_kappa] = lfun_circ_vmpar(unit_phase_pref.phases,opt);
    unit_phase_pref.trial_long_circ_var = circ_var(unit_phase_pref.phases);
else
    warning('found an empty phase vector');
    unit_phase_pref.trial_long_phase_pref = 0;
    unit_phase_pref.trial_long_phase_variance = 0;
    unit_phase_pref.trial_long_circ_var = 0;
end

ts = opt.ts;
unit_phase_pref.phase_pref_by_t = zeros(1,numel(ts));
unit_phase_pref.phase_kappa_by_t = zeros(1,numel(ts));
for k = 1:numel(ts)
    this_phases = phases(and(stimes >= opt.timebin_edges(k), stimes < opt.timebin_edges(k+1)));
    [unit_phase_pref.phase_pref_by_t(k),unit_phase_pref.phase_kappa_by_t(k)] =...
        lfun_circ_vmpar(this_phases,opt);
end


function [theta,kappa] = lfun_circ_vmpar(phases,opt)
if(~isempty(phases))
    if(~isempty(opt.w))
        [theta,kappa] = circ_vmpar(phases,opt.w);
    elseif(~isempty(opt.d))
        [theta,kappa] = circ_vmpar(phases,opt.d);
    else
        [theta,kappa] = circ_vmpar(phases);
    end
else
    theta = 0;
    kappa = 0;
end