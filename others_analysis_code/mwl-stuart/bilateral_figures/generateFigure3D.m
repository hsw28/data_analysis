

%%
clear

if ~exist('allRipples','var')
    allRipples = dset_load_ripples;
end
epType = 'SLEEP';

if strcmp('RUN', epType)
    eList = dset_list_epochs('run');
    ripples = allRipples.run;
elseif strcmp('SLEEP', epType)
    eList = dset_list_epochs('sleep');
    ripples = allRipples.sleep;
else
    error('Invalid EP TYPE');
end

Fs = 1500;
ripWin = -750:750;
ripTrigMuaAll = [];


eps = 2;
%eps = 1:size(eList,1);
if ~exist('muRate', 'var') || ~exist('eeg','var') || ~exist('ts','var') || ~exist('fs','var') || ...
 isempty(muRate) || isempty(eeg) || isempty(tsRip) || isempty(fs)
    disp('Multi-unit and eeg not loaded yet, loading now');
    muRate = {};
    eeg = {};
    tsRip = {};
    fs = [];
    
    for iEpoch = eps%1:numel(ripples)
        
        dset = dset_load_all(eList{iEpoch,1}, eList{iEpoch,2}, eList{iEpoch,3});
        %dset = dset_load_all('gh-rsc1', 'day18', 'sleep3');
        eegTmp = dset.eeg(1);
        mu = dset.mu;
        
        eeg = eegTmp.data;
        eegFs = eegTmp.fs;
        eegTs = dset_calc_timestamps(eegTmp.starttime, numel(eegTmp.data), eegTmp.fs);
       
        if ~isfield(mu, 'rate')
            muRate{iEpoch} = mu.rateL + mu.rateR;
        else
            muRate{iEpoch} = mu.rate;
        end
        muTs = mu.timestamps;
        if isfield(mu,'Fs')
            muFs = mu.Fs;
        else
            muFs = mu.fs;
        end
        
    
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Compute the Triplet/Singlet triggered MU Rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
muRateAll = [];
dtThresh = [1 .25 .25]; 
win = [-.25 .5];
tripletTsJit= {};
singletTsJit = {};
setWinTrip = {};
setWinSing = {};

for iEpoch = eps%:numel(ripples)
    
   if isempty(muRate{iEpoch})
        continue;
    end
    
    ripTs = eegTs( ripples(iEpoch).peakIdx);
       
    numel(filter_event_sets(ripTs, 3, dtThresh))
    
    [tripletSet, singletSet] = filter_event_sets(ripTs, 3, dtThresh);

    tripletTsJit{iEpoch} = ripTs(tripletSet);
    singletTsJit{iEpoch} = ripTs(singletSet);
   
    fprintf('Triplets:%d Singlets:%d\n', numel(tripletSet), numel(singletSet));
   
   
    
    nTriplet = numel(tripletSet);
    nSinglet = numel(singletSet);
    
    
    peakTs = detect_peaks(tsRip, mRipEnvTrip, [-.1 .4]);
    
    nStd = 1.96;
