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

win = [0 .25];
nStd = 1.96;

[mRtRL, sRtRL, freq1] = meanTriggeredSpectrum(rippleTs(lRipIdx), eegTs.hpc, eegRipEnv,win);
[mRtRS, sRtRS,  ~ ] = meanTriggeredSpectrum(rippleTs(sRipIdx), eegTs.hpc, eegRipEnv,win);

[mRtSL, sRtSL, freq2] = meanTriggeredSpectrum(rippleTs(lRipIdx), eegTs.ctx, eegSpinEnv, win);
[mRtSS, sRtSS,  ~ ] = meanTriggeredSpectrum(rippleTs(sRipIdx), eegTs.ctx, eegSpinEnv, win);

[mStSL, sStSL, freq3] = meanTriggeredSpectrum(spindleTs(lSpinIdx), eegTs.ctx, eegSpinEnv, win);
[mStSS, sStSS,  ~ ] = meanTriggeredSpectrum(spindleTs(sSpinIdx), eegTs.ctx, eegSpinEnv, win);

[mStRL, sStRL, freq4] = meanTriggeredSpectrum(spindleTs(lSpinIdx), eegTs.hpc, eegRipEnv, win);
[mStRS, sStRS,  ~ ] = meanTriggeredSpectrum(spindleTs(sSpinIdx), eegTs.hpc, eegRipEnv, win);

%%

close all;
figH = figure('Position', [450 200 800 630]);
axH(1) = subplot(221);
axH(2) = subplot(222);
axH(3) = subplot(223);
axH(4) = subplot(224);

line(freq3, mStSL./mStSS, 'Parent', axH(1));
title(axH(1),'Spindle Triggered CTX Spectrum');

line(freq4, mStRL./mStRS, 'Parent', axH(3));
title(axH(3),'Spindle Triggered HPC Spectrum');

line(freq1, mRtRL./mRtRS, 'Parent', axH(2));
title(axH(2), 'Ripple Triggered HPC Spectrum');

line(freq2, mRtSL./mRtSS, 'Parent', axH(4));
title(axH(4), 'Ripple Triggered CTX Spectrum');

ylabel(axH(1), 'Long/Short PSD Ratio');
ylabel(axH(2), 'Long/Short PSD Ratio');
ylabel(axH(3), 'Long/Short PSD Ratio');
ylabel(axH(4), 'Long/Short PSD Ratio');

xlabel(axH(1), 'Frequency (Hz)');
xlabel(axH(2), 'Frequency (Hz)');
xlabel(axH(3), 'Frequency (Hz)');
xlabel(axH(4), 'Frequency (Hz)');

set(axH, 'XLim', [0 100]);

%%


%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('%s_%s_mean_%s_SPIN_HPC_SPECTRUM', animal,epType, CTX);
saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');
























