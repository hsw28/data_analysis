clear;

epList = dset_list_epochs('run');

for  k = 1:size(epList,1)

    animal = epList{k,1};
    day = epList{k,2};
    epoch = epList{k,3};

    minRipPeakDt = .025;

    dset = dset_load_all(animal, day, epoch, 1:30);
    baseChan = dset.channels.base;
    ipsiChan = dset.channels.ipsi;
    contChan = dset.channels.cont;
    eeg = dset.eeg;
    clear dset;

    %% Calculate the statistics on individual ripples
    for i = 1:numel(eeg)
        [ripWin{i}, peakTs{i}, ~, ~, ~] = find_rip_burst(eeg(i).data, eeg(i).fs, eeg(i).starttime);
    end

    %% Find the events that occur in both hemispheres
    contIdx = logical(zeros(size(peakTs{baseChan})));
    ipsiIdx = logical(zeros(size(peakTs{baseChan})));

    nearestIpsi = interp1(peakTs{ipsiChan}, peakTs{ipsiChan}, peakTs{baseChan}, 'nearest');
    ipsiIdx = abs(nearestIpsi - peakTs{baseChan}) <= minRipPeakDt;
    
    nearestCont = interp1(peakTs{contChan}, peakTs{contChan}, peakTs{baseChan}, 'nearest');
    contIdx = abs(nearestCont - peakTs{baseChan}) <= minRipPeakDt;

    peakFreqBase = dset_calc_event_peak_freq(eeg(baseChan).data, eeg(baseChan).starttime, eeg(baseChan).fs, peakTs{baseChan});
    peakFreqIpsi = dset_calc_event_peak_freq(eeg(ipsiChan).data, eeg(ipsiChan).starttime, eeg(ipsiChan).fs, peakTs{baseChan}(ipsiIdx));
    peakFreqCont = dset_calc_event_peak_freq(eeg(contChan).data, eeg(contChan).starttime, eeg(contChan).fs, peakTs{baseChan}(contIdx));

     if sum(ipsiIdx) < 30 || sum(contIdx)<30
         continue;
     end
    
    ipsiCorr = corr(peakFreqBase(ipsiIdx)', peakFreqIpsi(:));
    contCorr = corr(peakFreqBase(contIdx)', peakFreqCont(:));
    %%
    nShuffle = 500;
    for i = 1:nShuffle
        shuffleFreqIpsi = randsample(peakFreqBase, numel(peakFreqIpsi), 0);
        shuffleFreqCont = randsample(peakFreqBase, numel(peakFreqCont), 0);
        shuffCorrIpsi(i) = corr(peakFreqBase(ipsiIdx)', shuffleFreqIpsi(:));
        shuffCorrCont(i) = corr(peakFreqBase(contIdx)', shuffleFreqCont(:));
    end
    %%
    bins = -1:.025:1;
    hIpsi = histc(shuffCorrIpsi, bins);
    hCont = histc(shuffCorrCont, bins);
    
    pValIpsi = sum(shuffCorrIpsi>ipsiCorr) / nShuffle;
    pValCont = sum(shuffCorrCont>contCorr) / nShuffle;
    
    figure('Name', sprintf('%s-%d-%d', animal, day, epoch));
    subplot(211);
    line(bins, smoothn(hIpsi,2), 'color', 'k', 'linewidth', 2);
    line(repmat(ipsiCorr,1,2), [0 10], 'color', 'r', 'linewidth', 2);
    title( sprintf('Ipsilateral p-Value %0.3f', pValIpsi )); 
     
    subplot(212);
    line(bins, smoothn(hCont,2), 'color', 'k', 'linewidth', 2);   
    line(repmat(contCorr,1,2), [0 10], 'color', 'r', 'linewidth', 2);
    title( sprintf('Contralateral p-Value %0.3f', pValCont )); 
    %%
    contStat(k).corr = contCorr;
    contStat(k).shuff = shuffCorrCont;
    contStat(k).pval = pValCont;
    
    ipsiStat(k).corr = ipsiCorr;
    ipsiStat(k).shuff = shuffCorrIpsi;
    ipsiStat(k).pval = pValIpsi;
    
end