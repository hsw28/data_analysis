function create_epoch_dirs(session_dir)
% creates subdirs under session_dir/epochs/ requires the presence of
% epoch.def under session_dir/epochs/ if this file does not exist then it
% is created (creation of this file requires user input), 
% This requires MWLIO

answer = 'Yes';
if exist(fullfile(session_dir, 'epochs', 'epochs.def'))
    answer = questdlg('Epoch file exists, overwrite?');
end
if strcmp(answer, 'Yes');
    define_epochs(fullfile(session_dir, 'epochs'));

    while ~exist(fullfile(session_dir, 'epochs/epochs.def'), 'file')
        pause(1);
    end
end

epochs = load_epochs(fullfile(session_dir, 'epochs'));

for i=1:length(epochs)
    if ~exist(fullfile(session_dir, 'epochs', epochs{i}, '/'), 'dir');
        cmd = ['mkdir ', fullfile(session_dir, 'epochs', epochs{i})];
        system(cmd);
    else
        disp([session_dir, '/epochs/',epochs{i}, '/ already exists, Creation aborted!']);
    end
end

end