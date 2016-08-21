function [ref idx] = dset_resample_reference(eeg, ref)



tsRef = generate_timestamps(ref.starttime, numel(ref.data), ref.fs);
tsEeg = generate_timestamps(eeg(1).starttime, numel(eeg(1).data), eeg(1).fs);


newRef = interp1(tsRef, ref.data, tsEeg);


ref.starttime = eeg(1).starttime;
ref.fs = eeg(1).fs;
ref.data = newRef;
   
badIdx = isnan(ref.data);

ref.data(badIdx) = 0;

end