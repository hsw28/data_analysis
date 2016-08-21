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

meanRateLong = zeros(1,161);
meanRate = zeros(1,161);


iEpoch = 2;
% for iEpoch = 1:numel(muBursts)
mu = muBursts(iEpoch);
if ~isfield(mu, 'rate')
    muRate = mu.rateL + mu.rateR;
else
    muRate = mu.rate;
end
muTs = mu.timestamps;

if isfield(mu,'Fs')
    muFs = mu.Fs;
else
    muFs = mu.fs;
end

burstLen = diff(mu.bursts, [], 2);
[~, sortIdx] = sort(burstLen, 'descend');


longLen = quantile(burstLen, .95);
longIdx = burstLen>=longLen;

burstsOnOff = seg2binary(mu.bursts, mu.timestamps);
longBrOnOff =  seg2binary(mu.bursts(longIdx,:), mu.timestamps);

%% Load EEG
clear;
d = dset_load_all('Bon', 4, 3);
eeg = d.eeg(1);
eegTs = dset_calc_timestamps(eeg.starttime, numel(eeg.data), eeg.fs);
mu = d.mu;

%%
% Good Examples: Bon 4-3:   11, 17, 32, 36, 43, 65, 66, 81

close all;
N = 8;
ax = [];


% eIdx = [36 143 5 90 62 69 122 96];% 96  % bon 4 - 3
eIdx = [ 122    62    90    36    69   143    96     5];

win = [-.1 .3];

muSamps = win .* mu.fs;
eegSamps = round(win .*eeg.fs);

muSamps = muSamps(1):muSamps(2);
eegSamps = eegSamps(1):eegSamps(2);

f = figure('Position', [490   222   560   842]);
DY = .95;
for i = 1:N
    
    ax(i) = axes('Position', [.1 1 - (1/N) * (DY-.1) * (i) - .015, .89, (1/N) * (DY-.15)], 'XTick', [], 'YTick', []);
    
    tStart = mu.bursts( eIdx(i),1 );
    tEnd = mu.bursts( eIdx(i),2 );
    idx = interp1(mu.timestamps, 1:numel(mu.timestamps), tStart, 'nearest');
    
    rate = mu.rate( idx:(idx+20) );
    
     
    [~, pkIdx] = findpeaks(rate);
    pkIdx = idx + pkIdx(1)-1;
    
    muIdx = pkIdx+muSamps;
    
    peakTs = mu.timestamps(pkIdx);
    muTs = 1000 * ( mu.timestamps(muIdx) - peakTs );
    
    rateL = smoothn(mu.rateL(muIdx), 1,'correct', 1);
    rateR = smoothn(mu.rateR(muIdx), 1, 'correct', 1);
    line(muTs, rateL, 'color','r', 'linewidth', 4);
    line(muTs, rateR, 'color','b', 'linewidth', 4);
    
    line((tStart - peakTs) * [1e3 1e3], [0 5000], 'Color', 'g', 'linewidth', 2, 'linestyle', '--');
    line((tEnd - peakTs) * [1e3 1e3], [0 5000], 'Color', 'r', 'linewidth', 2, 'linestyle', '--');
    
%     ax(i,2) = axes('Position', [.05 .90 - (1/N) * (i-1) + (1/N) * .45, .9, (1/N) * .35], ...
%         'XTick', [], 'YTick', [], 'Color', 'none', 'YLim', [-400 600]);
% 
%     idx = interp1(eegTs, 1:numel(eeg.data), peakTs, 'nearest');
%     
%     eegIdx = idx+eegSamps;
%      
%     eTs = 1000 * (eegTs(eegIdx) - eegTs(idx));
%     v = eeg.data(eegIdx);
%     line(eTs, v, 'color', 'r');
%     ylabel(eIdx(i));

end
p = get(ax(end), 'Position');
ax(end+1) = axes('Position', [.1 p(2) .89, .85]);
axis(ax(end), 'off');
for i = -2:6
    line(60 * [i i], [0, 5000], 'color', [.4 .4 .4], 'parent', ax(end));
end
    
set(ax(1:end), 'Xtick',[], 'XLim', win * 1000, ...
     'YLim', [0 5000]);
set(ax(end-1), 'Xtick', -60:60:360, 'XLim', win * 1000, ...
     'YLim', [0 5000]);
 
 %%
 figName = 'Figure3-MultiUnitPeaksRawExample';
 save_bilat_figure(figName, f);

    
%     [~, allPeakIdx]  = findpeaks(muRate{iEpoch}(:) .* burstsOnOff(:));
%     [~, longPeakIdx] = findpeaks(muRate{iEpoch}(:) .* longBrOnOff(:));
%     allPeakTs = muTs{iEpoch}(allPeakIdx);
%     longPeakTs = muTs{iEpoch}(longPeakIdx);
%     
%     allDTs{iEpoch} = diff(allPeakTs);
%     longDTs{iEpoch} = diff(longPeakTs);
%     
%     dPeaksAll = [dPeaksAll; allDTs{iEpoch}(:)];  
%     dPeaksLong = [dPeaksAll; longDTs{iEpoch}(:)];  
% 
%     [longTmp, ~, meanTs]  = meanTriggeredSignal(mu.bursts(longIdx{iEpoch},1), muTs{iEpoch},  muRate{iEpoch}, [-.05, .75]);
%     [allTmp, ~, meanTs] = meanTriggeredSignal(mu.bursts(:,1), muTs{iEpoch},  muRate{iEpoch}, [-.05, .75]);
%     
%     meanRateLong = meanRateLong + longTmp;
%     meanRate = meanRate + allTmp;
%     
%  end