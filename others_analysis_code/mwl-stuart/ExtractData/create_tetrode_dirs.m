function create_tetrode_dirs(session_dir)
% creates a directory under session_dir/epochs/<epoch_dir>/ for each
% tetrode under session_dir/extracted_data
epochs = load_epochs(session_dir);
tt_files_cell = get_dir_names(fullfile(session_dir, 'extracted_data/', '*.tt'));
tt_files = [];
day = [];
for i=1:length(tt_files_cell)
    tt_file = tt_files_cell{i};
    if isempty(day)
        day = tt_file(i,1:4);
    end;
    tt_files(i,:) = tt_file(5:end-3)';
end


for e=1:length(epochs)
    epoch_name = epochs{e};
    for f=1:length(tt_files)
        %disp(['Making dir: ', tt_files(f,:)]); 
        mkdir(fullfile(session_dir, 'epochs', epoch_name, tt_files(f,:)));    
        % create symbolic link to .tt file
        cmd = ['ln -s ', fullfile(session_dir, 'extracted_data/'), day, tt_files(f,:), '.tt ', fullfile(session_dir, 'epochs', epoch_name, tt_files(f,:), '/'), tt_files(f,:), '.tt'];
        system(cmd);
        cmd = ['ln -s ', fullfile(session_dir, 'extracted_data/'), day, tt_files(f,:), '.pxyabw ', fullfile(session_dir, 'epochs', epoch_name, tt_files(f,:), '/'), tt_files(f,:), '.pxyabw'];
        system(cmd);
        cmd = ['ln -s ', fullfile(session_dir, 'extracted_data/', 'temp_pos.p'),' ', fullfile(session_dir, 'epochs', epoch_name, tt_files(f,:), 'temp_pos.p')];
        system(cmd);
        cmd = ['mkdir ', fullfile(session_dir, 'epochs', epoch_name, tt_files(f,:), epoch_name)];
        system(cmd);
        %%% This last link is created b/c xclust likes to save the clusters
        %%% under a folder that shares the same name as the epoch. This
        %%% link makes it so the clusters are saved under the same folder
        %%% as the .tt and .pxyabw file
    end;
end;