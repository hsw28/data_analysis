clear;
%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1 1 1 1 2 2 2 2];
day = [18, 22, 23, 24, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3];

win = [-.5 .5];

[hpcRateAll, ctxRateAll] = deal([]);

fprintf('\n\n');
for E = 1%:8

    % LOAD THE DATA
    epoch = sprintf('sleep%d', ep(E));
    edir = sprintf('/data/%s/day%d', base{bId(E)}, day(E));
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));
    fprintf('Loading:%s\t', fullfile(edir, fName));
    mu = load( fullfile(edir, fName) );
    mu = mu.mu;

    fName = sprintf('EEG_HPC_1500_%s.mat', epoch);
    fprintf(', %s\n', fullfile(edir, fName));
    eeg = load( fullfile(edir, fName) );
    eeg = eeg.hpc;

end
%%        

