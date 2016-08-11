function [eeg_r, radiatum_r] = get_rat3_eeg()
% navigate to dayXX/eeg/ then run this script

add_ref = true;
resample = 0.2;

file_list = dir();
file_list = file_list(3:end); % the first two elements are '.' and '..'
n_file = numel(file_list);

eeg = [];

[tmp1,tmp2,eeg1] = gh_debuffer(file_list(1).name,'chans',[1:6,8]);
clear tmp1;
clear tmp2;
eeg1.data = double(eeg1.data);
eeg1 = contresamp(eeg1,'resample',resample); % bring samplerate to 
eeg1.chanlabels = {'1','2','3','4','5','6','ref'};
ref = contchans(eeg1,'chans',7);
eeg1 = contchans(eeg1,'chans',[1:4,6]); % drop T05; it's not in the brain

[tmp1,tmp2,eeg2] = gh_debuffer(file_list(2).name,'chans',[1:6]);
clear tmp1;
clear tmp2;
eeg2.data = double(eeg2.data);
eeg2 = contresamp(eeg2,'resample',resample);
eeg2.chanlabels = {'7','8','9','10','11','12'};

eeg = contcombine(eeg1,eeg2);
clear eeg1;
clear eeg2;

[tmp1, tmp2, eeg3] = gh_debuffer(file_list(3).name,'chans',[1:7]);
clear tmp1;
clear tmp2;
eeg3.data = double(eeg3.data);
eeg3 = contresamp(eeg3,'resample',resample);
eeg3.chanlabels = {'16','17','18','13','14','15','R3'};
radiatum_eeg = contchans(eeg3,'chans',7);
eeg3 = contchans(eeg3,'chans',[1:6]);
eeg = contcombine(eeg,eeg3);

if(add_ref)
    tw = [max(eeg.tstart,ref.tstart), min(eeg.tend,ref.tend)];
    eeg = contwin(eeg,tw);
    ref = contwin(ref,tw);
    eeg.data = eeg.data + repmat(ref.data,1,17);
end

eeg_r = prep_eeg_for_regress(eeg);
radiatum_r = prep_eeg_for_regress(radiatum_eeg);