function f = example_precession(clust, pos_info, eeg_r, varargin)

p = inputParser();
p.addParamValue('phase_offset',0);
p.addParamValue('eeg_ind',1);
p.addParamValue('double_cycle',true);
p.addParamValue('timewin',[pos_info.lin_filt.tstart, pos_info.lin_filt.tend]);
p.parse(varargin{:});
opt = p.Results;

eeg_r = contwin_r(eeg_r, opt.timewin);

phase_ind = find(strcmp('theta_phase',clust.featurenames),1);
stimes = clust.stimes';
phases = mod((clust.data(:,phase_ind)' + opt.phase_offset),2*pi);

keep_bool = stimes >= opt.timewin(1) & stimes <= opt.timewin(2);

stimes = stimes(keep_bool);
phases = phases(keep_bool);

if(opt.double_cycle)
    stimes = [stimes,stimes];
    phases = [phases, phases + 2*pi];
end

f = draw_phase_precession(clust, 'clim',[0 20], 'stack','vertical','field_direction','outbound','ind',1);

pos_ts = conttimestamp(pos_info.lin_filt);
pos = pos_info.lin_filt.data';
keep_bool = pos_ts >= opt.timewin(1) & pos_ts <= opt.timewin(2);
pos_ts = pos_ts(keep_bool);
pos = pos(keep_bool);


pos_at_spike_time = interp1(pos_ts, pos, stimes,'linear');
pos_at_eeg_time = interp1(pos_ts, pos, conttimestamp(eeg_r.raw));

hold on;
plot(pos_at_eeg_time, eeg_r.raw.data(:,opt.eeg_ind));
plot(pos_at_eeg_time, eeg_r.theta.data(:,opt.eeg_ind));

[xs,ys] = gh_raster_points(pos_at_spike_time,'y_range',[1 2]);
plot(xs,ys);