%     close all;
    figH = figure('Position', [250 625 1000 300]);
    ax = axes();

    [p(1), l(1)] = error_area_plot(tsRip, mRipEnvSing, nStd * sRipEnvSing / sqrt(nSinglet), 'Parent', ax);
    [p(2), l(2)] = error_area_plot(tsRip, mRipEnvTrip, nStd * sRipEnvTrip / sqrt(nTriplet), 'Parent', ax);
    
    yLim = minmax( get(p(2), 'YData')' );
    
    set(p(1), 'FaceColor','r', 'EdgeColor','none');
    set(p(2), 'FaceColor','g', 'EdgeColor', 'none');
    set(l(1), 'Color', [.5 0 0], 'linewidth', 2);
    set(l(2), 'Color', [0 .5 0], 'linewidth', 2);
    set(gca,'XLim', win, 'YLim', yLim);
    
    dPeakTs = diff(peakTs);
    
    for i = 1:numel(peakTs) 
        if i ~= numel(peakTs)
           text( mean(peakTs([i, i+1])), yLim(2)*.9, sprintf('%s:%2.1f', '\Deltat', 1000*dPeakTs(i)), 'horizontalalignment', 'center', 'FontWeight', 'bold');
        end
        line( [1 1] * peakTs(i), yLim, 'color', [.4 .4 .4], 'linestyle', '--');
    end
       
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Compute the Triplet/Singlet triggered MU RATE and Ripple Power
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dset = dset_filter_eeg_ripple_band(dset);

rippleBand = dset.eeg(1).rippleband;
ripplePow = rippleBand .^ 2;
rippleEnv = abs( hilbert(rippleBand) );

muRateAll = [];
dtThresh = [1 .25 .25]; 
win = [-.25 .5];
tripletTs= {};
singletTs = {};
setWinTrip = {};
setWinSing = {};
%%
for iEpoch = eps%:numel(ripples)
    
   if isempty(muRate{iEpoch})
        continue;
    end
    
    ripTs = eegTs( ripples(iEpoch).peakIdx);
       
    numel(filter_event_sets(ripTs, 3, dtThresh))
    
    [tripletSet, singletSet] = filter_event_sets(ripTs, 3, dtThresh);

    tripletTs{iEpoch} = ripTs(tripletSet);
    singletTs{iEpoch} = ripTs(singletSet);
   
    fprintf('Triplets:%d Singlets:%d\n', numel(tripletSet), numel(singletSet));
   
    [mMuRateTrip, sMuRateTrip, tsMu] = meanTriggeredSignal(tripletTs{iEpoch}, muTs, muRate{iEpoch}, win);
    [mMuRateSing, sMuRateSing, ~ ] = meanTriggeredSignal(singletTs{iEpoch}, muTs, muRate{iEpoch}, win);
    
%     [mRipEnvTrip, sRipEnvTrip, tsRip] = meanTriggeredSignal(tripletTs{iEpoch}, eegTs, rippleEnv, win);
%     [mRipEnvSing, sRipEnvSing, ~ ] = meanTriggeredSignal(singletTs{iEpoch}, eegTs, rippleEnv, win);
%     
%     [mRipPowTrip, sRipPowTrip, tsRip] = meanTriggeredSignal(tripletTs{iEpoch}, eegTs, ripplePow, win);
%     [mRipPowSing, sRipPowSing, ~ ] = meanTriggeredSignal(singletTs{iEpoch}, eegTs, ripplePow, win);
    
    smRipPow = smoothn(ripplePow, 4, 'correct', 1);
    
    [mRipPowTrip, sRipPowTrip, tsRip] = meanTriggeredSignal(tripletTs{iEpoch}, eegTs, smRipPow, win);
    [mRipPowSing, sRipPowSing, ~ ] = meanTriggeredSignal(singletTs{iEpoch}, eegTs, smRipPow, win);
    
    nTriplet = numel(tripletSet);
    nSinglet = numel(singletSet);
    
    
    nStd = 1.96;
    close all;

    figH = figure('Position', [250 625 600 600]);
    ax = [];
    ax(1) = subplot(211);
    ax(2) = subplot(212);
        
    line(tsMu, normr( mMuRateTrip ), 'color', 'r', 'parent', ax(1));
    line(tsMu, normr( mMuRateSing ), 'color', 'g', 'parent', ax(1));
    
    line(tsRip, normr( mRipPowTrip ), 'color', 'r', 'parent', ax(2));
    line(tsRip, normr( mRipPowSing ), 'color', 'g', 'parent', ax(2));
    
      
    set(ax(1),'XLim', [-.1 .35], 'YLim', [0 .25]); title(ax(1), 'Ripple Triggered MUA');
    set(ax(2),'XLim', [-.1 .35], 'YLim', [0 .2]); title(ax(2), 'Ripple Triggered Ripple Pow');
       
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Inter-Ripple Interval for Triplets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tripTs = tripletTs{2};
iri = [ Inf diff(ripTs)];
out = false(size(ripTs));
for i = 1:numel(tripTs)
    out = out | ( ripTs > tripTs(i) & ripTs < tripTs(i) + 1 );
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Compute the JITTERED Triplet/Singlet triggered MU RATE and Ripple Power
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

muRateAll = [];
dtThresh = [1 .25 .25]; 
win = [-.25 .5];
tripletTsJit= {};
singletTsJit = {};
setWinTrip = {};
setWinSing = {};
%%
for iEpoch = eps%:numel(ripples)
    
    if isempty(muRate{iEpoch})
        continue;
    end
    
    ripTs = eegTs( ripples(iEpoch).peakIdx);
       
    numel(filter_event_sets(ripTs, 3, dtThresh))
    
    [tripletSet, singletSet] = filter_event_sets(ripTs, 3, dtThresh);
    nTrip = numel(tripletSet);
    nSing = numel(singletSet);
    
    tripletTsJit{iEpoch} = ripTs(tripletSet) + (randi(90, 1, nTrip)-45)/1000;
    singletTsJit{iEpoch} = ripTs(singletSet) + (randi(90, 1, nSing)-45)/1000;
   
    fprintf('Triplets:%d Singlets:%d\n', numel(tripletSet), numel(singletSet));
   
    [mMuRateTrip, sMuRateTrip, tsMu] = meanTriggeredSignal(tripletTsJit{iEpoch}, muTs, muRate{iEpoch}, win);
    [mMuRateSing, sMuRateSing, ~ ] = meanTriggeredSignal(singletTsJit{iEpoch}, muTs, muRate{iEpoch}, win);
    
%     [mRipEnvTrip, sRipEnvTrip, tsRip] = meanTriggeredSignal(tripletTs{iEpoch}, eegTs, rippleEnv, win);
%     [mRipEnvSing, sRipEnvSing, ~ ] = meanTriggeredSignal(singletTs{iEpoch}, eegTs, rippleEnv, win);
%     
%     [mRipPowTrip, sRipPowTrip, tsRip] = meanTriggeredSignal(tripletTs{iEpoch}, eegTs, ripplePow, win);
%     [mRipPowSing, sRipPowSing, ~ ] = meanTriggeredSignal(singletTs{iEpoch}, eegTs, ripplePow, win);
    
    smRipPow = smoothn(ripplePow, 3, 'correct', 1);
    
    [mRipPowTrip, sRipPowTrip, tsRip] = meanTriggeredSignal(tripletTsJit{iEpoch}, eegTs, smRipPow, win);
    [mRipPowSing, sRipPowSing, ~ ] = meanTriggeredSignal(singletTsJit{iEpoch}, eegTs, smRipPow, win);
    
    nTriplet = numel(tripletSet);
    nSinglet = numel(singletSet);
    
    nStd = 1.96;
    close all;

    figH = figure('Position', [250 625 600 600]);
    ax = [];
    ax(1) = subplot(211);
    ax(2) = subplot(212);
        
    line(tsMu, normr( mMuRateTrip ), 'color', 'r', 'parent', ax(1));
    line(tsMu, normr( mMuRateSing ), 'color', 'g', 'parent', ax(1));
    
    line(tsRip, normr( mRipPowTrip ), 'color', 'r', 'parent', ax(2));
    line(tsRip, normr( mRipPowSing ), 'color', 'g', 'parent', ax(2));

    set(ax(1),'XLim', [-.1 .35], 'YLim', [0 .25]); title(ax(1), 'Ripple Triggered MUA');
    set(ax(2),'XLim', [-.1 .35], 'YLim', [0 .2]); title(ax(2), 'Ripple Triggered Ripple Pow');
   
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Compute the Pre/Post burst LFP Spectrum 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iEpoch = 2;

nTapers = 4;
hs = spectrum.mtm(nTapers);
set3Rip = setWinTrip{iEpoch};
set1Rip = setWinSing{iEpoch};

midIdx = round(size(set3Rip,2)/2);
preOffset = 75;
postOffset = -75; %%<------------- REMOVE ALL RIPPLE SAMPS FROM PRE
nSamp = 600;        %%<------------- SET N SAMP HERE

preIdx = (1:nSamp) + ( (midIdx - nSamp) - preOffset);
postIdx = (midIdx : midIdx+nSamp ) + postOffset;

specPre3 = [];
specPost3 = [];
specPre1 = [];
specPost1 = [];

lfpPre3 = eeg{iEpoch}(set3Rip(:, preIdx));
lfpPost3 = eeg{iEpoch}(set3Rip(:, postIdx));
lfpPre1 = eeg{iEpoch}(set1Rip(:, preIdx));
lfpPost1 = eeg{iEpoch}(set1Rip(:, postIdx));
freqs = [];

%%
for iRip = 1:size(set3Rip,1)
      
    psdPre3 =  psd(hs, lfpPre3(iRip,:),  'Fs', Fs);
    psdPost3 = psd(hs, lfpPost3(iRip,:), 'Fs', Fs);
    
    psdPre1 =  psd(hs, lfpPre1(iRip,:),  'Fs', Fs);
    psdPost1 = psd(hs, lfpPost1(iRip,:), 'Fs', Fs);
    
    if isempty(specPre3)
        specPre3 = psdPre3.Data;
        specPost3 = psdPost3.Data;
        specPre1 = psdPre1.Data;
        specPost1 = psdPost1.Data;
        
    else
        specPre3 = [specPre3, psdPre3.Data];
        specPost3 = [specPre3, psdPost3.Data];
        
        specPre1 = [specPre1, psdPre1.Data];
        specPost1 = [specPre1, psdPost1.Data];
    end  
    if isempty(freqs)
        freqs = psdPre3.frequencies;
    end
end

% transpose the matrices for later use
[specPre3, specPost3, specPre1, specPost1] = deal( specPre3', specPost3', specPre1', specPost1');



%% Plot the ratio of the spectra

figure('Position', [400 30 560 1000]);


ax(1) = subplot(311);
line(freqs,  mean(specPost1) ./ mean(specPre1), 'Color', 'r', 'linewidth', 2 );
set(gca,'XLim', [0 300]);
title('Post1:Pre1 Ratio');

ax(2) = subplot(312);
line(freqs,  mean(specPost3) ./ mean(specPre3) , 'Color', 'g', 'linewidth', 2 );
title('Post3:Pre3 Ratio');

ax(3) = subplot(313);
line(freqs,  mean(specPost3) ./ mean(specPost1) , 'Color', 'b', 'linewidth', 2 );
title('Post3:Post1 Ratio');
set(ax,'XLim', [0 300]);



%% Plot the Spectrums
figure;
clear ax;
ax(1) = subplot(211);
imagesc(freqs, 1:size(set3Rip,1), log(specPre3) );

ax(2) = subplot(212);
imagesc(freqs, 1:size(set3Rip,1), log(specPost3) );

set(ax,'YDir', 'normal');
%hpsd = psd(Hs, 

%%






