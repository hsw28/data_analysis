function [match_times,match_bool] = gh_troughs_from_phase(eeg_r,varargin)
% trough_times = gh_troughs_from_phase(phase_cdat) Find theta trough or other phase
%
% Optional params: 
%    'phase' usually [-pi,pi], depends on cdat limits
%    'chan_ind', numelical index of channel, no option for channel name
%    'env_thresh' - filter points to those where envelope is higher than
%            this threshold
%    'run_speed_thresh' - minimum POSITIVE run speed to keep a point
%    'pos_info'  - used by above filter
%    'run_direction' - can be [], 'bidirect', 'inbound', or 'outbound'


p = inputParser();
p.addParamValue('phase',0);
p.addParamValue('chan_ind',1);
p.addParamValue('env_thresh',[]);
p.addParamValue('pos_info', []);
p.addParamValue('run_direction', 'bidirect');
p.addParamValue('run_speed_thresh',[]);
p.parse(varargin{:});
opt = p.Results;

ts = conttimestamp(eeg_r.phase);

data = eeg_r.phase.data(:, p.Results.chan_ind);

match_bool = reshape( [diff(data >= p.Results.phase) == 1; 0], 1, []);
zeros_match_bool = reshape([diff(data >=  0) == 1; 0], 1, []);

shift_count = 0;
while( sum(match_bool) < (0.9 * sum(zeros_match_bool)) && shift_count < 10)
    % cover the case when user asks for pi, -pi, 2pi, or -2p when
    % these data are too close to the domain edges of the phase timecourse
    shift_count = shift_count + 1;
    if(opt.phase < 0)
        direction = -1;
    elseif(opt.phase > 0)
        direction = 1;
    end
    data = mod(data - direction*shift_count*pi + pi, 2*pi) + ...
        direction*shift_count*pi - pi;
    match_bool = reshape([diff(data >= p.Results.phase) == 1; 0],1,[]);
end

if(~isempty(opt.run_speed_thresh))
    if(isempty(opt.pos_info))
        error('gh_troughs_from_phase:no_pos_info',...
            'gh_troughs_from_phase tried to filter on run speed but got no pos_info');
    end
    fast_enough_bool = abs(interp1(conttimestamp(opt.pos_info.lin_filt),...
        opt.pos_info.lin_filt.data', ts)) >= opt.run_speed_thresh;
    match_bool = and(match_bool, fast_enough_bool);
end

if(any(strcmp( opt.run_direction, {'inbound', 'outbound'})))
    if(isempty(opt.pos_info))
        error('gh_troughs_from_phase:no_pos_info',...
            'gh_troughs_from_pahse tried to filter on run direction but got no pos_info');
    end
    if(isempty(opt.run_speed_thresh))
        error('gh_troughs_from_phase:no_run_speed_thresh',...
            'gh_troughs_from_phase tried to filter on run direction but got no run_speed_thresh');
    end
    if(strcmp(opt.run_direction, 'outbound'))
        [~, correct_direction] = gh_times_in_timewins(ts, opt.pos_info.out_run_bouts);
    end
    if(strcmp(opt.run_direction, 'inbound'))
        [~, correct_direction] = gh_times_in_timewins(ts, opt.pos_info.in_run_bouts);
    end
    match_bool = and(match_bool, correct_direction);
end

if(~isempty(opt.env_thresh))
    suitable_power = eeg_r.env.data(:,opt.chan_ind) >= opt.env_thresh;
    match_bool = and(match_bool, suitable_power);
end

match_times = ts(logical(match_bool));

