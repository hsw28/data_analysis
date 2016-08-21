
clearvars -except dPeaksAllRun
%%

epType = 'SLEEP';

if strcmp('RUN', epType)
    eList = dset_list_epochs('run');
elseif strcmp('SLEEP', epType)
    eList = dset_list_epochs('sleep');
else
    error('Invalid EP TYPE');
end

ripTrigMuaAll = [];

eps = size(eList,1);

muRate = {};
eeg = {};
ts = {};
open_pool;
parfor iEpoch = 1 : eps

    dset = dset_load_all(eList{iEpoch,1}, eList{iEpoch,2}, eList{iEpoch,3});
    dset = dset_calc_ripple_params(dset);
    
    eegTmp = dset.eeg(1);
    mu = dset.mu;

    eeg = eegTmp.data;
    eegFs = eegTmp.fs;
    eegTs{iEpoch} = dset_calc_timestamps(eegTmp.starttime, numel(eegTmp.data), eegTmp.fs);

    if ~isfield(mu, 'rate')
        muRate{iEpoch} = mu.rateL + mu.rateR;
    else
        muRate{iEpoch} = mu.rate;
    end
    muTs{iEpoch} = mu.timestamps;
    if isfield(mu,'Fs')
        muFs = mu.Fs;
    else
        muFs = mu.fs;
    end
    
    ripples(iEpoch) = dset.ripples;


end


%%


muRateAll = [];
dtThresh = [.5 .25 .25]; 
win = [-.25 .5];
tripletTs= {};
singletTs = {};
setWinTrip = {};
setWinSing = {};

dPeaksAll = [];

PLOT_INDIVIDUAL = 0;

