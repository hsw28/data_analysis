function [dips, frames] = find_dips_frames(mua_rate,eeg,varargin)

p = inputParser();
p.addParamValue('mean_rate_threshold', 30);
p.addParamValue('smooth_sec',0.005);
p.addParamValue('trode_groups',[]);
p.addParamValue('area_for_threshold','RSC');
p.addParamValue('min_width_pre_bridge',0.020);
p.addParamValue('frame_length_range', [0.01 10]);
p.addParamValue('time_whitelist',[]);
p.addParamValue('time_blacklist',[]);
p.addParamValue('k_complex_freqs',[100,150,200,300]); % Theta-env, a k-complex-like stopgap
p.addParamValue('k_env_override',[]);
p.addParamValue('k_complex_env_threshold',-0.1);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.area_for_threshold))
    if(~isempty(opt.trode_groups))
        mua_rate = contchans_trode_group(mua_rate,opt.trode_groups,opt.area_for_threshold);
    else
        error('find_dips_frames:need_both_params','Need trode_groups and area_for_threshold or neither');
    end
end

if(~isempty(opt.area_for_threshold))
    if(isempty(opt.trode_groups))
        error('need trode_groups');
    else
        eeg = contchans_trode_group(eeg,opt.trode_groups,...
            opt.area_for_threshold);
    end
end

okWin = {[-inf,inf]};
if(~isempty(opt.time_whitelist))
    okWin = gh_intersection_segs(okWin,opt.time_whitelist);
end
if(~isempty(opt.time_blacklist))
    okWin = gh_subtract_segs(okWin,opt.time_blacklist);
end

dip_crit = seg_criterion('cutoff_value', opt.mean_rate_threshold,...
    'threshold_is_positive',false,...
    'bridge_max_gap',0.005,'min_width_pre_bridge',opt.min_width_pre_bridge);

mua_mean = mua_rate;
mua_mean.data = mean(double(mua_mean.data),2);
mua_mean.chanlabels = {'meanRate'};
nSmooth = floor(mua_mean.samplerate * opt.smooth_sec);
if(nSmooth > 1)
    mua_mean.data = smooth(mua_mean.data,nSmooth);
end

dips = gh_signal_to_segs(mua_mean,dip_crit);
frames = gh_invert_segs(dips);

dips = gh_intersection_segs(dips,okWin);
frames = gh_intersection_segs(frames,okWin);

% filter down frames by frame length
frames = ...
    frames(cellfun(@(x) (diff(x) >= min(opt.frame_length_range) && ...
    diff(x) <= max(opt.frame_length_range)), frames, 'UniformOutput',true));

% Filter dips by 'ripple' (spike-in-lfp) power
if(isempty(opt.k_env_override))
    [~,~,env] = gh_ripple_filt(eeg,'F',opt.k_complex_freqs);
    env.data = mean(env.data,2);
else
    env = contchans_trode_group(opt.k_env_override,opt.trode_groups,opt.area_for_threshold);
    env.data = mean(env.data,2);
end
envDeviation = contmap((@(x) (x - smooth(x,1600))), env); %  1600: 2 seconds at 800 Hz (TODO fix this magic number jeez)

keepDip = cellfun(@(x) winPassThresh(x,envDeviation,opt.k_complex_env_threshold),dips);
droppedDips = dips(~keepDip);
dips=dips(keepDip);

if(opt.draw)
    %gh_plot_cont(mua_mean);
    %hold on;
    gh_plot_cont(envDeviation);
    hold on;
    %gh_plot_cont(eeg,'trode_groups',opt.trode_groups);
    gh_draw_segs({frames, dips,droppedDips}, 'names',{'frames','dips','dropped'},'ys',{[-1, 0],[-2, -1],[-3, -2]});
end
end

function b = winPassThresh(w,env,thresh)

    subenv = contwin(env,w);
    b = max(subenv.data) >= thresh;

end