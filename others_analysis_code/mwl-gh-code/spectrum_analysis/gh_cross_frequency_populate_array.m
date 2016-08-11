function [m_norm_array,gamma_centers] = gh_cross_frequency_populate_array(eeg,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('theta_ind',[]);
p.addParamValue('gamma_ind',1:size(eeg.data,2));
p.addParamValue('freq_range',[7, (eeg.samplerate./2)]);
p.addParamValue('freq_step',2);
p.addParamValue('bandwidths',10); 
p.addParamValue('stop_widths',14);
p.addParamValue('num_surrogates',200); % use 0 or [] to report raw M values (not normed)
p.addParamValue('verbose',false);

p.addParamValue('n_trial_repeat',1);
p.parse(varargin{:});
opt = p.Results;

m_norm_array = cell(opt.n_trial_repeat,numel(opt.gamma_ind));

for n = 1:numel(opt.gamma_ind)
    for m = 1:opt.n_trial_repeat
        disp(['Calculating chan ', num2str(n), ', trial ', num2str(m), '.']);
        
        if(~isempty(opt.theta_ind)) % only pass a theta_ind if we mean it
            [m_norm, gamma_centers] = gh_cross_frequency_coupling(eeg,...
                'timewin',opt.timewin,'theta_ind',opt.theta_ind,'gamma_ind',opt.gamma_ind(n),'freq_range',opt.freq_range,...
                'freq_step',opt.freq_step,'bandwidths',opt.bandwidths,'stop_widths',opt.stop_widths,...
                'num_surrogates',opt.num_surrogates,'verbose',opt.verbose);
        else % interpret blank as use theta from same channel as gamma
            [m_norm, gamma_centers] = gh_cross_frequency_coupling(eeg,...
                'timewin',opt.timewin,'theta_ind',opt.gamma_ind(n),'gamma_ind',opt.gamma_ind(n),'freq_range',opt.freq_range,...
                'freq_step',opt.freq_step,'bandwidths',opt.bandwidths,'stop_widths',opt.stop_widths,...
                'num_surrogates',opt.num_surrogates,'verbose',opt.verbose);
        end
        
        m_norm_array{m,n} = m_norm;
    end
end