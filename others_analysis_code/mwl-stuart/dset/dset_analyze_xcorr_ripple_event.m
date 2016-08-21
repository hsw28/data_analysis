function [xcIpsi xcCont] = dset_analyze_xcorr_ripple_event(dset, env)
    
    eeg = dset.eeg;
    if ~isfield(eeg,'rippleband')
        dset = dset_filter_eeg_ripple_band(dset);
    end
    
    for i = 1:numel(dset.eeg)
        thold = 3 * std(dset.eeg(i).rippleband);
        dset.eeg(i).rippleband = dset.eeg(i).rippleband >= thold;
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
    
    
  %  xcIpsi = xcIpsi / max(xcIpsi);
  %  xcCont = xcCont / max(xcCont);
% 
%     figure;
%     axes;
%     line(ts, xcIpsi, 'color', 'r');
%     line(ts, xcIpsi + ipsiBounds(1), 'color', 'r', 'linestyle', '--');
%     line(ts, xcIpsi + ipsiBounds(2), 'color', 'r', 'linestyle', '--');
%     
%     line(ts, xcCont, 'color', 'k');
%     line(ts, xcCont + contBounds(1), 'color', 'k', 'linestyle', '--');
%     line(ts, xcCont + contBounds(2), 'color', 'k', 'linestyle', '--');
%     
    
end

% args.high_thold = 7;
% args.low_thold =  2;