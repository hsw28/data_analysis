function [beta_data regress_info] = gh_long_mua_regress(mua,rat_conv_table,varargin)

p = inputParser();

p.addParamValue('lfp_beta_data',[]);
p.addParamValue('lfp_regress_info',[]);

p.addParamValue('long_timewin',[]);
p.addParamValue('short_timewin',0.25);
p.addParamValue('fraction_overlap',0);

p.parse(varargin{:});

nclust = numel(mua.clust);

if(isempty(p.Results.long_timewin))
long_tw = [];
for n = 1:nclust
    long_tw = [min([min(long_tw),mua.clust{n}.stimes]), max([max(long_tw),mua.clust{n}.stimes])];
end
else
    long_tw = p.Results.long_tw;
end

short_tw = p.Results.short_timewin;
fo = p.Results.fraction_overlap;

% figure out the small window bounds
steps_till_abutting_window = 1/(1-fo);
if(not(steps_till_abutting_window) == floor(steps_till_abutting_window))
    warning('fraction_overlap should be set so that after some number of slides, the new window start time equals an old window end time.  1/(1-fraction_overlap) should be int.');
end

stepsize = short_tw * (1-fo);
start_times = long_tw(1):stepsize:long_tw(2);
start_times = start_times(1:end-1);
end_times = start_times + short_tw;

if(~isempty(p.Results.lfp_regress_info))
    dt = min(diff(p.Results.lfp_beta_data.timestamps));
    start_times = p.Results.lfp_beta_data.timestamps - dt/2;
    fo = p.Results.lfp_regress_info.fraction_overlap;
    short_tw = dt * 1/(1-fo);
    end_times = start_times + short_tw;
    lfp_regress_info = p.Results.lfp_regress_info;
    lfp_beta_data = p.Results.lfp_beta_data;
end
    
beta_data.timestamps = (start_times + end_times) ./ 2;
beta_data.mua_est = zeros(2,numel(start_times)); % n params by n timepoints
beta_data.mua_ci = zeros(2,numel(start_times),2); % n params by n timepoints by low/high ci
beta_data.mua_r_squared = zeros(1,numel(start_times));

regress_info.n_small_windows = numel(start_times);
regress_info.long_timewin = long_tw;
regress_info.fraction_overlap = fo;

n_wins = numel(beta_data.timestamps);
for n = 1:n_wins
    this_win = [start_times(n),end_times(n)];
    disp(['Working on win ', num2str(n), '/', num2str(n_wins),'.  Time: ', num2str(start_times(n))]);
    [this_f,this_mulist,this_kappalist,reg_stats,tmptrodexy] = sdat_phase_pref(mua,rat_conv_table,'timewin',this_win,'draw',false);
    beta_data.mua_est(:,n) = [reg_stats.wave_angle;reg_stats.lambda];
    beta_data.mua_r_squared(n) = reg_stats.r_squared;
end

if(~isempty(p.Results.lfp_beta_data))
    lfp_beta_data.mua_est = beta_data.mua_est;
    lfp_beta_data.mua_r_squared = beta_data.mua_r_squared;
    lfp_beta_data.mua_ci = beta_data.mua_ci;
    beta_data = lfp_beta_data;
end
