function extract_eeg_files(edir)
    files = dir(fullfile(edir, 'eeg*'));
    eeg_f = {files.name};

    disp('Extracting EEG Data');
    for f = eeg_f
        file = f{1};
        ffile = fullfile(edir, file);
        eeg_file = fullfile(edir, [file(1:4), '.buf']);
        
        cmd = ['adextract -eslen80 ', ffile, ' -c -o ', eeg_file];
        system(cmd);
     
        cmd = ['mv ', ffile, ' ', fullfile(edir, 'raw', file)];
        system(cmd);
    end

end