function import_raw_data(edir)
if ~exist(edir,'dir')
    error('The specified directory:%s does not exist!', edir);
end
exp_extract(edir);
%save_epochs
exp_save_eeg_mat(edir);
end