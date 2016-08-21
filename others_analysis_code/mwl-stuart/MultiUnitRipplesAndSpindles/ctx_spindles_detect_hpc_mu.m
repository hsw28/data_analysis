%%
clear;

dsetList = {...
    'gh-rsc1',  'day18',    'sleep3',   'RSC', 26, 15, [-inf inf];...
    'gh-rsc1',  'day22',    'sleep1',    'RSC', 26, 3, [-inf inf];...
    'gh-rsc1',  'day23',    'sleep1',    'RSC', 26, 3, [-inf inf];...
    'gh-rsc1',  'day24',    'sleep1',    'RSC', 26, 3, [-inf inf];...
    'gh-rsc1',  'day25',    'sleep1',    'RSC', 26, 3, [-inf inf];...
    'sg-rat2',  'day26',    'sleep2',   'PFC', 15, 11, [7920 9269];...
    'mr-tec',   'day13',    'sleep3',   'RSC', 10, 1, [-inf inf];...
    'gh-rsc1',  'day18',    'run',   'RSC', 26, 15, [-inf inf];...

};

dsetId = 8;

[animal, day, epoch, ctxAnat, ctxChan, hpcChan, swsTimes] = deal( dsetList{dsetId,:} );
clear dsetList dsetId;
edir = fullfile('/data', animal,day);
%%

%detect_sws(hpcTs, hpcLfp);

eegFileName = ['EEG_',ctxAnat,'_250HZ_', upper(epoch), '.mat'];

if ~exist(fullfile(edir, eegFileName), 'file')
    disp('Loading raw eeg');
    
    e = load_exp_eeg(edir, epoch);
    
    hpcLfp = e.data(:, hpcChan);
    hpcTs = e.ts;
    hpcFs = e.fs;

    newCtxFs = 250;
    N = floor(e.fs/newCtxFs);
    
    ctxLfp = downsample( e.data(:, ctxChan), N );
    ctxTs = downsample( e.ts, N);
    ctxFs = timestamp2fs(ctxTs);
    
    %clear e;
    fprintf('Saving eeg to:%s\n', fullfile(edir, eegFileName));
    save(fullfile(edir, eegFileName), 'hpcLfp', 'hpcTs', 'hpcFs', 'ctxLfp', 'ctxTs', 'ctxFs');
else
    disp('Loading pre-downsampled eeg');
    load(fullfile(edir, eegFileName));
end
clear eegFileName ctxChan hpcChan 

muFileName = ['MU_', upper(epoch), '.mat'];
muFileName = fullfile(edir, muFileName);

if ~exist('mu', 'var')

    if ~exist(muFileName, 'file')
        
        disp('Multiunit file not yet created, loading now')
        mu = dset_exp_load_mu(edir, epoch);
        
        muFs = mu.Fs;
        muTs = mu.timestamps;
        muRate = mu.rate;
        muBurst = mu.bursts( diff(mu.bursts,[],2)>=.035, :);
        clear mu;
        disp('Saving multi-unit file!');
        save(muFileName, 'muRate', 'muTs', 'muFs', 'muBurst');
        
    else
        
        disp('Multiunit file already exists, loading!');
        load(muFileName);
        
    end    
    
end

tmpDur = diff(muBurst, [], 2);
burstIdx = tmpDur > .1 & tmpDur <1;
muBurst = muBurst( burstIdx, :);
clear tmpDur burstIdx;
%%

% [spinOn, spinAll, spinOff] = detect_spindles2(ctxTs, ctxLfp);

[spindleTime, spindlePeakTs, spindlePeaksAllTs, spindleParam, ~, spindleEnv, spindleEnvSm ] = detect_spindles(ctxTs, ctxLfp, 'time_windows', swsTimes);
[ripplePeakTs, rippleEvents, ripplePeakAllTs, rippleParam, ~, rippleEnv]= detect_ripples(hpcTs, hpcLfp);

