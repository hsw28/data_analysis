function sleepMap = sleep_states(epochMap, varargin)

p = inputParser();
p.addParamValue('eeg_r',[]);
p.addParamValue('theta_delta_ratio',[]);
p.addParamValue('REM_tdr_min',1.5);
p.addParamValue('REM_min_length',30);
p.addParamValue('SWS_tdr_max', 1 );
p.addParamValue('SWS_min_length',120);
p.addParamValue('emg_power',[]);
p.addParamValue('sleep_max_emg_power',[]);
p.addParamValue('ripple_rate',[]);
p.addParamValue('ripple_rate_crit',[]);
p.addParamValue('velocity_state',[]);
p.addParamValue('sleep_minimum_still_length',60);
p.addParamValue('sleep_epochs',{'sleep1','sleep2'});
p.addParamValue('fold_fn',@(x) x);
p.addParamValue('smooth_s',0);
p.parse(varargin{:});
opt = p.Results;


sleepEpochMap = filterMapKeys( @(x) any(strcmp(opt.sleep_epochs, x)), epochMap);
sleepEpochSegs = sleepEpochMap.values;

segs_cell = cell(0);

if(~isempty(opt.eeg_r) && isempty(opt.theta_delta_ratio))
    opt.theta_delta_ratio = theta_delta_ratio(eeg_r);
end

if(~isempty(opt.theta_delta_ratio)) % If we got tdr from user or from eeg_r
    % REM and SWS criteria, given that the animal is nonstationary and in
    % the sleep epochs (we'll pare down by these later)
    REM_criterion = seg_criterion('name','REM',...
        'cutoff_value', opt.REM_tdr_min,'min_width_pre_bridge',10,...
        'bridge_max_gap',2, 'min_width_post_bridge', opt.REM_min_length);
    SWS_criterion = seg_criterion('name','SWS',...
        'cutoff_value', opt.REM_tdr_max,'min_width_pre_bridge',5,...
        'bridge_max_gap',2, 'win_width_post_bridge', opt.SWS_min_length, ...
        'threshold_is_positive',false);
    REM_segs = gh_signal_to_segs(opt.theta_delta_ratio, REM_criterion);
    SWS_segs = gh_signal_to_segs(opt.theta_delta_ratio, SWS_criterion);
    %segs_cell{numel(segs_cell)+1} = gh_signal_to_segs(opt.theta_delta_ratio, ...
    %    opt.theta_delta_ratio_crit);
end

if(~isempty(opt.velocity_state))
    stillSegs = ...
        filter( @(x) diff(x) >= opt.sleep_min_still_length, ...
        opt.velocity_state.still);
end

sleep_segs = gh_intersection_segs( stillSegs, sleepEpochSegs );

REM_segs = gh_intersection_segs( sleep_segs, REM_segs );
SWS_segs = gh_intersection_segs( sleep_segs, SWS_segs );

sleepMap('REM') = REM_segs;
sleepMap('SWS') = SWS_segs;
sleepMap('sleep') = sleep_segs;
sleepMap('quietWake') = gh_subtract_segs( gh_subtract_segs(sleep_segs, REM_segs ), ...
    SWS_segs );