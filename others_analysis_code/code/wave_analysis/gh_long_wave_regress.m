function [beta_data, regress_info] = gh_long_wave_regress(cdat_r,rat_conv_table,varargin)
% [wave_params, regress_info] = GH_LONG_WAVE_REGRESS( cdat, rat_conv_table,
%                                                    ['long_timewin',[b,e] ], ...
%                                                    ['short_timewin', win_length],...
%                                                    ['fraction_overlap',n],...
%                                                    ['nlin_regress',bool],... -enhance estimate?
%                                                    ['timewins',[
p = inputParser();
p.addParamValue('long_timewin',[]); % total timewin to regress on
p.addParamValue('short_timewin',0.25); % the size of the slices to regress on
p.addParamValue('fraction_overlap',0); % how much should short regression timewins overlap

p.addParamValue('timewins',[]);

p.addParamValue('nlin_regress', true);

%p.addParamValue('theta_filt',[]);   <-- these seem unused
%p.addParamValue('theta_phase',[]);
%p.addParamValue('theta_env',[]);

p.addParamValue('pos_info',[]); % if you have it, we'll interp into it for pos,speed info in beta_data
p.parse(varargin{:});
opt = p.Results;

n_param = 5; % params to estimate are temporal_freq, lambda wavelength, theta direction of propagation, phi phase offset, amp amplitude
n_independ_vars = 3; % independent vars to predict from are t time, x position, y position

%is input already in cdat_r form?
if(~isfield(cdat_r,'raw'))
    cdat_r = prep_eeg_for_regress(cdat_r);
end

% set up timewindow for the big wave
if(isempty(p.Results.long_timewin))
    long_timewin = [cdat_r.raw.tstart, cdat_r.raw.tend];
else
    long_timewin = p.Results.long_timewin;
end

% figure out the small window bounds
steps_till_abutting_window = 1/(1-p.Results.fraction_overlap);
if(not(steps_till_abutting_window) == floor(steps_till_abutting_window))
    warning('fraction_overlap should be set so that after some number of slides, the new window start time equals an old window end time.  1/(1-fraction_overlap) should be int.');
end

stepsize = p.Results.short_timewin * (1-p.Results.fraction_overlap);
start_times = long_timewin(1):stepsize:long_timewin(2);
start_times = start_times(1:end-1);
end_times = start_times + p.Results.short_timewin;

%override long_timewin/short_timewin options if user passed their own
%timewin array
if(~isempty(opt.timewins))
    start_times = opt.timewins(:,1);
    end_times = opt.timewins(:,2);
end

beta_data.timestamps = (start_times + end_times) ./ 2;
beta_data.est = zeros(n_param,numel(start_times)); % n params by n timepoints
beta_data.ci = zeros(n_param,numel(start_times),2); % n params by n timepoints by low/high ci
beta_data.r_squared = zeros(1,numel(start_times));
beta_data.start_times = start_times;

regress_info.n_small_windows = numel(start_times);
regress_info.long_timewin = long_timewin;
regress_info.fraction_overlap = p.Results.fraction_overlap;

for n = 1:numel(start_times)
    %this_cdat = contwin(cdat,[start_times(n),end_times(n)]);
    %this_theta_filt = contwin(p.Results.theta_filt,[start_times(n),end_times(n)]);
    %this_theta_phase = contwin(p.Results.theta_phase,[start_times(n),end_times(n)]);
    %this_theta_env = contwin(p.Results.theta_env,[start_times(n),end_times(n)]);
    %eeg.raw = this_cdat;
    %eeg.theta = this_theta_filt;
    %eeg.phase = this_theta_phase;
    %eeg.env = this_theta_env;
    if( mod(n, 100) == 0 )
        disp(['Working on wave-slice', num2str(n),'/',num2str(numel(start_times)),'. Timewin:', num2str([start_times(n), end_times(n)])]);
    end
    this_small_wave = contwin_r(cdat_r,[start_times(n),end_times(n)]);
    [this_est, this_ci, this_r_squared] = gh_short_wave_regress(this_small_wave,rat_conv_table, 'nlin_regress', opt.nlin_regress);
    beta_data.est(:,n) = this_est;
    beta_data.ci(:,n,:) = this_ci;
    beta_data.r_squared(n) = this_r_squared;
end

if(~isempty(p.Results.pos_info))
    beta_data.pos = interp1(conttimestamp(p.Results.pos_info.lin_filt),p.Results.pos_info.lin_filt.data,beta_data.timestamps);
    beta_data.vel = interp1(conttimestamp(p.Results.pos_info.lin_vel_cdat),p.Results.pos_info.lin_vel_cdat.data,beta_data.timestamps);
end