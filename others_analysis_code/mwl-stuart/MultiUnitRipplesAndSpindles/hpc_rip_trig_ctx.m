clear;


animal = 'gh-rsc1'; % 'gh-rsc1' or  'sg-rat2'
day = 'day18'; % 'day18' or 'day01'
epType = 'sleep3'; % 'sleep3 or sleep2'
CTX = 'RSC'; % 'RSC' or 'CTX'
% 
% animal = 'sg-rat2';
% day = 'day01';
% epType = 'sleep2';
% CTX = 'PFC';

eegFileName = ['EEG_HPC_1500HZ_',CTX,'_250HZ_', upper(epType), '.mat']; 

edir = fullfile('/data', animal, day);

if ~exist(fullfile(edir, eegFileName), 'file')
    disp('Loading raw eeg');
   
    e = load_exp_eeg(edir, epType);
    [~, anat] = load_exp_eeg_anatomy(edir);
    ctxChanIdx = find( strcmp(anat, CTX) );
    hpcChanIdx = find( strcmp(anat, 'rCA1') );
    chanIdx = [ctxChanIdx(1) hpcChanIdx(1)];
    e.data = e.data(:, chanIdx);
    e.loc = e.loc(chanIdx);
    e.ch = e.ch(chanIdx);
    disp('Downsampling eeg');
    
    eegHpc = e.data(:,2);
    eegTs.hpc = e.ts;
    eegFs.hpc = e.fs;
    
    e = downsample_exp_eeg(e, 250);

    eegCtx = e.data(:,1);
    eegTs.ctx = e.ts;
    eegFs.ctx = e.fs;
    
    clear e;
    
    disp('Saving eeg');
    save(fullfile(edir, eegFileName), 'eegCtx','eegHpc', 'eegTs', 'eegFs')
else
    disp('Loading pre-downsampled eeg');
    load(fullfile(edir, eegFileName));
end
clear eegFileName
%%
fprintf('Filtering for spindles and ripples\n');
spinFilt = getfilter(eegFs.ctx, 'spindle', 'win');
ripFilt = getfilter(eegFs.hpc, 'ripple', 'win');

eegSpin = filtfilt(getfilter(eegFs.ctx, 'spindle', 'win'), 1, eegCtx);
eegRip = filtfilt(getfilter(eegFs.hpc, 'ripple', 'win'), 1, eegHpc);

eegSpinEnv = abs(hilbert(eegSpin));
eegSpinPow = eegSpin .^2;
eegRipPow = eegRip.^2; 
eegRipEnv = abs(hilbert(eegRip));

tholdSpin = 3 * std(eegSpinPow);
tholdRip = 4 * std(eegRipEnv);

isSpindle = eegSpinPow > tholdSpin;
isRipple = eegRipEnv > tholdRip;

spindleEvents = detect_mountains(eegTs.ctx, eegSpinPow, 'threshold', tholdSpin);
rippleEvents = detect_mountains(eegTs.hpc, eegRipEnv, 'threshold', tholdRip);
%%
TRIG_ON = 'START';

switch TRIG_ON
    case 'START'
        spindleTs = spindleEvents(:,1);
        rippleTs = rippleEvents(:,1);
    case 'STOP'
        spindleTs = spindleEvents(:,2);
        rippleTs = rippleEvents(:,2);
    case 'MEAN'
        spindleTs = mean(spindleEvents,2);
        rippleTs = mean(rippleEvents,2);
    otherwise
        error('Invalid trigger type');
end

N_SPIN = 4;
SPIN_WIN = [.25 .15 .15];

N_RIP = 3;
RIP_WIN = [.25 .25 .25];
[lSpinIdx, sSpinIdx] = filter_event_sets(spindleTs, N_SPIN, SPIN_WIN);
[lRipIdx, sRipIdx] = filter_event_sets(rippleTs, N_RIP, RIP_WIN);

nRipL = numel(lRipIdx);
nRipS = numel(sRipIdx);
nSpinL = numel(lSpinIdx);
nSpinS = numel(sSpinIdx);
%%

win = [-.5 1];
nStd = 1.96;

[mRtRL, sRtRL, ts1] = meanTriggeredSignal(rippleTs(lRipIdx), eegTs.hpc, eegRipEnv,win);
[mRtRS, sRtRS,  ~ ] = meanTriggeredSignal(rippleTs(sRipIdx), eegTs.hpc, eegRipEnv,win);

