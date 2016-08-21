function dset = dset_add_ref_to_eeg(dset, varargin)

if nargin==1
    error(' REMOVE THIS CALL TO DSET_ADD_REF_TO_EEG');
end


if ~isfield(dset,'ref') || ~isfield(dset, 'eeg')
    error('Required fields missing');
end

filtDat = load('~/src/matlab/thesis/sixtyFilt.mat');
sixtyFilt = filtDat.sixtyFilt;

for i = 1:numel(dset.eeg)
    if (dset.eeg(i).starttime ~= dset.ref.starttime) || numel(dset.ref.data) ~= numel(dset.eeg(i).data)
        error('Reference needs to be resampled');
    end
      
    dset.eeg(i).data = filtfilt(sixtyFilt, 1, dset.eeg(i).data(:) + dset.ref.data(:));
    
end
