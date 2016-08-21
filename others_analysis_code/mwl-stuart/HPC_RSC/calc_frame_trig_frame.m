clearvars -except MultiUnit LFP

win = [-.5 .5];

N = numel(MultiUnit);
Fs = timestamp2fs(LFP{1}.ts);

bins = win(1):.01:win(2);

[hpcFrame, ctxFrame] = deal( nan(N, numel(bins)) );

[hpcMuRate, hpcEvent, ctxMuRate, ctxEvent] = deal( nan(N, 201));

eventLenThold = .125;
for i = 1 : N
    
    fprintf('%d ', i);
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    [sws, ripTs] = classify_sleep(eeg.ripple, eeg.rippleEnv, eeg.ts);
    muBursts = find_mua_bursts(mu);
    cFrames = find_ctx_frames(mu);
    
    % Merge Frames within 50 ms of each other
%     muBursts = merge_frames(muBursts, .05);
%     cFrames = merge_frames(cFrames, .05);

    % Filter MU-Bursts
%     muBursts = durationFilter(muBursts, eventLenThold);
%     cFrames = durationFilter(cFrames, eventLenThold);
    cFrames = durationFilter(cFrames, [0. .1]);
    
    cFrames = merge_frames(cFrames, .1);
%     figure;
%     ksdensity( diff(cFrames,[],2));
    % Trigger on Start of FRAME
    hpcTrig = muBursts(:,1);
    ctxTrig = cFrames(:,1);
    
    
%     muBursts = muBursts( inseg(cFrames, muBursts, 'partial'), :);
%     cFrames = cFrames( inseg(muBursts, cFrames, 'partial'),:);
    
    hpcBinaryFrame = seg2binary( muBursts, mu.ts);
    ctxBinaryFrame = seg2binary( cFrames, mu.ts);
   
    [hpcFrame(i,:), ts1] = meanTriggeredEvent( ctxTrig, hpcTrig, bins);
    [ctxFrame(i,:), ts1] = meanTriggeredEvent( hpcTrig, ctxTrig, bins);
    
    [hpcMuRate(i,:), ts2] = meanTriggeredSignal( ctxTrig, mu.ts, mu.hpc, win);
    [ctxMuRate(i,:), ts2] = meanTriggeredSignal( hpcTrig, mu.ts, mu.ctx, win);
   
    [hpcEvent(i,:), ts3] = meanTriggeredSignal( ctxTrig, mu.ts, hpcBinaryFrame, win);
    [ctxEvent(i,:), ts3] = meanTriggeredSignal( hpcTrig, mu.ts, ctxBinaryFrame, win);

end
fprintf('DONE!\n'); beep;
%%

[l, f, ax] = plotAverages(ts1, smoothn(nanmean(hpcFrame), 1.5, 'correct', 1), ts1, smoothn(nanmean(ctxFrame),1.5, 'correct', 1));
set(ax,'FontSize', 14);

title('HPC/RSC Frame Start Time Relationship');
legend(l, {'HPC Start - RSC Trig', 'RSC Start - HPC Trig'}, 'location', 'southeast');
set(f,'Position', [300 400 800 300]);
set(ax,'Position', [.1 .15 .8 .75]);
%%
plot2svg('/data/HPC_RSC/frame_start_trig_frame_starts.svg',gcf);

[l, f, ax] = plotAverages(ts2, nanmean(hpcMuRate), ts2, nanmean(ctxMuRate));
set(ax,'FontSize', 14);

title('Mean MU Rate Triggered on Local Frame Starts');
legend(l, {'HPC Rate - RSC Trig', 'RSC Rate - HPC Trig'});
set(f,'Position', [350 350 800 300]);
set(ax,'Position', [.1 .15 .8 .75]);

plot2svg('/data/HPC_RSC/frame_start_trig_mu_rate.svg',gcf);

[l, f, ax] = plotAverages(ts3, smoothn(nanmean(hpcEvent), 1.5, 'correct', 1), ts3, smoothn(nanmean(ctxEvent), 1.5, 'correct', 1));
set(ax,'FontSize', 14);

title('Mean Frame State Trig on Complementary Frame Start');
legend(l, {'HPC Frame - RSC Trig', 'RSC Frame - HPC Trig'}, 'Location', 'southeast');
set(f,'Position', [400 300 800 300]);
set(ax,'Position', [.1 .15 .8 .75]);
plot2svg('/data/HPC_RSC/frame_start_trig_binary_event.svg',gcf);


