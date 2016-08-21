function dset = dset_filter_eeg_sharpwave(dset, varargin)
    
    swFilt = getfilter(dset.eeg(1).fs, 'sharpwave', 'win');
       
    validSeg = logical2seg( isfinite( dset.eeg(1).data) );
    
    data = cell2mat({dset.eeg.data});
    
    if size(validSeg,1) > 1
        fprintf('Skipping invalid segments in the EEG.\n');
    end
    
    for iSeg = 1:size(validSeg, 1)
           
        idx = validSeg(iSeg,1):validSeg(iSeg,2);
           
        data(idx, :) = filtfilt(swFilt, 1, data(idx,:));
    end
    
    for i = 1:numel(dset.eeg)
        dset.eeg(i).sharpwaveBand = data(:,i);
    end

end