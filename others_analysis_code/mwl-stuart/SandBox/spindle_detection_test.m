%%
clear;
animal = 'gh-rsc1';
day = 'day18';
edir = fullfile('/data', animal, day);
eegFileName = 'EEG_RSC_250HZ_SLEEP3.mat';
epType = 'sleep3';

if ~exist(fullfile(edir, eegFileName), 'file')
    disp('Loading raw eeg');
    
    e = load_exp_eeg(edir, epType);
    [~, anat] = load_exp_eeg_anatomy(edir);
    chanIdx = strcmp(anat, 'RSC');
    e.data = e.data(:, chanIdx);
    e.loc = e.loc(chanIdx);
    e.ch = e.ch(chanIdx);
    disp('Downsampling eeg');
    e = downsample_exp_eeg(e, 250);
    
    eegData = e.data;
    eegTs = e.ts;
    eegFs = e.fs;
    clear e;
    disp('Saving eeg');
    save(fullfile(edir, eegFileName), 'eegData', 'eegTs', 'eegFs')
else
    disp('Loading pre-downsampled eeg');
    load(fullfile(edir, eegFileName));
end
clear eegFileName
%%

% - Filter RSC channels in the spindle band (10-20 hz)
eegChan = 1;
eegCtx = eegData(:,eegChan);
s1Filt = getfilter(eegFs, 'spindle', 'win');
% s2Filt = getfilter(fs, 'spindle2', 'win');

disp('Filtering RSC EEG for Spindles');
eegSpinBand = filtfilt(s1Filt, 1, eegCtx);
%rscSpin2 = filtfilt(s2Filt, 1, data);

eegSpinEnvelope = abs(hilbert(eegSpinBand));
eegSpinPower = eegSpinBand .^2;

tholdEnvelope = 3 * std(eegSpinEnvelope);
tholdPower = 3 * std(eegSpinPower);


%isSpindlePow = bsxfun(@gt, eegSpinPower, tholdPow);
% isSpindleEnv = bsxfun(@gt, rscEnv, tholdEnv);

% - Load the multi-unit data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   CHANGE THESE VALUES
BURST_LEN = 'SHORT'; % must be SHORT or LONG
TRIG_ON = 'MEAN'; % must be START END MEAN PEAK

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

muFileName = 'MU_SLEEP3.mat';
muFileName = fullfile(edir, muFileName);

if ~exist('mu', 'var')
    if ~exist(muFileName, 'file')
        disp('Multiunit file not yet created, loading now')
        d = dset_load_all('gh-rsc1', 'day18', epType);
        mu = d.mu;
        clear d;
        disp('Saving multi-unit file!');
        save(muFileName, 'mu');
    else
        disp('Multiunit file already exists, loading!');
        load(muFileName);
    end
    
    muRate = mu.rate;
    muTs = mu.timestamps;
    muFs = 1/mean(diff(muTs));
    muBursts = mu.bursts;
    clear d;
    
end

%spindleEvents = logical2seg(eegTs, isSpindlePow);
spindleEvents = detect_mountains(eegTs, eegSpinPower, 'threshold', tholdPower);
binarySpindles = eegSpinPower > tholdPower;

isi = [Inf; diff(spindleEvents(:,1))];

%%
dtThresh = [.25 .15 .15];

setIdx.trip = [];
setIdx.sing = [];

tmpSetIdx3 = nan(size(isi));
tmpSetIdx1 = nan(size(isi));

N = 4;
for j = 1:numel(isi)-N
    
    if isi(j) > dtThresh(1)
        
        if all( isi( j+1 : j+N) < dtThresh(2) )
            
            tmpSetIdx3(j) = j;
            
        elseif isi(j+1) > dtThresh(3)*N
            
            tmpSetIdx1(j) = j;
            
        end
        
    end
end
multiSpinIdx = tmpSetIdx3( isfinite(tmpSetIdx3));
singleSpinIdx = tmpSetIdx1( isfinite(tmpSetIdx1));

nMulti = nnz(multiSpinIdx);
nSingle = nnz( singleSpinIdx);

fprintf('Multi:%d Single:%d\n', nMulti, nSingle);


multiTimes = spindleEvents(multiSpinIdx,1);
singleTimes = spindleEvents(singleSpinIdx,1);

% [multiSpMean, multiSpAll, ts] = meanTriggeredSignal(multiTimes, eegTs, binarySpindles, [-.5 1]);
% [singleSpMean, singleSpAll, ts] = meanTriggeredSignal(singleTimes, eegTs, binarySpindles, [-.5 1]);

[~, multiSpinEnv, ts1] = meanTriggeredSignal(multiTimes, eegTs, eegSpinEnvelope, [-.5 1]);
[~, singleSpinEnv] = meanTriggeredSignal(singleTimes, eegTs, eegSpinEnvelope, [-.5 1]);

mMultiSpin = mean( multiSpinEnv);
sMultiSpin = std( multiSpinEnv);

mSingleSpin = mean(singleSpinEnv);
sSingleSpin = std(singleSpinEnv);

[~, multiMuRate, ts2] = meanTriggeredSignal(multiTimes, muTs, muRate, [-.5 1]);
[~, singleMuRate] = meanTriggeredSignal(singleTimes, muTs, muRate, [-.5 1]);

mMultiMu = mean( multiMuRate);
sMultiMu = std( multiMuRate);

mSingleMu = mean(singleMuRate);
sSingleMu = std(singleMuRate);
nStd = 1.96;

close all;
figure('Position', [350 700 900 800]);

axH(1) = subplot(211); 
axH(2) = subplot(212); 

set(axH,'NextPlot', 'add');



%[p(3), l(3)] = error_area_plot(winTime * 1000, mean(muRateRand1), nStd * std(muRateRand1) / sqrt(nRand), 'Parent', axH);
[p(1), l(1)] = error_area_plot(ts1 * 1000, mMultiSpin, nStd * sMultiSpin / sqrt(nMulti), 'Parent', axH(1));
[p(2), l(2)] = error_area_plot(ts1 * 1000, mSingleSpin, nStd * sSingleSpin / sqrt(nSingle), 'Parent', axH(1));


[p(3), l(3)] = error_area_plot(ts2 * 1000, mMultiMu, nStd * sMultiMu / sqrt(nMulti), 'Parent', axH(2));
[p(4), l(4)] = error_area_plot(ts2 * 1000, mSingleMu, nStd * sSingleMu / sqrt(nSingle), 'Parent', axH(2));


set(p,'EdgeColor', 'none');
set(p(1:2:3), 'FaceColor','r'); set(l(1:2:3), 'Color', 'r');
set(p(2:2:4), 'FaceColor','g'); set(l(2:2:4), 'Color', 'g');
set(p,'FaceAlpha', .4);
%% - Save the Figure;
tmpAnimal = animal;
tmpAnimal(tmpAnimal~='-') = '_';
strName = sprintf('%s_%s_SpinTrig_ctxSpin_hpcMU', animal,epType );
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





