function dset = dset_calc_ripple_spectrum(dset)

    Fs = dset.eeg(1).fs;

    halfWindow = round( .15 * Fs)  ; %150 ms 
    windowTemplate = -halfWindow:halfWindow;    
    
    window = bsxfun(@plus, windowTemplate, dset.ripples.peakIdx);

    for chanIdx = 1:numel(dset.eeg)
        dset.ripples.raw{chanIdx} = dset.eeg(chanIdx).data(window);
        dset.ripples.rip{chanIdx} = dset.eeg(chanIdx).rippleband(window);
    end
   
    [~, ~, f, ~] = calc_ripple_spectrum( dset.ripples.raw{1}(1,:), Fs);
    
    nFreq = numel(f);
    
    for ii = 1:numel(dset.ripples.rip)
        
        r = dset.ripples.raw{ii};
        nRip = size(r,1);
           
        [pkFr, ~] = deal( zeros(nRip, 1) );
        [sp, wsp]  = deal( zeros(nRip, nFreq) );

        parfor jj = 1:size(r,1)
            % compute the peak fr from the spectrum
            [sp(jj,:), wsp(jj,:), ~, pkFr(jj)]  = calc_ripple_spectrum(r(jj,:), Fs);
            % compute the peak fr from the interpeak interval
%            [~, peakIdx] = findpeaks( r(jj,:) );
            %pkFrM(jj) = mean( 1 ./  (diff(peakIdx) / Fs) );
        end
        
        dset.ripples.spec.spec{ii} = sp;
        dset.ripples.spec.specW{ii} = wsp;
        dset.ripples.spec.peakFreq{ii} = pkFr;
        %dset.ripples.peakFreqM{ii} = pkFrM;
        dset.ripples.window = windowTemplate;
    end
    
    dset.ripples.spec.freqs= f;
    
    dset.ripples = orderfields(dset.ripples);

end

