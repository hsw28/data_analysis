function [results] = calc_bilateral_ripple_band_xcorr(epoch)

if ~any( strcmp( epoch, {'sleep', 'run'} ) )
    error('Invalid epoch');
end


eList = dset_list_epochs(epoch);
badList = dset_get_bad_epochs(epoch);

for i = 1:size(eList,1)
    if any( badList == i)
        continue;
    end
    dset = dset_load_all(eList{i,1}, eList{i,2}, eList{i,3});
%    dset = dset_add_ref_to_eeg(dset);
    
    [xcIpsi(:,i) xcCont(:,i)] =  dset_analyze_xcorr_ripple_band(dset,1);
    if ~exist('eeg_fs', 'var')
        eeg_fs = dset.eeg(1).fs;
    end
end

results.xcorrIpsi = xcIpsi;
results.xcorrCont = xcCont;

end