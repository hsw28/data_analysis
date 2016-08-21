function [ipsiCorr contCorr shuffCorr freq] = dset_analyze_ripple_freq_correlations(dset)

    error('DEPRECATED FUNCTION');
    nShuffle = 500;
    
    baseChan = dset.channels.base;
    ipsiChan = dset.channels.ipsi;
    contChan = dset.channels.cont;
    
    eeg = dset.eeg;

    %% Calculate the statistics on individual ripples
    
    [ripWin, peakTs, ~, ~, ~] = find_rip_burst(eeg(1).data, eeg(1).fs, eeg(1).starttime);
    
    peakFreqBase = dset_calc_event_peak_freq(eeg(baseChan).data, eeg(baseChan).starttime, eeg(baseChan).fs, peakTs);
    peakFreqIpsi = dset_calc_event_peak_freq(eeg(ipsiChan).data, eeg(ipsiChan).starttime, eeg(ipsiChan).fs, peakTs);
    peakFreqCont = dset_calc_event_peak_freq(eeg(contChan).data, eeg(contChan).starttime, eeg(contChan).fs, peakTs);
    
    ipsiCorr = corr2(peakFreqBase, peakFreqIpsi);
    contCorr = corr2(peakFreqBase, peakFreqCont);
    %%
    for i = 1:nShuffle
        shuffleFreq = randsample(peakFreqBase, numel(peakFreqIpsi), 1);
        shuffCorr(i) = corr2(peakFreqBase, shuffleFreq);
    end
    %%
    
    freq.base = peakFreqBase;
    freq.ipsi = peakFreqIpsi;
    freq.cont = peakFreqCont;
  
    
end
