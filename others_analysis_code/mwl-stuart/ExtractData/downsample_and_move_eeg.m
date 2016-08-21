function downsample_and_move_eeg(session_dir)
% uses fkPreprocessing.process_eeg to down sample and de buffer the eeg
% files. The files are saved according the fkPreprocessing guidlines which


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

epoch_dir = fullfile(session_dir, 'epochs/');
d = dir(epoch_dir);

for i = 1:length(d) % make dirs for process_eeg
    if d(i).isdir && i>2
        cmd = ['mkdir ', fullfile(epoch_dir, d(i).name, 'eeg')];
        system(cmd);
    end
end


process_eeg(session_dir);

epoch_dir = fullfile(session_dir, 'epochs/');
d = dir(epoch_dir);
for i = 1:length(d)
    if d(i).isdir && i>2
        cmd = ['mv ', fullfile(epoch_dir, d(i).name, 'eeg/*.eeg'), ' ',fullfile(epoch_dir, d(i).name)];
        system(cmd);
        cmd = ['rmdir ', fullfile(epoch_dir, d(i).name, 'eeg')];
        system(cmd);
    end
end
cmd = ['rm ', fullfile(session_dir, 'eeg', '*.eeg')];
system(cmd);
cmd = ['rmdir ', fullfile(session_dir, 'eeg')] ;
system(cmd);
cmd = ['rm ' fullfile(session_dir, '*.log')];
system(cmd);

end