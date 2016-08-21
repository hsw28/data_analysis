function source_names = get_eeg_signal_source_names(session_dir)
    
    signal_names = load_signal_names(session_dir);
    n_eeg_files = 2; %
    warning('Not detecting number of EEG files, only works with 2 files'); %#ok
    source_names = signal_names(end-15:end,:);
end