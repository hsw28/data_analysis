function stimulus = mk_stimulus_lin_track(varargin)
% MK_STIMULUS Stimulus for stimulus decoding

p = inputParser();
p.addParamValue('pos_info',[]);
p.addParamValue('timewin',[]);
p.addParamValue('samplerate',[]);
p.addParamValue('timepoints',[]);
p.addParamValue('timebouts',[]);
p.addParamValue('pos_bin_limits',[]);
p.addParamValue('pos_dp', 0.1);
p.addParamValue('pos_bin_edges',[]);
p.addParamValue('features', cell(0));
p.addParamValue('var_types',cell(0));
p.parse(varargin{:});
opt = p.Results;

posinfo_ts = conttimestamp(opt.pos_info.lin_filt);
if(isempty(opt.samplerate))
    dt = posinfo_ts(2) - posinfo_ts(1);
else
    dt = 1/opt.samplerate;
end
if(isempty(opt.timewin))
    opt.timewin = [posinfo_ts(1), posinfo_ts(end)];
end
stim_ts = opt.timewin(1) : dt : opt.timewin(2);
if(~isempty(opt.timepoints))
    stim_ts = reshape(opt.timepoints,1,[]);
end

if(isempty(opt.timebouts))
    dt = stim_ts(2) - stim_ts(1);
    opt.timebouts = [stim_ts' - dt/2, stim_ts' + dt/2];
else
     stim_ts = (mean(opt.timebouts,2))';
end

if(isempty(opt.pos_bin_limits))
    opt.pos_bin_limits = [min(opt.pos_info.lin_filt.data), max(opt.pos_info.lin_filt.data)];
end
pos_bin_edges = opt.pos_bin_limits(1) : opt.pos_dp : opt.pos_bin_limits(2);
if(max(pos_bin_edges)) < max(opt.pos_info.lin_filt.data)
    pos_bin_edges = [pos_bin_edges, max(pos_bin_edges) + opt.pos_dp];
end
if(~isempty(opt.pos_bin_edges))
    pos_bin_edges = opt.pos_bin_edges;
end
pos_bin_centers = pos_bin_edges(1:(end-1)) + opt.pos_dp/2;

posinfo_lin = reshape(opt.pos_info.lin_filt.data(:,1),1,[]);
stim_time_pos = interp1(posinfo_ts, posinfo_lin, stim_ts, 'linear', 'extrap');
stim_time_pos(isnan(stim_time_pos)) = 0;
[~, posbin_inds] = histc(stim_time_pos, pos_bin_edges);
stim_pos = posbin_inds;


run_direction = 2*ones(size(stim_ts));
outbound_wins = opt.pos_info.out_run_bouts;
[~, outbound_bool] = gh_times_in_timewins(stim_ts, outbound_wins);
run_direction(logical(outbound_bool)) = 1;
inbound_wins = opt.pos_info.in_run_bouts;
[~, inbound_bool] = gh_times_in_timewins(stim_ts, inbound_wins);
run_direction(inbound_bool) = 3;

stim_dim = 2;
stimulus.stim_dim = stim_dim;

stimulus.value = zeros(numel(stim_ts), stim_dim);
stimulus.value(:,1) = reshape(stim_pos,[],1);
stimulus.value(:,2) = reshape(run_direction,[],1);
stimulus.value_name = cell(1,stim_dim);
stimulus.value_name{1} = 'linear_position';
stimulus.value_name{2} = 'run_direction';
stimulus.value_mapping = cell(1,stim_dim);
stimulus.value_mapping{1} = pos_bin_centers;
stimulus.value_mapping{2} = [1 0 -1];  % value 1 in outbound, 2 is stationary; 3 is inbound
stimulus.ts = reshape(stim_ts,[],1);
stimulus.timebouts = opt.timebouts;