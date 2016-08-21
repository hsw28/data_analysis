function process_dataset(baseDir, MIN_VEL, MIN_AMP, MIN_WIDTH)
%% Check input arguments
if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must be a string and valid directory');
end

if ~isscalar(MIN_VEL) || ~isnumeric(MIN_VEL)
    error('MIN_VEL must be a numeric scalar');
end

if ~isscalar(MIN_AMP) || ~isnumeric(MIN_AMP)
    error('MIN_AMP must be a numeric scalar');
end

if ~isscalar(MIN_WIDTH) || ~isnumeric(MIN_WIDTH)
    error('MIN_WIDTH must be a numeric scalar');
end
%% Start processing

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir');
    fprintf('Creating:%s\n', klustDir);
    mkdir(klustDir);
end

% If the dataset files don't exist then load the waveforms from the tt
% files, process the waveforms and then save the dataset files
if ~exist( fullfile(klustDir, 'dataset_4ch.mat'), 'file') || ...
  ~exist( fullfile(klustDir, 'dataset_1ch.mat'), 'file')

    % load the waveform files from disk
    [ts, wf, ttList] = load_all_tt_waveforms_prefilter( baseDir, MIN_VEL, MIN_AMP, MIN_WIDTH );
 
    %Save dataset files
    create_dataset_file(baseDir, 4, ts, wf, ttList, MIN_VEL, MIN_AMP, MIN_WIDTH);
    create_dataset_file(baseDir, 1, ts, wf, ttList, MIN_VEL, MIN_AMP, MIN_WIDTH);
    
end

end