spindleBand = filtfilt(spindleParam.bandpass_filter, 1, ctxLfp);

isRipple = rippleEnv>=rippleParam.highThreshold;
isSpindle = spindleEnvSm>spindleParam.threshold;


spindleDuration = diff(spindleTime, [], 2);
muBurstDuration = diff(muBurst, [], 2);
rippleDuration = diff(rippleEvents, [], 2);


ripDtThresh = [.25 .25  3 ];
perSpindle =.3;
perMuBurst = .3;

[ripTripIdx, ripSingIdx] = filter_event_sets(ripplePeakTs, 3, ripDtThresh);
[lSpinIdx, sSpinIdx] = filter_event_durations(spindleDuration, perSpindle);
[lMubIdx, sMubIdx] = filter_event_durations(muBurstDuration, perMuBurst);

rippleTrig =  { ripplePeakTs(ripTripIdx), ripplePeakTs(ripSingIdx) };
spindleTrig = { spindlePeakTs( lSpinIdx , 1), spindlePeakTs( sSpinIdx , 1) };
muBurstTrig = { muBurst( lMubIdx , 1), muBurst( sMubIdx , 1) };
%%

% rippleSignal = smoothn(rippleEnv, 10, 'correct', 1);
rippleSignal = rippleEnv;
spindleSignal = spindleEnv;
muSignal = muRate;

win = [-.25 .75];
for i = 1:2
    [mR_S{i}, sR_S{i}, tsS]   = meanTriggeredSignal(rippleTrig{i}, ctxTs, spindleSignal, win);
    [mR_M{i}, sR_M{i}, tsM ]  = meanTriggeredSignal(rippleTrig{i}, muTs, muSignal, win);
    
    [mS_R{i}, sS_R{i}, tsR]    = meanTriggeredSignal(spindleTrig{i}, hpcTs, rippleSignal, win);
    [mS_M{i}, sS_M{i}, ~]      = meanTriggeredSignal(spindleTrig{i}, muTs, muSignal, win);
    
    [mM_R{i}, sM_R{i}, ~]      = meanTriggeredSignal(muBurstTrig{i}, hpcTs, rippleSignal, win);
    [mM_S{i}, sM_S{i}, ~]      = meanTriggeredSignal(muBurstTrig{i}, ctxTs, spindleSignal, win);
end
%%
 close all;
figure('Position', [160 75 1340 1000]);
ax = [];
for  i = 1:6
    ax(i) = subplot(3,2,i);
end
[p, l] = deal({});

c = 'br';
    [p{1}, l{1}] = plot_mean_trigs(tsS, mR_S, sR_S, cellfun(@size, rippleTrig,{1,1}, 'uniformoutput', 0), c, ax(1)); title(ax(1), 'Ripple Triggered Spindles');
    [p{2}, l{2}] = plot_mean_trigs(tsM, mR_M, sR_M, cellfun(@size, rippleTrig,{1,1}, 'uniformoutput', 0), c, ax(2)); title(ax(2), 'Ripple Triggered MU');
    [p{3}, l{3}] = plot_mean_trigs(tsR, mS_R, sS_R, cellfun(@size, spindleTrig,{1,1}, 'uniformoutput', 0), c, ax(3));title(ax(3), 'Spindle Triggered Ripples');
    [p{4}, l{4}] = plot_mean_trigs(tsM, mS_M, sS_M, cellfun(@size, spindleTrig,{1,1}, 'uniformoutput', 0), c, ax(4));title(ax(4), 'Spindle Triggered MU');
    [p{5}, l{5}] = plot_mean_trigs(tsS, mM_S, sM_S, cellfun(@size, muBurstTrig,{1,1}, 'uniformoutput', 0), c, ax(5));title(ax(5), 'MU Triggered Spindles');
    [p{6}, l{6}] = plot_mean_trigs(tsR, mM_R, sM_R, cellfun(@size, muBurstTrig,{1,1}, 'uniformoutput', 0), c, ax(6));title(ax(6), 'MU Triggered Ripples');
    legend(l{6}, 'Short','Long', 'Location', 'northeast');

