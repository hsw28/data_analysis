function process_eeg_into_epochs(session_dir, fs_new)
% Opens .eeg files under session_dir/extracted_data, 
% down samples them to  fs_new
% splits the eeg based upon epoch 
% save a new .eeg file under session_dir/epoch/<epoch_name>/
%
% depends on fkPreprocessing
% needs to create session_dir/eeg/link to eeg files for fkPreprocessing,
% these will be deleted at the end of this script

disp('Creating file structure for fkPreprocessing...');
mkdir(fullfile(session_dir, 'eeg/'));
eeg_files_cell = get_dir_names(fullfile(session_dir, 'extracted_data/', '*.eeg'));
eeg_files = [];
day = [];
for i=1:length(eeg_files_cell)
    eeg_file = eeg_files_cell{i};
    if isempty(day)
        day = eeg_file(i,end-5:end-4);
    end;
    eeg_files(i,:) = eeg_file'; %#ok
    cmd = ['ln -s ', fullfile(session_dir, 'extracted_data/'), eeg_files(i,:),' ', fullfile(session_dir, 'eeg/', eeg_files(i,:))];
    system(cmd);
end
disp('Running fkPreProcessing::Process_eeg');
process_eeg(session_dir,fs_new);
disp('Cleaning up!');
e_names = load_epochs(session_dir);

for i = 1:length(e_names)
    name = e_names{i};
    cmd = ['mv ', fullfile(session_dir, 'epochs', name, 'eeg/'), '*.eeg ', fullfile(session_dir, 'epochs', name, '/')];
    system(cmd);
    cmd = ['rmdir ', fullfile(session_dir, 'epochs', name, 'eeg/')];
    system(cmd);
end
cmd = ['rm -rf ', fullfile(session_dir, 'eeg/')];
system(cmd);