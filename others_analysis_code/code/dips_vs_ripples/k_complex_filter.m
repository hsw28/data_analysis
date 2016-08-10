function [eegDip, phaseDip, envDip] = k_complex_filter( eeg, varargin )

p = inputParser();
p.addParamValue('bandLims',[0.5 2 5 7]);
p.addParamValue('mua',[]);
p.addParamValue('muaWeight',0.5);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

k_filtopts.name = 'k_complex'
k_filtopts.Fs = eeg.samplerate;
k_filtopts.filttype = 'bandpass';
k_filtopts.F = opt.bandLims;
k_filtopts.atten_db = -50;
k_filtopts.ripp_db = 1;
k_filtopts.datatype = 'single';

k_filt = mkfilt('filtopt',k_filtopts);

eegDip = contfilt( eeg, 'filt', k_filt, 'autoresample', false );

phaseDip = multicontphase( eegDip );

envDip = multicontenv( eegDip );

if(opt.draw)
    [~,spacing] = gh_plot_cont( eegDip );
    hold on;
    gh_plot_cont( eeg, 'spacing', spacing);
end