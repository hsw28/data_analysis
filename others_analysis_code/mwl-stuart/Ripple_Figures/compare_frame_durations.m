clear;
%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1,  1,  1,  1,  1,  2,  2,  2,  2];
day = [18, 22, 23, 24, 28, 22, 24, 25, 26];
ep  = [3,  1,  1,  2,  3,  3,  3,  3,  3];


fprintf('\nLOADING THE RAW DATA\n');
mu = {};
eeg = {};

for E = 1:8
    
    % LOAD THE DATA
    epoch = sprintf('sleep%d', ep(E));
    edir = sprintf('/data/%s/day%d', base{bId(E)}, day(E));
    fName = sprintf('MU_HPC_RSC_%s.mat', upper(epoch));
    fprintf('Loading: %s', fName );
    tmp = load( fullfile(edir, fName) );
    mu{E} = tmp.mu;
    
    fName = sprintf('EEG_HPC_1500_%s.mat', epoch);
    fprintf(', %s\n', fName );
    tmp = load( fullfile(edir, fName) );
    eeg{E} = tmp.hpc;
    
end

fprintf('---------------DATA LOADED!---------------\n');
%% %%%%%%%%%%%%%%   FRAME START TRIGGERED FRAME STARTS    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except mu eeg

fprintf('\n');


for E = 1%:numel(mu)  
    fprintf('%d ', E);
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg{E}.ripple, eeg{E}.rippleEnv, eeg{E}.ts);
    muBursts = find_mua_bursts(mu{E});
    cFrames = find_ctx_frames(mu{E});
    nBurst = size(muBursts,1);
       
%     durFilt = [.01 2.5]; 
%     
%     cFrames = durationFilter(cFrames, durFilt);
%     muBursts = durationFilter(muBursts, durFilt);
    
    cLen = diff(cFrames,[],2);
    hLen = diff(muBursts,[],2);
    

end
%%
figure;
plot(cLen(1:end-1), cLen(2:end), '.');
set(gca,'XSCale', 'log', 'YSCale', 'log');

