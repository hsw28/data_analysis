clear;
%{'spl11', 'spl11', 'spl11'}, [15 12 11], [2 1 2];
base = {'gh-rsc1', 'gh-rsc2', 'spl11'};
bId = [1 1 1 1 2 2 2 2];
day = [18, 22, 23, 24, 22, 24, 25, 26];
ep = [3, 1, 1, 2, 3, 3, 3, 3];


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

ctxTrigHpc = [];
hpcTrigCtx = [];
fprintf('\n');


for E = 1:numel(mu)  
    fprintf('%d ', E);
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg{E}.ripple, eeg{E}.rippleEnv, eeg{E}.ts);
    muBursts = find_mua_bursts(mu{E});
    cFrames = find_ctx_frames(mu{E});
    nBurst = size(muBursts,1);
       
    durFilt = [.1 2.5]; 
    
    cFrames = durationFilter(cFrames, durFilt);
    muBursts = durationFilter(muBursts, durFilt);
    
    b = inseg(muBursts, cFrames, 'partial');
    
    ctxEvent = cFrames(b,1);
    hpcEvent = muBursts(:,1);
    
    [cth, ts] = meanTriggeredEvent(ctxEvent, hpcEvent, -.5:.01:.5 );
    [htc, ts] = meanTriggeredEvent(hpcEvent, ctxEvent, -.5:.01:.5 );
   
    ctxTrigHpc = [ctxTrigHpc; cth];
    hpcTrigCtx = [hpcTrigCtx; htc];
end

fprintf(' DONE!\n');
beep;
%%
[l, f, ax] = plotAverages(ts, smoothn(mean( ctxTrigHpc),1), ts, smoothn(mean(hpcTrigCtx),1) );

legend(l, {'CTX Trig HPC', 'HPC Trig CTX'});
title('Event Start Triggered Starts');

%% %%%%%%%%%%%%%%   FRAME END TRIGGERED FRAME END    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except mu eeg

ctxTrigHpc = [];
hpcTrigCtx = [];
fprintf('\n');


for E = 1:numel(mu) 
    
    fprintf('%d ', E);
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg{E}.ripple, eeg{E}.rippleEnv, eeg{E}.ts);
    muBursts = find_mua_bursts(mu{E});
    cFrames = find_ctx_frames(mu{E});
    nBurst = size(muBursts,1);
       
    durFilt = [.1 2.5]; 
    
    cFrames = durationFilter(cFrames, durFilt);
    muBursts = durationFilter(muBursts, durFilt);
    
    b = inseg(muBursts, cFrames, 'partial');
    
    ctxEvent = cFrames(b,2);
    hpcEvent = muBursts(:,2);
    
    [cth, ts] = meanTriggeredEvent(ctxEvent, hpcEvent, -.5:.01:.5 );
    [htc, ts] = meanTriggeredEvent(hpcEvent, ctxEvent, -.5:.01:.5 );
   
    ctxTrigHpc = [ctxTrigHpc; cth];
    hpcTrigCtx = [hpcTrigCtx; htc];
    
end

fprintf('\tDONE!\n');
beep;
%%
[l, f, ax] = plotAverages(ts, smoothn(mean( ctxTrigHpc),1), ts, smoothn(mean(hpcTrigCtx),1) );

legend(l, {'CTX Trig HPC', 'HPC Trig CTX'});
title('Event END Triggered ENDS');

%% %%%%%%%%%%%%%%    Example of Frame overlap   %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except mu eeg

ctxTrigHpc = [];
hpcTrigCtx = [];
fprintf('\n');


E = 1;    

% DETECT SWS, Ripples, and MU-Bursts
[sws, ripTs] = classify_sleep(eeg{E}.ripple, eeg{E}.rippleEnv, eeg{E}.ts);
muBursts = find_mua_bursts(mu{E});
cFrames = find_ctx_frames(mu{E});
nBurst = size(muBursts,1);

durFilt = [.05 2.5];

cFrames = durationFilter(cFrames, durFilt);
muBursts = durationFilter(muBursts, durFilt);

b = inseg(muBursts, cFrames, 'partial');


%%
close all;

