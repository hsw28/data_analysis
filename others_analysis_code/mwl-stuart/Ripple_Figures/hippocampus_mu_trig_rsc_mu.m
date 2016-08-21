clear;
base = {'gh-rsc1', 'gh-rsc2'};
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
%%

clearvars -except mu eeg

thold = [.1 .4];
win = [-.25 .5];

hpcRateAll = [];
ctxRateAll = [];
fprintf('\n');

for E = 1:numel(mu)  
    
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg{E}.ripple, eeg{E}.rippleEnv, eeg{E}.ts);
    muBursts = find_mua_bursts(mu{E});
    cFrames = find_ctx_frames(mu{E});
    nBurstPre = size(muBursts,1);

    b = inseg(cFrames, muBursts, 'partial');
    muBursts = muBursts(b,:);
    
    muBursts = durationFilter(muBursts, thold);
    nBurst = size(muBursts,1);
    
    %     muBursts = seg_and(muBursts, cFrames);
    fprintf('Keeping %d of %d MU-Bursts\n', nBurstPre, nBurst); 

    
    if nBurst < 2
        continue;
    end

    % Classify burst by SWS state
    swsIdx = inseg(sws, muBursts, 'partial');

    muPkIdx = [];

    for i = 1:nBurst
        
       b = muBursts(i,:);

       startIdx = find( b(1) == mu{E}.ts, 1, 'first');

       r = mu{E}.hpc( mu{E}.ts>=b(1) & mu{E}.ts <= b(2) );

       [~, pk] = findpeaks(r); % <------- FIRST LOCAL MAX
       
       if numel(pk)<1
           continue
       end
       pk = pk + startIdx -1;
       muPkIdx = [muPkIdx, pk(1)];  %#ok
       
    end    
    
    [mHpc, ~, ts, sampHpc] = meanTriggeredSignal( mu{E}.ts( muPkIdx ), mu{E}.ts, mu{E}.hpc, win);
    [mCtx, ~, ts2, sampCtx]= meanTriggeredSignal( mu{E}.ts( muPkIdx ), mu{E}.ts, mu{E}.ctx, win);
     
    hpcRateAll = [hpcRateAll; mHpc];
    ctxRateAll = [ctxRateAll; mCtx];   
         
end

fprintf('\n\t\t\tDONE!\n');
beep;
%%

close all;
[l, f, ax] = plotAverages(ts, mean(hpcRateAll), ts2, mean(ctxRateAll) );

legend(l, {'Hippocampus', 'Retrosplenial'});
set(f,'Position', [300 500 800 300]);
set(ax,'Position', [.1 .15 .8 .75]);

if numel(thold)==2
   title( ax, sprintf('Event Dur: %d to %dms', thold * 1000), 'fontSize', 16); 
else
   title( ax, sprintf('Event Dur: %d to Inf', thold * 1000), 'fontSize', 16); 
end


fName = sprintf('/data/HPC_RSC/%s_%d_%d_2.svg', 'hippocampus_trig_mean_mu', thold(1)*1000, thold(2)*1000);
% plot2svg(fName, f);