for iEpoch = 1 : eps
    
   if isempty(muRate{iEpoch})
        continue;
    end
    
    ripTs = eegTs{iEpoch}( ripples(iEpoch).peakIdx);
       
    [tripletSet, singletSet] = filter_event_sets(ripTs, 3, dtThresh);

    tripletTs{iEpoch} = ripTs(tripletSet);
    singletTs{iEpoch} = ripTs(singletSet);
   
    nTriplet = numel(tripletSet);
    nSinglet = numel(singletSet);
    
    if nTriplet < 5
        continue;
    end
    
    
   
    
    [mRip3Mu, sRip3Mu, ts] = meanTriggeredSignal(tripletTs{iEpoch}, muTs{iEpoch}, muRate{iEpoch}, win);
    [mRip1Mu, sRip1Mu, ~ ] = meanTriggeredSignal(singletTs{iEpoch}, muTs{iEpoch}, muRate{iEpoch}, win);
    
    
    
    allPeakTs = detect_peaks(ts, mRip3Mu, [-.05 .4]);
    allDTs = diff(allPeakTs);
    dPeaksAll = [dPeaksAll; allDTs(:)];
    
    if PLOT_INDIVIDUAL
        fprintf('Triplets:%d Singlets:%d\n', nTriplet, nSinglet);

        nStd = 1.96;
        figH = figure('Position', [250+25*iEpoch 625-25*iEpoch 1000 300]);
        ax = axes();

        [p(1), l(1)] = error_area_plot(ts, mRip1Mu, nStd * sRip1Mu / sqrt(nSinglet), 'Parent', ax);
        [p(2), l(2)] = error_area_plot(ts, mRip3Mu, nStd * sRip3Mu / sqrt(nTriplet), 'Parent', ax);

        yLim = minmax( get(p(2), 'YData')' );

        set(p(1), 'FaceColor','r', 'EdgeColor','none');
        set(p(2), 'FaceColor','g', 'EdgeColor', 'none');
        set(l(1), 'Color', [.5 0 0], 'linewidth', 2);
        set(l(2), 'Color', [0 .5 0], 'linewidth', 2);
        set(gca,'XLim', win, 'YLim', yLim);



        for i = 1:numel(allPeakTs) 
            if i ~= numel(allPeakTs)
               text( mean(allPeakTs([i, i+1])), yLim(2)*.9, sprintf('%s:%2.1f', '\Deltat', 1000*allDTs(i)), 'horizontalalignment', 'center', 'FontWeight', 'bold');
            end
            line( [1 1] * allPeakTs(i), yLim, 'color', [.4 .4 .4], 'linestyle', '--');
        end
        title( sprintf('%s Triplets:%d Singlets:%d\n', ripples(iEpoch).description, nTriplet, nSinglet ) );
        
    end
end

f = figure;
dPeakMin = .035;

[Y,aX] = ksdensity(dPeaksAll*1000, 'support', 'positive');
% X = linspace(0, 250, 100);
% Y = histc(dPeaksAll*1000, X);
% Y = smoothn(Y,3);

[yMax, mIdx] = max(Y);

title(sprintf('%s - Distribution of IPI from RipTrip-Trig MU Rate', epType));
line(aX, Y);

p = round(aX(mIdx)*100)/100;
line(p * [1 1], [0 yMax*1.1], 'color', 'k');
xlabel('Time ms');


set(gca,'XTick', [0 p, 100  200 300]);

figName = sprintf('figure3-RipTrigMuRatePeakDist-%s', lower(epType));
% save_bilat_figure(figName,f)
%%
figure;

b = 0:10:250;

subplot(121);
hist(dPeaksAllSleep * 1000, b);
title('Sleep');

subplot(122);
hist(dPeaksAllRun * 1000, b);
title('Run');

set(get(gcf,'Children'), 'XLim', [0 150], 'XTick', 0:25:150);




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETECT INTER PEAK INTERVALS IN RAW MULTIUNIT SIGNAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

allMuBursts = dset_load_mu_bursts();
allRipples = dset_load_ripples();

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clearvars -except allMuBursts allRipples 
epType = 'sleep';

ripples = allRipples.(lower(epType));
muBursts = allMuBursts.(lower(epType));

muRate = {};
muTs = {};

meanRateLong = zeros(1,111);
meanRate = zeros(1,111);

dPeaksAll = [];
dPeaksShort = [];
dPeaksLong = [];
allDTs = {};
shortDTs = {};
longDTs = {};

muWin = [-.05 .5];

iEpoch = 1;
for iEpoch = 1:numel(muBursts)
    mu = muBursts(iEpoch);

    if ~isfield(mu, 'rate')
        muRate{iEpoch} = mu.rateL + mu.rateR;
    else
        muRate{iEpoch} = mu.rate;
    end
    muTs{iEpoch} = mu.timestamps;
    
    if isfield(mu,'Fs')
        muFs = mu.Fs;
    else
        muFs = mu.fs;
    end
    
    burstLen = diff(mu.bursts, [], 2);
    
    longLen{iEpoch} = quantile(burstLen, .95);
    longIdx{iEpoch} = burstLen>=longLen{iEpoch};
    
    burstsOnOff = seg2binary(mu.bursts, mu.timestamps);
    longBrOnOff =  seg2binary(mu.bursts(longIdx{iEpoch},:), mu.timestamps);
    
    [~, allPeakIdx]  = findpeaks(muRate{iEpoch}(:) .* burstsOnOff(:));
    [~, longPeakIdx] = findpeaks(muRate{iEpoch}(:) .* longBrOnOff(:));
    allPeakTs = muTs{iEpoch}(allPeakIdx);
    longPeakTs = muTs{iEpoch}(longPeakIdx);
    
    allDTs{iEpoch} = diff(allPeakTs);
    longDTs{iEpoch} = diff(longPeakTs);
    
    dPeaksAll = [dPeaksAll; allDTs{iEpoch}(:)];  
    dPeaksLong = [dPeaksAll; longDTs{iEpoch}(:)];  

    firstPeakTs = find_first_peak(mu.bursts(:,1), allPeakTs);
    
    [longTmp, ~, meanTs]  = meanTriggeredSignal( firstPeakTs(longIdx{iEpoch}), muTs{iEpoch},  muRate{iEpoch}, muWin);
    [allTmp, ~, meanTs] = meanTriggeredSignal( firstPeakTs, muTs{iEpoch},  muRate{iEpoch}, muWin);
    
    meanRateLong = meanRateLong + longTmp;
    meanRate = meanRate + allTmp;
    
 end

dPeaksAllFilt = dPeaksAll(dPeaksAll<.5);
dPeaksLongFilt = dPeaksLong(dPeaksLong <.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fSleep = figure('Position', [500 460 660 420]);
subplot(211);

tmpTs = meanTs * 1000;
plot(tmpTs, meanRateLong); hold on;
plot(tmpTs, meanRate, 'r')

[~, detectedBursts] = findpeaks(meanRateLong);

line(tmpTs(detectedBursts(1)) * [1 1], max(meanRate) * [0 1.1], 'color', 'k');
line(tmpTs(detectedBursts(2)) * [1 1], max(meanRate) * [0 1.1], 'color', 'k');


t = text( mean(tmpTs(detectedBursts(1:2))), max(meanRateLong)/2, 1, sprintf('%2.1f ms', diff(tmpTs(detectedBursts(1:2)))));
set(t, 'HorizontalAlignment', 'center', 'FontSize', 12);

set(gca, 'YLim',  max(meanRate) * [0 1.1],'XLim',muWin * 1000, 'YTick', []);
xlabel('Time ms')
title('SLEEP Mean MU Rate triggered for Long Bursts');
% set(gca, 'XTick', [0 tmpTs(idx(1:2)) 200 400]);

subplot(212);
[aF, aX] = ksdensity(dPeaksAllFilt, 'support', [0 500]);
[lF, lX] = ksdensity(dPeaksLongFilt, 'support', [0 500]);

aX = aX * 1000;
lX = lX * 1000;

plot(aX,aF, lX, lF);
[~, detectedBursts] = findpeaks(aF);
line( aX(detectedBursts(1)) * [1 1], max(aF) * [0 1.1], 'color', 'k');

set(gca,'XLim', [0 300], 'XTick', [0 aX(detectedBursts(1)), 100, 300], 'YLim', max(aF)*[0 1.1]);
xlabel('Time ms')
title(sprintf('SLEEP MUB Inter Peak Intervals %d', sum(cellfun(@sum, longIdx))));

fprintf('Number of events in Sleep: %d\n', sum(cellfun(@sum, longIdx)));
 save_bilat_figure('figure3-MuRate-Sleep', fSleep);

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
clearvars -except allMuBursts allRipples 
epType = 'run';

ripples = allRipples.(lower(epType));
muBursts = allMuBursts.(lower(epType));

muRate = {};
muTs = {};

meanRateLong = zeros(1,111);
meanRate = zeros(1,111);

dPeaksAll = [];
dPeaksShort = [];
dPeaksLong = [];
allDTs = {};
shortDTs = {};
longDTs = {};

muWin = [-.05 .5];

iEpoch = 1;
for iEpoch = 1:numel(muBursts)
    mu = muBursts(iEpoch);

    if ~isfield(mu, 'rate')
        muRate{iEpoch} = mu.rateL + mu.rateR;
    else
        muRate{iEpoch} = mu.rate;
    end
    muTs{iEpoch} = mu.timestamps;
    
    if isfield(mu,'Fs')
        muFs = mu.Fs;
    else
        muFs = mu.fs;
    end
    
    burstLen = diff(mu.bursts, [], 2);
    
    longLen{iEpoch} = quantile(burstLen, .95);
    longIdx{iEpoch} = burstLen>=longLen{iEpoch};
    
    burstsOnOff = seg2binary(mu.bursts, mu.timestamps);
    longBrOnOff =  seg2binary(mu.bursts(longIdx{iEpoch},:), mu.timestamps);
    
    [~, allPeakIdx]  = findpeaks(muRate{iEpoch}(:) .* burstsOnOff(:));
    [~, longPeakIdx] = findpeaks(muRate{iEpoch}(:) .* longBrOnOff(:));
    allPeakTs = muTs{iEpoch}(allPeakIdx);
    longPeakTs = muTs{iEpoch}(longPeakIdx);
    
    allDTs{iEpoch} = diff(allPeakTs);
    longDTs{iEpoch} = diff(longPeakTs);
    
    dPeaksAll = [dPeaksAll; allDTs{iEpoch}(:)];  
    dPeaksLong = [dPeaksAll; longDTs{iEpoch}(:)];  

    firstPeakTs = find_first_peak(mu.bursts(:,1), allPeakTs);
    
    [longTmp, ~, meanTs]  = meanTriggeredSignal( firstPeakTs(longIdx{iEpoch}), muTs{iEpoch},  muRate{iEpoch}, muWin);
    [allTmp, ~, meanTs] = meanTriggeredSignal( firstPeakTs, muTs{iEpoch},  muRate{iEpoch}, muWin);
    
    meanRateLong = meanRateLong + longTmp;
    meanRate = meanRate + allTmp;
    
 end

dPeaksAllFilt = dPeaksAll(dPeaksAll<.5);
dPeaksLongFilt = dPeaksLong(dPeaksLong <.5);

fprintf('Number of events in Run: %d\n', sum(cellfun(@sum, longIdx)));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fSleep = figure('Position', [500 460 660 420]);
subplot(211);

tmpTs = meanTs * 1000;
plot(tmpTs, meanRateLong); hold on;
plot(tmpTs, meanRate, 'r')

[~, detectedBursts] = findpeaks(meanRateLong);

line(tmpTs(detectedBursts(1)) * [1 1], max(meanRate) * [0 1.1], 'color', 'k');
line(tmpTs(detectedBursts(2)) * [1 1], max(meanRate) * [0 1.1], 'color', 'k');


t = text( mean(tmpTs(detectedBursts(1:2))), max(meanRateLong)/2, 1, sprintf('%2.1f ms', diff(tmpTs(detectedBursts(1:2)))));
set(t, 'HorizontalAlignment', 'center', 'FontSize', 12);

set(gca, 'YLim',  max(meanRate) * [0 1.1],'XLim',muWin * 1000, 'YTick', []);
xlabel('Time ms')
title('SLEEP Mean MU Rate triggered for Long Bursts');
% set(gca, 'XTick', [0 tmpTs(idx(1:2)) 200 400]);

subplot(212);
[aF, aX] = ksdensity(dPeaksAllFilt, 'support', [0 500]);
[lF, lX] = ksdensity(dPeaksLongFilt, 'support', [0 500]);

aX = aX * 1000;
lX = lX * 1000;

plot(aX,aF, lX, lF);
[~, detectedBursts] = findpeaks(aF);
line( aX(detectedBursts(1)) * [1 1], max(aF) * [0 1.1], 'color', 'k');

set(gca,'XLim', [0 300], 'XTick', [0 aX(detectedBursts(1)), 100, 300], 'YLim', max(aF)*[0 1.1]);
xlabel('Time ms')
title(sprintf('RUN MUB Inter Peak Intervals %d', sum(cellfun(@sum, longIdx))));

 save_bilat_figure('figure3-MuRate-Run', fSleep);




