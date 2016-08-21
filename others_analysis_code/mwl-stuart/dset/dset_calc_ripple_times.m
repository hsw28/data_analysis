function [dset, peakIdx, winIdx] = dset_calc_ripple_times(dset, varargin)
    
    args.high_thold = 4;
    args.low_thold =  2;
    args.min_burst_len = .025;
   
    args = parseArgs(varargin, args);
   
    chPeak = {};
    chWin = {};
    for ch = 1:3

        % FILTER EEG - if not yet filtered
        if ~isfield(dset.eeg(ch), 'rippleband')
            dset = dset_filter_eeg_ripple_band(dset);
        end

        % construct indexing vector
        nSamp = numel(dset.eeg(ch).data);
        ind = 1:nSamp;

        % only define and detect ripples using CHAN #1
        ripLfp = dset.eeg(ch).rippleband;
        ripHilbert = nan .* ripLfp;

        validSeg = logical2seg( isfinite( ripLfp ) );

        for iSeg = 1:size(validSeg, 1)

            idx = validSeg(iSeg,1):validSeg(iSeg,2);
            ripHilbert(idx) = abs( hilbert( ripLfp(idx) ) );

        end

        % Get envelope of signal and find bursts

        tHigh = args.high_thold .* nanstd( ripHilbert );
        tLow = args.low_thold .* nanstd( ripHilbert);
        
        high_seg = logical2seg( ind, ripHilbert >= args.high_thold * nanstd(ripHilbert) );
        low_seg = logical2seg( ind, ripHilbert >= args.low_thold * nanstd(ripHilbert) );

        % which low segments contain high segments
        [~, n] = inseg(low_seg, high_seg);

        % define these low segments as the bursts
        winIdx = low_seg( logical(n), :);

        winIdx = winIdx( diff(winIdx,[],2) >= args.min_burst_len * dset.eeg(1).fs, : );

        
        % find the index of the peak of the rippleband lfp within the window
        findMaxEnvFunc = @(x,y) max( ripLfp(x:y) );

        % select the sample in the burst with the largest envelope as the peak
        [~, peakIdx] = arrayfun(findMaxEnvFunc, winIdx(:,1), winIdx(:,2) );

        % correct peakIdx offset
        peakIdx = peakIdx + winIdx(:,1) - 1;

        % remove peaks that are within 500 samples of the beginning or the end
        % of the recording
        validPeaks = peakIdx > 500 & peakIdx < (nSamp - 500);

        % remove invalid peaks
        peakIdx = peakIdx(validPeaks);
        winIdx = winIdx(validPeaks,:);

        chPeak{ch} = peakIdx;
        chWin{ch} = winIdx;
    end
    
    ripIdx = inseg( chWin{2}, chWin{1}, 'partial' ) & inseg( chWin{3}, chWin{1}, 'partial');
    
    
    dset.ripples.peakIdx = chPeak{1}(ripIdx);
    dset.ripples.eventOnOffIdx = chWin{1}(ripIdx,:);    
    dset.ripples.chPeakIdx = chPeak;
    dset.ripples.chEventOnOffIdx = chWin;
    
    
end