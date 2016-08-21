function [eeg_ch loc] = load_exp_eeg_anatomy(edir)

d = load(fullfile(edir, 'eeg_anatomy.mat'));
d = d.eeg_anatomy;

eeg_ch = d(:,1);
loc = d(:,2);