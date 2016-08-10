function eeg = jp_import_eeg(edir)
    
    if ~exist(edir,'dir')
        warning('%s directory does not exist', edir);
        eeg = [];
        return;
    end
    
    eegFile = fullfile(edir, 'eeg.mat');
    
    if ~exist(eegFile,'file')
        warning('%s file does not exist', eegFile);
        eeg = [];
        return;
    end
    
    fprintf('Loading EEG from:%s\n', edir);
    tmp = load(eegFile);
    eeg = tmp.eeg;
    
end