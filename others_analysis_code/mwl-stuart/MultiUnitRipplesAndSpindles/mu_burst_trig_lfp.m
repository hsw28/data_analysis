%%
% DATA SETS Showing some rhythmicity in the Multi-Unit bursts
%
% - Trigger on Burst START:
%   Bon 10:3, 6:3
%   S11 12:2
%
%   Best --> 7:3, S11 13:2
%
% - Trigger on Burst END:
%   Bon 3:3 6:5 3:3 9:3 5:5 10:3 5:5
%   S11 13:s2
%
%   Best --> Bon 5:5 3:3  10:3
%
% - Trigger on Burst CENTER:
%   spl11 14:2
%   bon 3:3
%
%

%%
clear;

epType = 'SLEEP';
if strcmp('RUN', epType)
    eList = dset_list_epochs('run');
elseif strcmp('SLEEP', epType)
    eList = dset_list_epochs('sleep');
else
    error('Invalid EP TYPE');
end
%TRIG_ON  must be 'PEAK', 'START', 'MEAN', or 'END'
TRIG_ON  = 'START';

if ~any( strcmp( TRIG_ON, {'PEAK','MEAN', 'START', 'END'} ) )
    error('Invalid trigger');
end
iEpoch = 1;
SHOW_PLOT = 1;

dPeaksAll = [];
%%
for iEpoch = 1:size(eList,1)
    
    drawnow;
    clearvars -except iEpoch eList SHOW_PLOT TRIG_ON eList epType dPeaksAll
    %     if ~exist('muRate', 'var') ||  isempty(muRate)
    disp('Multi-unit and eeg not loaded yet, loading now');
    
    dset = dset_load_all(eList{iEpoch,1}, eList{iEpoch,2}, eList{iEpoch,3});
    %         eegTmp = dset.eeg(1);
    mu = dset.mu;
    eegTs = dset_calc_timestamps(dset.eeg(1).starttime, numel(dset.eeg(1).data), dset.eeg(1).fs);
    eegFs = dset.eeg(1).fs;
    
    eegRaw = dset.eeg(1).data;
    eegRip = filtfilt( getfilter(eegFs,'ripple', 'win'), 1, eegRaw);
    ripEnv = abs(hilbert(eegRip));
    
    %         eegTs = dset_calc_timestamps(eegTmp.starttime, numel(eegTmp.data), eegTmp.fs);
    
    if ~isfield(mu, 'rate')
        muRate = mu.rateL + mu.rateR;
    else
        muRate = mu.rate;
    end
    
    muBursts = mu.bursts;
    muTs = mu.timestamps;
    muFs = mean(diff(mu.timestamps))^-1;
    
    %%
    % Get the length of the multi-unit bursts
    burstLen = diff(muBursts,[],2);
    burstIdx = find( burstLen > quantile(burstLen, .3) );
    nBurst(iEpoch) = nnz(burstIdx);
    
    % [~, sIdx] = sort(burstLen);
    % burstIdx = sIdx(end-10:end);
    
    fprintf('Found %d bursts\n', numel(burstIdx));
    
    % find the Multi-unit rate for the bursts
    peakIdx = zeros(size(burstIdx));
    for j = 1:numel(burstIdx)
        
        startIdx = find( muTs == muBursts(burstIdx(j), 1), 1, 'first');
        endIdx = find(muTs == muBursts(burstIdx(j),2), 1, 'first');
        
        switch TRIG_ON
            case 'MEAN'
                peakIdx(j) = round( mean( [startIdx endIdx] ) );% - 1 + mIdx;
            case 'START'
                peakIdx(j) = startIdx;
            case 'END'
                peakIdx(j) = endIdx;
            case 'PEAK'
                [~, mIdx] = max( muRate(startIdx:endIdx) );
                peakIdx(j) = startIdx + mIdx - 1;
            otherwise
                peakIdx(j) = startIdx;
        end
        
    end
    
    %convert the peakIdx from multi-unit samples to eeg samples  
    peakTs = muTs(peakIdx);
    peakTs = interp1(eegTs, eegTs, peakTs, 'nearest');
    
    % define the window in samples and time around the event
    
    
    winLenTime = .5;
    winLenSamp = winLenTime * eegFs;
    winSamp = -winLenSamp:winLenSamp;
    winTime = 1000 * winSamp / eegFs;

    sampleWin = round( bsxfun(@plus, peakIdx, -winLenSamp:winLenSamp ) );
    
    
    muTrigRipEnv = ripEnv(sampleWin);  
    
    figure;
    plot(winTime, mean(muTrigRipEnv))
    
end

%%

[counts, centers] = hist(dPeaksAll * 1000, 0:10:400);
counts = counts/max(counts);

[~, maxCntIdx] = max(counts);
[f, xi] = ksdensity(dPeaksAll*1000);
f = f/max(f);
[~, idxMaxF] = max(f);

figH = figure;

bar(centers, counts,1);


line(xi,f,'Color','r','linewidth', 2);
line(xi(idxMaxF), f(idxMaxF), 'color', 'g', 'marker', '.','markersize', 30);


txt = text(xi(idxMaxF), 1.025*f(idxMaxF) , sprintf('%2.1fms', xi(idxMaxF)));

set(txt, 'fontsize', 16, 'horizontalalignment', 'center');
title(sprintf('Inter MUB Peak Intervals. Ep:%s Trig:%s',epType, TRIG_ON'));
set(gca,'YLim', [0 1.1]);

strName = sprintf('mean_MUA_burst_trig_%s_%s', TRIG_ON, epType);
saveFigure(figH, '/data/ripple_burst_dynamics/', strName, 'png', 'svg', 'fig');


