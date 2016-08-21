function exp_process(edir, varargin)
%
% see also exp_extract
args.extract = 1;
args.define_epochs = 1;
args.downsample_eeg =1;
args.eeg_fs = 750;
args = parseArgs(varargin, args);


already_extracted = exist(fullfile(edir, 'meta.extracted'), 'file');

% ------------------- Extract the Data -------------------%
if ~already_extracted && args.extract
    disp('Files not yet extracted...');
    exp_extract(edir);
else
    disp('extraction skipped');
end

epoch_dirs_created = exist(fullfile(edir, 'meta.epochs_defined'), 'file');

% ------------------- Define the Epochs -------------------%
if ~epoch_dirs_created && args.define_epochs
    disp('Epochs not yet defined, defining them now');
    create_exp_epoch_dirs(edir)    
else
    disp('epoch definitions skipped');
end

eeg_downsampled = exist(fullfile(edir, 'meta.eeg_downsampled'), 'file');
if ~eeg_downsampled && args.downsample_eeg
    disp('EEG not yet downsampled. Downsampling now');
    downsample_eeg(edir, args.eeg_fs);
else
    disp('eeg downsampling skipped');
    
end

disp('Done Processing');
end

function create_exp_epoch_dirs(edir)

    f = define_epochs(edir, 'epoch_file', fullfile(edir, 'epochs.def'));
    tt_dirs = get_dir_names(fullfile(edir, 't*'));
    waitfor(f);
    epochs = load_epochs(edir, 'epoch_file', fullfile(edir, 'epochs.def'));
    for i=1:numel(tt_dirs)
        for e = 1:numel(epochs)
            epoch_dir = fullfile(edir, tt_dirs{i}, epochs{e});
            if ~exist(epoch_dir, 'dir')
                cmd = ['mkdir ', epoch_dir];
                system(cmd);
            end
        end
    end
    
    file = fullfile(edir, 'meta.epochs_defined');
    system(['touch ', file]);
end

function downsample_eeg(edir, fs)
    eeg_files = get_dir_names(fullfile(edir, '*.buf'));
    for i=1:numel(eeg_files)
        in = fullfile(edir, eeg_files{i});
        out = fullfile(edir, [eeg_files{i}(1:4), '.eeg']);
        debuffer_eeg_file(in, out, 'fs', fs);
    end
    
    file = fullfile(edir, 'meta.eeg_downsampled');
    system(['touch ', file]);
end