for i = 1:6
    lineY = get(ax(i),'Ylim');
    line([0 0], lineY, 'color', 'k', 'linestyle', '--', 'parent', ax(i));
end

set(ax,'XLim', win);




%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('%s_%s_mean_%s_SPIN_trig_HPC_MUA', animal,epoch, ctxAnat);
saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');


%%
% 
% 
% [~, multiMuRate, ts] = meanTriggeredSignal(multiTimes, muTs, muRate, [-.5 1]);
% [~, singleMuRate] = meanTriggeredSignal(singleTimes, muTs, muRate, [-.5 1]);
% 
% mMultiMu = mean( multiMuRate);
% sMultiMu = std( multiMuRate);
% 
% mSingleMu = mean(singleMuRate);
% sSingleMu = std(singleMuRate);
% 
% close all;
% figH = figure('Position', [350 500 900 350]);
% axH = axes('NextPlot', 'add');
% nStd = 1.96;
% 
% 
% %[p(3), l(3)] = error_area_plot(winTime * 1000, mean(muRateRand1), nStd * std(muRateRand1) / sqrt(nRand), 'Parent', axH);
% [p(1), l(1)] = error_area_plot(ts * 1000, mMultiMu, nStd * sMultiMu / sqrt(nMulti), 'Parent', axH);
% [p(2), l(2)] = error_area_plot(ts * 1000, mSingleMu, nStd * sSingleMu / sqrt(nSingle), 'Parent', axH);
% 
% set(p,'EdgeColor', 'none');
% set(p(1), 'FaceColor','r'); set(l(1), 'Color', 'r');
% set(p(2), 'FaceColor','g'); set(l(2), 'Color', 'g');
% set(p,'FaceAlpha', .4);


% %%
% 
% 
% 
% mSingleSpin = mean(singleSpinEnv);
% sSingleSpin = std(singleSpinEnv);
% 
% figure; axH = axes;
% nStd = 1.96;
% %[p(3), l(3)] = error_area_plot(winTime * 1000, mean(muRateRand1), nStd * std(muRateRand1) / sqrt(nRand), 'Parent', axH);
% [p(1), l(1)] = error_area_plot(ts * 1000, mMultiSpin, nStd * sMultiSpin / sqrt(nMulti), 'Parent', axH);
% [p(2), l(2)] = error_area_plot(ts * 1000, mSingleSpin, nStd * sSingleSpin / sqrt(nSingle), 'Parent', axH);
% 
% set(p,'EdgeColor', 'none');
% set(p(1), 'FaceColor','r'); set(l(1), 'Color', 'r');
% set(p(2), 'FaceColor','g'); set(l(2), 'Color', 'g');
% set(p,'FaceAlpha', .4);
% 
% 
% %%
% 
% spinDur = diff(spindleEvents, [], 2);
% 
% isi1 = [Inf; diff(spindleEvents(:,1))];
% isi2 = spindleEvents(2:end,1) - spindleEvents(1:end-1,2);
% 
% isi1 = isi(isi1<.5) * 1000;
% isi2 = isi(isi2<.5) * 1000;
% 
% close all;
% [f1, x1] = ksdensity(isi1,1:500);
% [f2, x2] = ksdensity(isi2,1:500);
% 
% axes('NextPlot', 'add');
% plot(x1,f1,'r', 'linewidth', 2);
% plot(x2,f2,'g', 'linewidth', 2);
% legend('isi1', 'isi2');
% 
% 
% 
% 
% close all;
% figure;
% a = axes;
% line_browser(eegTs, eegSpinPower, 'color', 'r', 'Parent', a);
% line_browser(eegTs(tmp), eegSpinPower(tmp), 'color', 'k', 'Parent', a);
% 





