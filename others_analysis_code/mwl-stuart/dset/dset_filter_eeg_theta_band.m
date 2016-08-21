function dset = dset_filter_eeg_theta_band(dset, varargin)
    
    tFilt = getfilter(dset.eeg(1).fs, 'theta', 'win');
    
    validSeg = logical2seg( isfinite( dset.eeg(1).data) );

    data = cell2mat({dset.eeg.data});
    
    if size(validSeg,1) > 1
        fprintf('Invalid segments in the EEG skipping them');
    end
    for iSeg = 1:size(validSeg, 1)
           
        idx = validSeg(iSeg,1):validSeg(iSeg,2);
           
        data(idx, :) = filtfilt(tFilt, 1, data(idx,:));
    end
    
    for i = 1:numel(dset.eeg)
        dset.eeg(i).thetaband = data(:,i);
    end

end