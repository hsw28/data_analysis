function [eeg, ref, channels] = dset_exp_load_eeg(edir, epoch)

ch = exp_get_preferred_eeg_channels(edir);
[~, anat] = load_exp_eeg_anatomy(edir);

e = load_exp_eeg(edir, epoch);
fs = timestamp2fs(e.ts);
channels = [];

for i = 1:3
    eeg(i).data = e.data(:,ch(i));
    eeg(i).fs = fs;
    eeg(i).starttime = e.ts(1);
    if strcmp(anat{ch(i)}, 'lCA1')
        eeg(i).area = 'CA1';
        eeg(i).hemisphere = 'left';
    elseif strcmp(anat{ch(i)}, 'rCA1')
        eeg(i).area = 'CA1';
        eeg(i).hemisphere = 'right';
    else
        eeg(i).area = anat{ch(i)};
        eeg(i).hemisphere = 'unknown';
    end
    eeg(i).tet = 'unknown';
end

ref = [];
