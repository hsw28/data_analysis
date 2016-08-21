function [ipsiCorr contCorr shuffCorr freq] = dset_calculate_bilateral_mean_ripple_freq_corr(dset)

    nShuffle = 500;
    
    baseChan = dset.channels.base;
    ipsiChan = dset.channels.ipsi;
    contChan = dset.channels.cont;

    eeg = dset.eeg;
    
   
    ripWin = find_rip_burst(eeg(1).data, eeg(1).fs, eeg(1).starttime);
   
    freqBase = dset_calc_event_mean_freq(eeg(1).data, eeg(1).starttime, eeg(1).fs, ripWin);
    freqIpsi = dset_calc_event_mean_freq(eeg(2).data, eeg(1).starttime, eeg(1).fs, ripWin);
    freqCont = dset_calc_event_mean_freq(eeg(3).data, eeg(1).starttime, eeg(1).fs, ripWin);
   
    validIdx = ~( isnan(freqBase) | isnan(freqIpsi) | isnan(freqCont) );
   
    ipsiCorr = corr2(freqBase(validIdx), freqIpsi(validIdx));
    contCorr = corr2(freqBase(validIdx), freqCont(validIdx));
    
    for i = 1:500
        shuffleFreq = randsample(freqBase(validIdx), sum(validIdx), 1);
        shuffCorr(i) = corr2(freqBase(validIdx), shuffleFreq);
    end
    
    freq.base = freqBase;
    freq.ipsi = freqIpsi;
    freq.cont = freqCont;
end