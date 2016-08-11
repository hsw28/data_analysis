function [rel_ts, mean_norm_phase, indiv_norm_phase, phase_stdev, dist_from_expected] = trig_shift_theta(eeg_r,trig_times,varargin)

% note to self - function outputs not set yet.  I generated old figs by
% plotting intermediate variables from debug mode

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('rel_timewin',[-0.5, 0.5]);
p.addParamValue('exclude_wins_with_trigs_in_pre',true);
p.addParamValue('exclude_wins_with_trigs_in_post',true);
p.addParamValue('max_env_thresh',[]);
p.addParamValue('min_env_thresh',[]);
p.addParamValue('chan_for_env_thresh',1);
p.addParamValue('examine_trig_times',false);
p.addParamValue('rewrap_phase',true);
p.addParamValue('subtract_zero_phase',true);
p.addParamValue('mult_by_env',true);
p.parse(varargin{:});
opt = p.Results;

if(opt.examine_trig_times)
    [xs,ys] = gh_raster_points(trig_times);
    f1 = plot(xs,ys,'r');
    hold on;
end

if(~isempty(opt.timewin))
    eeg_r = contwin_r(eeg_r,opt.timewin);
end
eeg_timewin = [eeg_r.raw.tstart, eeg_r.raw.tend];

ts = conttimestamp(eeg_r.raw);
dt = ts(2)-ts(1);
rel_ts = [opt.rel_timewin(1):dt:opt.rel_timewin(2)];

trig_ok_bool = and( (trig_times >= (eeg_timewin(1)-opt.rel_timewin(1))), (trig_times <= (eeg_timewin(2) - opt.rel_timewin(2))));
trig_times = trig_times(logical(trig_ok_bool));

if(opt.exclude_wins_with_trigs_in_pre)
    ok_bool = [1, diff(trig_times) >= -1*opt.rel_timewin(1)];
    trig_times = trig_times(logical(ok_bool));
end

if(opt.exclude_wins_with_trigs_in_post)
    ok_bool = [(diff(trig_times) > opt.rel_timewin(2)),1];
    trig_times = trig_times(logical(ok_bool));
end

env_inds = lfun_times_to_inds(trig_times + opt.rel_timewin(1), diff(opt.rel_timewin), conttimestamp(eeg_r.raw));
env_data = reshape(eeg_r.env.data(:,opt.chan_for_env_thresh),1,[]);
env_vals = env_data(env_inds);

if(~isempty(opt.max_env_thresh))
    ok_bool = max(env_vals,[],2) >= opt.max_env_thresh;
    trig_times = trig_times(logical(ok_bool));
    env_vals = env_vals(logical(ok_bool),:);
end
if(~isempty(opt.min_env_thresh))
    ok_bool = min(env_vals,[],2) >= opt.min_env_thresh;
    trig_times = trig_times(logical(ok_bool));
    env_vals = env_vals(logical(ok_bool),:);
end

if(opt.examine_trig_times)
    %figure(f1);
    [xs,ys] = gh_raster_points(trig_times);
    plot(xs,ys,'b','LineWidth',3);
end

phase_inds = lfun_times_to_inds(trig_times + opt.rel_timewin(1),diff(opt.rel_timewin), conttimestamp(eeg_r.raw));
zero_phase_inds = floor(interp1(ts,[1:numel(ts)],trig_times'));
n_trigs = numel(trig_times);
n_rel_ts = numel(rel_ts);
n_chans = size(eeg_r.raw.data,2);
phase_data = zeros(n_trigs,n_rel_ts,n_chans);
env_data = zeros(n_trigs,n_rel_ts,n_chans);
raw_data = zeros(n_trigs,n_rel_ts,n_chans);
theta_data = zeros(n_trigs,n_rel_ts,n_chans);
norm_phase_data = zeros(n_trigs,n_rel_ts,n_chans);
norm_reconst_data = zeros(n_trigs,n_rel_ts,n_chans);
non_norm_resets = cell(n_chans,1);
norm_resets = cell(n_chans,1);
for n = 1:n_chans
    this_phase_data = reshape(eeg_r.phase.data(:,n),1,[]);
    this_env_data = reshape(eeg_r.env.data(:,n),1,[]);
    this_raw_data = reshape(eeg_r.raw.data(:,n),1,[]);
    this_theta_data = reshape(eeg_r.theta.data(:,n),1,[]);
    phase_data(:,:,n) = this_phase_data(phase_inds);
    env_data(:,:,n) = this_env_data(phase_inds);
    raw_data(:,:,n) = this_raw_data(phase_inds);
    theta_data(:,:,n) = this_theta_data(phase_inds);
    zero_phase = this_phase_data(zero_phase_inds);
    if(~opt.subtract_zero_phase)
        zero_phase = zeros(size(zero_phase));
    end
    norm_phase_data(:,:,n) = mod((phase_data(:,:,n) - repmat(zero_phase',1,n_rel_ts)),2*pi);
    norm_reconst_data(:,:,n) = cos(norm_phase_data(:,:,n)) .* env_data(:,:,n);
    non_norm_reset_times = [];
    norm_reset_times = [];
    for m = 1:n_trigs
        non_norm_reset_times = [non_norm_reset_times, reshape(rel_ts(diff(phase_data(m,:,n)) < -3),1,[]) ];
        norm_reset_times = [norm_reset_times, reshape(rel_ts(diff(norm_phase_data(m,:,n)) < -3), 1, []) ];
    end
    non_norm_resets{n} = non_norm_reset_times;
    norm_resets{n} = norm_reset_times;
end

mean_norm_phase = 1; indiv_norm_phase = 1; phase_stdev = 1; dist_from_expected = 1;

function [inds, rel_times] = lfun_times_to_inds(start_times,interval_length,ts)
start_ind = floor(interp1(ts,[1:length(ts)],start_times));
num_ind = ceil(interval_length/(ts(2)-ts(1)));
%total_inds = [1:length(ts)];
inds = repmat(reshape(start_ind,[],1),1,num_ind) + repmat([0:(num_ind-1)],numel(start_ind),1);