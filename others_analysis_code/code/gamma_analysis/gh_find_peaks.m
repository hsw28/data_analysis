function [times opt] = gh_find_peaks(eeg_r,varargin)

p = inputParser;
p.addParamValue('timewin',[]);

p.addParamValue('chan_ind',1); % channel from which to take phase
p.addParamValue('phase_field','phase'); % field of eeg_r from which to take phase (must me a phase timeseries)
p.addParamValue('theta_env_field','env'); % field of eeg_r for env (env timeseries)
p.addParamValue('theta_env_chan',[]); % chan to use for thresholding env
p.addParamValue('theta_env_thresh',0); % theta threshold
p.addParamValue('gamma_env_field',[]); % field of eeg_r for gamma env threshold
p.addParamValue('gamma_env_chan',1); % chan of eeg_r env field for threshold
p.addParamValue('gamma_env_thresh',[]); % gamma threshold

p.addParamValue('phase_val',[]); % phase of theta to trigger on.  0 is the trough.  Defaults to troughs 
p.addParamValue('method','hilbert',@(x) any(strcmp(x,{'hilbert','local_min'}))); % method of determining phase values
p.addParamValue('gh_find_peaks_opt',[]); % pre-loaded options passed here overrive everything above
p.parse(varargin{:});
opt = p.Results;
if(~isempty(opt.gh_find_peaks_opt))
    opt = opt.gh_find_peaks_opt;
end

num_trig_list = length(opt.chan_ind);
trig_list = cell(1,num_trig_list);
ts = conttimestamp(eeg_r.raw);

for n = 1:num_trig_list
    
    if(isempty(opt.theta_env_chan)) % pick a channel for min theta power
        this_theta_env_chan = n;
    else
        this_theta_env_chan = opt.theta_env_chan;
    end
    if(isempty(opt.gamma_env_chan)) % likewise for min gamma power
        this_gamma_env_chan = n;
    else
        this_gamma_env_chan = opt.gamma_env_chan;
    end
    
    phase = eeg_r.(opt.phase_field); % will usually evaluate to eeg_r.phase
    phase_data = phase.data(:,opt.chan_ind(n))';

    theta_env = eeg_r.(opt.theta_env_field); % will usually evaluate to eeg_r.env
    
    theta_ok_bool = theta_env.data(:,opt.theta_env_chan)' >= opt.theta_env_thresh;
    
    if(~isempty(opt.gamma_env_field))
        % next will usually evaluate to eeg_r.env, meaning theta env
        gamma_env = eeg_r.(opt.gamma_env_field); 
        gamma_env_data = gamma_env.data(:,this_gamma_env_chan)';
        gamma_ok_bool = gamma_env_data >= opt.gamma_env_thresh;
    else
        gamma_ok_bool = ones(size(ts));
    end

    n_phase = length(phase_data);

    if(strcmp(opt.method,'hilbert'))
        trough_ind = find(diff(phase_data) < -5) + 1;
        trough_bool = logical([0, diff(phase_data) < -6]);
    elseif(strcmp(opt.method,'local_min'))
        this_data = eeg_r.gamma.data(:,opt.chan_ind(n))';
        trough_ind = find(...
            and(this_data(1:end-2) > this_data(2:end-1),...
            this_data(2:end-1) < this_data(3:end)));
        trough_ind = trough_ind + 1;
        trough_bool = and(this_data(1:end-2) > this_data(2:end-1),...
            this_data(2:end-1) < this_data(3:end));
        trough_bool = logical([0, trough_bool, 0]);
    end

    
    %if(~isempty(opt.theta_env_thresh))
    %    trough_theta_env = theta_env.data(trough_ind,this_theta_env_chan);
    %    trough_ind = trough_ind(trough_theta_env >= opt.theta_env_thresh);
    %end
    in_timewin_bool = and(ts >= opt.timewin(1), ts <= opt.timewin(2));
    
    all_bool=([trough_bool;...
        in_timewin_bool;theta_ok_bool;gamma_ok_bool]);
    all_bool = (sum(all_bool,1) == size(all_bool,1));
    
    %trough_ind = trough_ind(trough_ind < n_phase);
    trough_times = ts(all_bool);
    
    %if(~isempty(opt.timewin))
    %    trough_times = trough_times(and(trough_times >= opt.timewin(1), trough_times <= opt.timewin(2)));
    %end

    times = trough_times;
    trig_list{n} = times;
end

times = trig_list;

if(num_trig_list == 1)
    times = times{1};
end