figure('Position', [0 300 1280, 400]);
ax(1) = axes('Position', [.05 .55 .9 .4],'NextPlot', 'add');
ax(2) = axes('Position', [.05 .075 .9 .4],'NextPlot', 'add');


line_browser(mu{E}.ts, mu{E}.hpc, 'color', 'b','Parent', ax(1));
line_browser(mu{E}.ts, mu{E}.ctx, 'color', 'r','Parent', ax(2));

seg_plot(muBursts, 'Axis', ax(1), 'Height', 1000, 'Alpha', .6, 'FaceColor', 'k');
seg_plot(cFrames(b,:),'Axis', ax(2),'Height', 1000, 'Alpha', .6, 'FaceColor', 'k'); 


linkaxes(ax,'x');
zoom xon







%% %%%%%%%%%%%%%%   FRAME START TRIGGERED ON/OFF    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except mu eeg

ctxTrigHpc = [];
hpcTrigCtx = [];
fprintf('\n');


for E = 1:numel(mu)  
    fprintf('%d ', E);
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg{E}.ripple, eeg{E}.rippleEnv, eeg{E}.ts);
    muBursts = find_mua_bursts(mu{E});
    cFrames = find_ctx_frames(mu{E});
    nBurst = size(muBursts,1);
       
    durFilt = [.1 2.5]; 
    
    cFrames = durationFilter(cFrames, durFilt);
    muBursts = durationFilter(muBursts, durFilt);
    
    b = inseg(muBursts, cFrames, 'partial');
    
    ctxEvent = cFrames(b,1);
    hpcEvent = muBursts(:,1);
    
    ctxSig = seg2binary(cFrames(b,:), mu{E}.ts);
    hpcSig = seg2binary(muBursts, mu{E}.ts);
    
    [cth, ~, ts] = meanTriggeredSignal(ctxEvent, mu{E}.ts, hpcSig, [-.5 .5] );
    [htc, ~,  ts] = meanTriggeredSignal(hpcEvent, mu{E}.ts, ctxSig, [-.5 .5] );
   
    ctxTrigHpc = [ctxTrigHpc; cth];
    hpcTrigCtx = [hpcTrigCtx; htc];
end

fprintf('\tDONE!\n');
beep;
%%
[l, f, ax] = plotAverages(ts, mean( ctxTrigHpc), ts, mean(hpcTrigCtx) );

legend(l, {'CTX-Frame Trig HPC-Event', 'HPC-Frame Trig CTX-Event'});
title('Frame START Triggered ON/OFF');

%% %%%%%%%%%%%%%%   FRAME END TRIGGERED ON/OFF    %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clearvars -except mu eeg

ctxTrigHpc = [];
hpcTrigCtx = [];
fprintf('\n');
xc = [];

for E = 1:numel(mu)  
    fprintf('%d ', E);
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg{E}.ripple, eeg{E}.rippleEnv, eeg{E}.ts);
    muBursts = find_mua_bursts(mu{E});
    cFrames = find_ctx_frames(mu{E});
    nBurst = size(muBursts,1);
       
    durFilt = [.1 2.5]; 
    
    cFrames = durationFilter(cFrames, durFilt);
    muBursts = durationFilter(muBursts, durFilt);
    
    b = inseg(muBursts, cFrames, 'partial');
    
    ctxEvent = cFrames(b,2);
    hpcEvent = muBursts(:,2);
    
    ctxSig = seg2binary(cFrames(b,:), mu{E}.ts);
    hpcSig = seg2binary(muBursts, mu{E}.ts);
        
    [cth, ~, ts] = meanTriggeredSignal(ctxEvent, mu{E}.ts, hpcSig, [-.5 .5] );
    [htc, ~,  ts] = meanTriggeredSignal(hpcEvent, mu{E}.ts, ctxSig, [-.5 .5] );
   
    ctxTrigHpc = [ctxTrigHpc; cth];
    hpcTrigCtx = [hpcTrigCtx; htc];
end

fprintf('\tDONE!\n');
beep;
%%
[l, f, ax] = plotAverages(ts, mean( ctxTrigHpc), ts, mean(hpcTrigCtx) );

legend(l, {'CTX Trig HPC', 'HPC Trig CTX'});
title('Frame END Triggered EVENT');