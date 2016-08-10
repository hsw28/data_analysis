function theta_bouts = gh_theta_bouts(varargin)

p = inputParser();
p.addParamValue('eeg_theta',[]);
p.addParamValue('needs_smoothing',false,@islogical);
p.addParamValue('filtopt',filtoptdefs('smooth_sd_400ms'));
p.addParamValue('verbose',false,@islogical);
p.addParamValue('theta_env',[]);
p.addParamValue('power_threshold',0.05,@isreal);
p.addParamValue('eeg_theta_phase',[]);
p.parse(varargin{:});
opt = p.Results;

if(isempty(opt.theta_env))
    if(not(isempty(opt.eeg_theta)))
        opt.theta_env = multicontenv(opt.eeg_theta);
    else
        error('Must provide eeg_theta or theta_env');
    end
end

if(opt.needs_smoothing)
    opt.filtopt.Fs = opt.theta_env.samplerate;
    the_filt = mkfilt('filtopt',opt.filtopt);
    opt.theta_env = contfilt(opt.theta_env,'filt',the_filt);
end

% build theta bouts
nchans = size(opt.theta_env.data,2);
theta_bouts = cell(1,nchans);
for i = 1:nchans
    this_smooth_env = contchans(opt.theta_env,'chans',i);
    theta_bouts{i} = contbouts(this_smooth_env,...
    'timeargunits','seconds',...
    'datargunits','stdevs',...
    'thresh_fn', @ge,...
    'thresh', opt.power_threshold,...
    'minevdur', 0.25, ...
    'window',0.01, ...
    'mindur',0.4, ...
    'interp', false);
    theta_bouts{i} = theta_bouts{i}';
    if(opt.verbose)
        theta_bouts{i}
    end
end
