function [xcIpsi, xcCont] = dset_analyze_xcorr_ripple_band(dset, env)
    
    if ~isfield(dset.eeg,'rippleband')
        dset = dset_filter_eeg_ripple_band(dset);
    end
    
    baseChan = dset.channels.base;
    ipsiChan = dset.channels.ipsi;
    contChan = dset.channels.cont;
    
    fs = dset.eeg(1).fs;
    nLags = 300;
    ts = (-1*nLags:nLags) / fs;
    
    if nargin == 1
        [xcIpsi] = xcorr(dset.eeg(baseChan).rippleband, dset.eeg(ipsiChan).rippleband, nLags, 'coeff');
        [xcCont] = xcorr(dset.eeg(baseChan).rippleband, dset.eeg(contChan).rippleband, nLags, 'coeff');
    
    elseif nargin==2 && env==1
        envBase = abs(hilbert(dset.eeg(baseChan).rippleband));
        envIpsi = abs(hilbert(dset.eeg(ipsiChan).rippleband));
        envCont = abs(hilbert(dset.eeg(contChan).rippleband));
    
        [xcIpsi] = xcorr(envBase, envIpsi, nLags, 'coeff');
        [xcCont] = xcorr(envBase, envCont, nLags, 'coeff');
    end
    
end

