function replace_pos_file(session_dir)
epochs = load_epochs(session_dir);

for e = epochs
    tt_dirs = get_dir_names(fullfile(session_dir, 'epochs', e{1}));
    for i = 1:length(tt_dirs)
        name = tt_dirs{i};
        if name(1) == 't'
            cmd = ['rm ', fullfile(session_dir, 'epochs', e{1}, name, 'temp_pos.p')];
            system(cmd);
            cmd = ['ln -s ', fullfile(session_dir, 'epochs', e{1}, 'position.p'), ' ', fullfile(session_dir, 'epochs', e{1}, name, 'position.p')];
            system(cmd);
        end
    end
end