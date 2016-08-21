function process_and_merge_eeg(session_dir)
% depends on fkPreprocessing
% needs to create session_dir/eeg/link to eeg files for fkPreprocessing,
% these will be deleted at the end of this script

mkdir(fullfile(session_dir, 'eeg/'));
eeg_files_cell = get_dir_names(fullfile(session_dir, 'extracted_data/', '*.eeg'));
eeg_files = [];
day = [];
for i=1:length(eeg_files_cell)
    eeg_file = eeg_files_cell{i};
    if isempty(day)
        day = eeg_file(i,end-5:end-4);
    end;
    eeg_files(i,:) = eeg_file';
    cmd = ['ln -s ', fullfile(session_dir, 'extracted_data/'), eeg_files(i,:),' ', fullfile(session_dir, 'eeg/', eeg_files(i,:))];
    system(cmd);
end


process_eeg(session_dir);

end