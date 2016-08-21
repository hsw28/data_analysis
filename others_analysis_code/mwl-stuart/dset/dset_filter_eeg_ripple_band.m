function dset = dset_filter_eeg_ripple_band(dset, varargin)
    
    rFilt = getfilter(dset.eeg(1).fs, 'ripple', 'win');
    
    validSeg = logical2seg( isfinite( dset.eeg(1).data) );
    
    data = cell2mat({dset.eeg.data});
    
    if size(validSeg,1) > 1
        fprintf('Skipping invalid segments in the EEG.\n');
    end
    for iSeg = 1:size(validSeg, 1)
           
        idx = validSeg(iSeg,1):validSeg(iSeg,2);
           
        data(idx, :) = filtfilt(rFilt, 1, data(idx,:));
    end
    
    for i = 1:numel(dset.eeg)
        dset.eeg(i).rippleband = data(:,i);
    end

end