[mRtSL, sRtSL, ts2] = meanTriggeredSignal(rippleTs(lRipIdx), eegTs.ctx, eegSpinEnv, win);
[mRtSS, sRtSS,  ~ ] = meanTriggeredSignal(rippleTs(sRipIdx), eegTs.ctx, eegSpinEnv, win);

[mStSL, sStSL, ts3] = meanTriggeredSignal(spindleTs(lSpinIdx), eegTs.ctx, eegSpinEnv, win);
[mStSS, sStSS,  ~ ] = meanTriggeredSignal(spindleTs(sSpinIdx), eegTs.ctx, eegSpinEnv, win);

[mStRL, sStRL, ts4] = meanTriggeredSignal(spindleTs(lSpinIdx), eegTs.hpc, eegRipEnv, win);
[mStRS, sStRS,  ~ ] = meanTriggeredSignal(spindleTs(sSpinIdx), eegTs.hpc, eegRipEnv, win);

tbins = win(1):.01:win(2);

[mRtRL,  ~ ] = timeAverage(ts1, mRtRL, tbins);
[sRtRL,  ~ ] = timeAverage(ts1, sRtRL, tbins);
[mRtRS,  ~ ] = timeAverage(ts1, mRtRS, tbins);
[sRtRS, ts1] = timeAverage(ts1, sRtRS, tbins);

[mStRL,  ~ ] = timeAverage(ts4, mStRL, tbins);
[sStRL,  ~ ] = timeAverage(ts4, sStRL, tbins);
[mStRS,  ~ ] = timeAverage(ts4, mStRS, tbins);
[sStRS, ts4] = timeAverage(ts4, sStRS, tbins);


ts1 = ts1 * 1000;
ts2 = ts2 * 1000;
ts3 = ts3 * 1000;
ts4 = ts4 * 1000;

close all;
figH = figure('Position', [300 500 900 500]);
axH(1) = subplot(221);
axH(2) = subplot(222);
axH(3) = subplot(223);
axH(4) = subplot(224);


[p(1), l(1)] = error_area_plot(ts3, mStSL, nStd * sStSL / sqrt(nSpinL), 'parent', axH(1), 'smooth', 0);
[p(2), l(2)] = error_area_plot(ts3, mStSS, nStd * sStSS / sqrt(nSpinS), 'parent', axH(1), 'smooth', 0);
title(axH(1), 'Spindle Triggered Spindle');

[p(3), l(3)] = error_area_plot(ts1, mRtRL, nStd * sRtRL / sqrt(nRipL), 'parent', axH(2), 'smooth', 1);
[p(4), l(4)] = error_area_plot(ts1, mRtRS, nStd * sRtRS / sqrt(nRipS), 'parent', axH(2), 'smooth', 1);
title(axH(2), 'Ripple Triggered Ripple');

[p(5), l(5)] = error_area_plot(ts2, mRtSL, nStd * sRtSL / sqrt(nRipL), 'parent', axH(3), 'smooth', 0);
[p(6), l(6)] = error_area_plot(ts2, mRtSS, nStd * sRtSS / sqrt(nRipS), 'parent', axH(3), 'smooth', 0);
title(axH(3), 'Ripple Triggered Spindle');

[p(7), l(7)] = error_area_plot(ts4, mStRL, nStd * sStRL / sqrt(nSpinL), 'parent', axH(4), 'smooth', 1);
[p(8), l(8)] = error_area_plot(ts4, mStRS, nStd * sStRS / sqrt(nSpinS), 'parent', axH(4), 'smooth', 1);
title(axH(4), 'Spindle Triggered Ripple');


xlabel(axH(1), 'Time (ms)');
xlabel(axH(2), 'Time (ms)');
xlabel(axH(3), 'Time (ms)');
xlabel(axH(4), 'Time (ms)');


set(p,'EdgeColor', 'none');
set(p(1:2:end), 'FaceColor','r'); 
set(p(2:2:end), 'FaceColor','g'); 

set(l(1:2:end), 'Color', 'r');
set(l(2:2:end), 'Color', 'g');

set(p,'FaceAlpha', .4);

set(axH, 'XLim', win * 1000);


%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('1-%s_%s_mean_%s_SPIN_HPC_RIP', animal,epType, CTX);
saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');
























