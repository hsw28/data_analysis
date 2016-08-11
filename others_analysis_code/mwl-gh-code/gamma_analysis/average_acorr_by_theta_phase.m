function average_acorr = average_acorr_by_theta_phase( ...
    acorr_by_t, eeg_r, varargin)

p = inputParser();
p.addParamValue('phase_bin_edges',(-pi):((2*pi)/10):pi);
p.addParamValue('phase_chan',1);
p.addParamValue('env_thresh',[]);
p.parse(varargin{:});
opt = p.Results;

if(~or(ischar(opt.phase_chan), isempty(opt.phase_chan)))
    opt.phase_chan = eeg_r.raw.chanlabels{opt.phase_chan};
end

n_chans = size(acorr_by_t.data,3);
n_ts = size(acorr_by_t.data,2);
n_lags = size(acorr_by_t.data,1);
ts = linspace(acorr_by_t.tstart,acorr_by_t.tend,n_ts);
phase_bin_edges = opt.phase_bin_edges;
dphase = phase_bin_edges(2) - phase_bin_edges(1);
phase_bin_centers = phase_bin_edges(1:(end-1)) + dphase/2;
n_phases = numel(phase_bin_centers);

phase_ts = conttimestamp(eeg_r.raw);

average_acorr.data = zeros( n_lags, n_phases, n_chans);
average_acorr.lags_secs = acorr_by_t.lags_secs;

for n = 1:n_chans
    if(~isempty(opt.phase_chan))
        phase_data = eeg_r.phase.data(:,...
            strcmp(opt.phase_chan, eeg_r.raw.chanlabels));
        env_data = eeg_r.env.data(:,...
            strcmp(opt.phase_chan, eeg_r.raw.chanlabels));
    else
        phase_data = eeg_r.data(:,n)';
        env_data =     eeg_r.data(:,n)';
    end
    
    phases_at_acorr = interp1(phase_ts, phase_data,...
                                             ts);
    
    [~,p_inds] = histc(phases_at_acorr, phase_bin_edges);
    if(~isempty(opt.env_thresh))
        p_inds( env_data < opt.env_thresh) = NaN;
    end
    
    disp([num2str( numel(p_inds) - sum(isnan(p_inds))),...
        ' good inds.']);
    
    for p = 1:n_phases
        this_acorr_data = acorr_by_t.data(:, (p_inds == p), n);
        average_acorr.data(:,p,n) = mean(this_acorr_data, 2);
    end
end