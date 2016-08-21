clear;
%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2'};
bId = [1 1 1 1 1, 2 2 2 2];
day = [18, 22, 23, 24, 28, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3, 3];

C = [];
H = [];
hpcIPI = [];
ctxIPI = [];
fprintf('\n\n');

for E = 1:9
    
    % LOAD THE DATA
%     epoch = sprintf('sleep%d', ep(E));
    epoch = 'run';
    edir = sprintf('/data/%s/day%d', base{bId(E)}, day(E));

    fName = sprintf('EEG_HPC_1500_%s.mat', epoch);
    fprintf('Loading:%s\n', fullfile(edir, fName));
    eeg = load( fullfile(edir, fName) );
    hpc = eeg.hpc;
    
    if isfield(hpc, 'data');
        fprintf('Filtering for ripples\n');
        rfilt = getfilter(1500, 'ripple', 'win');
        hpc.ripple = filtfilt(rfilt, 1, hpc.data);
        hpc.rippleEnv = abs(hilbert(hpc.ripple));
        hpc.lfp = hpc.data;
        hpc = rmfield(hpc, 'data');

    elseif ~isfield(hpc, 'rippleEnv');
        fprintf('Computing ripple env\n');
        hpc.rippleEnv = abs(hilbert(hpc.ripple));
     
        
    else
        fprintf('File already fixed\n');
    end
    
    save( fullfile(edir, fName), 'hpc');

end