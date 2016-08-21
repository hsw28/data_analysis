clearvars -except MultiUnit LFP

win = [-.25 .5];


N = numel(MultiUnit);
Fs = timestamp2fs(LFP{1}.ts);

[hpcRateCorrH, ctxRateCorrH] = deal( nan(N, 151) );
[hpcRateCorrL, ctxRateCorrL] = deal( nan(N, 151) );

eventLenThold = [.2 .4 ]; %<============
corrThold = .25;

c = {};
for i = 1 : N
    
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    % DETECT SWS, Ripples, and MU-Bursts
    [sws, ripTs] = classify_sleep(eeg.ripple, eeg.rippleEnv, eeg.ts);
    muBursts = find_mua_bursts(mu);
    cFrames = find_ctx_frames(mu);
     
%     events = seg_and(muBursts, cFrames);
    events = muBursts;
    events = durationFilter(events, eventLenThold);
  
    nEvent = size(events,1);
    

    %
    if nEvent < 2
        continue;
    end
    
    % Classify burst by SWS state
    %     swsIdx = inseg(sws, muBursts, 'partial');
    muPkIdxHC = [];
    muPkIdxLC = [];
    
    trigIdxH = [];
    trigIdxL = [];
    
    c{i} = zeros(nEvent,1);
    for iEvent = 1:nEvent
        
        b = events(iEvent,:);
        
        startIdx = find( b(1) == mu.ts, 1, 'first');
        
        tmpIdx = mu.ts>=b(1) & mu.ts <= b(2);
        r = mu.hpc( tmpIdx );
        
        [~, pk] = findpeaks(r); % <------- FIRST LOCAL MAX
        
        if numel(pk)<1
            continue
        end
        pk = pk + startIdx -1;
        
        
        c{i}(iEvent) = corr( mu.hpc(tmpIdx)', mu.ctx(tmpIdx)' );
        
        if c{i}(iEvent) <= -1 * corrThold
            trigIdxL = [trigIdxL, pk(1)];
        elseif c{i}(iEvent) >= corrThold
            trigIdxH = [trigIdxH, pk(1)];
        end
                    
    end
     
    
    fprintf('%d - H:%d L:%d\n', i, numel(trigIdxH), numel(trigIdxL) );
    
    [hpcRateCorrH(i,:), ts] = meanTriggeredSignal( mu.ts( trigIdxH ), mu.ts, mu.hpc, win);
    [ctxRateCorrH(i,:), ts]= meanTriggeredSignal( mu.ts( trigIdxH ), mu.ts, mu.ctx, win);
    
    [hpcRateCorrL(i,:), ts] = meanTriggeredSignal( mu.ts( trigIdxL ), mu.ts, mu.hpc, win);
    [ctxRateCorrL(i,:), ts]= meanTriggeredSignal( mu.ts( trigIdxL ), mu.ts, mu.ctx, win);
    
end
fprintf('DONE!\n');
%%
f = figure;
ax = [];

ax(1) = subplot(211);
line(ts, nanmean(hpcRateCorrH), 'color', 'r');
line(ts, nanmean(hpcRateCorrL), 'color', 'k');

legend('High Corr', 'Low Corr');
set(f,'Position', [300 500 800 300])

ax(2) = subplot(212);
line(ts, nanmean(ctxRateCorrH), 'color', 'r');
line(ts, nanmean(ctxRateCorrL), 'color', 'k');

legend('High Corr', 'Low Corr');
set(f,'Position', [400 450 800 300]);



set(ax,'XLim', [-.25 .5]);
if numel(eventLenThold)==2
    title( ax, sprintf('Event Dur: %d to %d ms', eventLenThold * 1000), 'fontSize', 16);
else
    title( ax, sprintf('Event Dur: %d to Inf', eventLenThold * 1000), 'fontSize', 16);
end

% plot2svg('/data/HPC_RSC/frame_start_triggered)mu_rate.svg',gcf);

