function [m_norm,gamma_centers] = gh_cross_frequency_coupling(eeg,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('theta_ind',2);
p.addParamValue('gamma_ind',2);
p.addParamValue('freq_range',[7, (eeg.samplerate./2)]);
p.addParamValue('freq_step',2);
p.addParamValue('bandwidths',10); 
p.addParamValue('stop_widths',14);
p.addParamValue('num_surrogates',200); % use 0 or [] to report raw M values (not normed) [Not implemented yet]
p.addParamValue('verbose',false);
p.parse(varargin{:});
opt = p.Results;

% set asside cdats for theta and gamma
eeg_t = contchans(eeg,'chans',opt.theta_ind);
eeg_g = contchans(eeg,'chans',opt.gamma_ind);

% set up theta filtered signals, contwin them
[eeg_theta, phase_theta, env_theta] = gh_theta_filt(eeg_t);
if(isempty(opt.timewin))
    warning('Strongly recommended: a timewin a least a couple seconds clipped from the raw ends prevents NaNs in phase and env');
else
    eeg_theta = contwin(eeg_theta,opt.timewin);
    phase_theta = contwin(phase_theta,opt.timewin);
    env_theta = contwin(env_theta,opt.timewin);
end
phase = phase_theta.data;
numpoints = length(phase);

opt.freq_range(2) = min([eeg.samplerate/2 - opt.stop_widths/2, opt.freq_range(2)]);

% prep gamma windows
gamma_centers = [opt.freq_range(1):opt.freq_step:opt.freq_range(2)]';
n_gamma_centers = numel(gamma_centers);
gamma_wins = [gamma_centers - opt.stop_widths/2, gamma_centers - opt.bandwidths/2, ...
    gamma_centers + opt.bandwidths/2, gamma_centers + opt.stop_widths/2];

% initialize m_norm results vector
m_norm = zeros(1,n_gamma_centers);

srate = eeg.samplerate;
numsurrogate = opt.num_surrogates;
minskip = srate;
maxskip = numpoints - srate;

% find m_norms for gamma freqs
for n = 1:n_gamma_centers
    
    if(opt.verbose)
        disp(['Phase coupling: theta ind ', num2str(opt.theta_ind),', gamma ind', num2str(opt.gamma_ind),...
            ', gamma_center ',num2str(gamma_centers(n)),'.']);
    end

    % setup gamma env
    [tmp1,tmp2,env_gamma] = gh_gamma_filt(eeg_g,'passband',gamma_wins(n,:));
    if(~isempty(opt.timewin))
        env_gamma = contwin(env_gamma,opt.timewin);
    end
    clear tmp1;
    clear tmp2;
    amplitude = env_gamma.data;
    
    % setup skips
    skip = ceil(numpoints .* rand(numsurrogate*2,1));
    skip = skip(and(skip > minskip, skip < maxskip));
    skip = skip(1:numsurrogate,1);
    surrogate_m = zeros(numsurrogate,1);
    
    z = amplitude .* exp(i*phase);
    m_raw = mean(z);
    
    for s = 1:numsurrogate
        surrogate_amplitude = [amplitude(skip(s):end); amplitude(1:skip(s)-1)];
        surrogate_m(s) = abs(mean(surrogate_amplitude .* exp(i*phase)));
        if(opt.verbose)
            %disp(num2str(numsurrogate - s));
        end
    end
    if(numsurrogate > 0)
        [surrogate_mean, surrogate_std] = normfit(surrogate_m);
        m_norm_length = (abs(m_raw) - surrogate_mean) / surrogate_std;
        m_norm_phase = angle(m_raw);
        m_norm(n) = m_norm_length * exp(i*m_norm_phase);
    else
        m_norm_length = abs(m_raw);
        m_norm_phase = angle(m_raw);
        m_norm(n) = m_norm_length ./ m_norm_length * exp(i*m_norm_phase);
    end
    
end