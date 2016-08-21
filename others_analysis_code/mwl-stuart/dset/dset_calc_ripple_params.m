function [dset, data] = dset_calc_ripple_params(dset)
    
    fprintf('Calculating ripple times\n');
    dset = dset_calc_ripple_times(dset);    
    fprintf('Calculating ripple spectra\n');
    dset = dset_calc_ripple_spectrum(dset);
    
    fprintf('Filtering for Sharp-Waves\n');
    dset = dset_filter_eeg_sharpwave(dset);

    data = dset.ripples;
%     data.rips = dset.ripples.rip;
%     data.spect = dset.ripples.spect;
%     data.spectW = dset.ripples.spectW;
%     data.f = dset.ripples.f;
%     data.peakTs = dset.ripples.peakTs;
%     data.peakFr = dset.ripples.peakFreq;
%     data.window = w;
    w = bsxfun(@plus, data.peakIdx, data.window);
    data.fs = dset.eeg(1).fs;
    for i = 1:3
%          data.raw{i} = dset.eeg(i).data(w);
        data.sw{i} = dset.eeg(i).sharpwaveBand(w);
        instRippleFreq = calc_inst_freq(dset.eeg(i).rippleband, dset.eeg(i).fs);
        data.instFreq{i} = instRippleFreq(w);
    end
    %data.raw{2} = dset.eeg(2).data(w);
    %data.raw{3} = dset.eeg(3).data(w);
    
    
    
    data.description = dset_get_description_string(dset);
    fprintf('Calculating ripple mean frequency\n');
    data.meanFreq = dset_calc_ripple_mean_freq(dset);
    
    %data = orderfields(data);
    data = orderfields(data, ...
       {'description','fs', 'raw', 'rip', 'sw', 'window', 'peakIdx',...
        'eventOnOffIdx', 'meanFreq', 'instFreq', 'spec', 'chPeakIdx', 'chEventOnOffIdx'} );

    dset.ripples = data;

end