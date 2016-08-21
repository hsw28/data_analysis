function [stats] = calc_bilateral_ripple_stats(r)
if ~isstruct(r)
    error('R must be a struct');
end
if ~isscalar(r)
    error('R must be a scalar');
end

nRipple = numel(r.peakIdx);
ts = r.window / r.fs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bilateral Ripple Instaneous Frequency Correlations 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ripWin = [-.01 .01];
ripIdx = ts >= ripWin(1) & ts<=ripWin(2);

trig.instFreq = r.instFreq{1}(:, ripIdx);
ipsi.instFreq = r.instFreq{2}(:, ripIdx);
cont.instFreq = r.instFreq{3}(:, ripIdx);

corrIdx = ~isnan(trig.instFreq .* ipsi.instFreq .* cont.instFreq);

[stats.instFreq.corrIpsi, stats.instFreq.pIpsi]= corr(trig.instFreq(corrIdx(:)), ipsi.instFreq(corrIdx(:)));
[stats.instFreq.corrCont, stats.instFreq.pCont]= corr(trig.instFreq(corrIdx(:)), cont.instFreq(corrIdx(:)));


nShuffle = 1000;
stats.nShuffle = nShuffle;
for iShuffle = 1:nShuffle

   randIdx = randsample(nRipple, nRipple,1); 
   
   ipsiShuffle = ipsi.instFreq(randIdx,:);
   contShuffle = cont.instFreq(randIdx,:);
   
   corrIdx = ~isnan(trig.instFreq .* ipsiShuffle .*contShuffle);
   
   freqCorr.ipsiShuff(iShuffle) = corr( trig.instFreq(corrIdx(:)), ipsiShuffle(corrIdx(:)) );
   freqCorr.contShuff(iShuffle) = corr( trig.instFreq(corrIdx(:)), contShuffle(corrIdx(:)) );
   
end

stats.instFreq.pIpsiMC = max( sum( freqCorr.ipsiShuff > stats.instFreq.corrIpsi) / nShuffle, 1/nShuffle);
stats.instFreq.pContMC = max( sum( freqCorr.contShuff > stats.instFreq.corrCont) / nShuffle, 1/nShuffle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bilateral SW Peak Amplitude Correlations 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

swWin = [-.05 .05];
swIdx = ts >= swWin(1) & ts<=swWin(2);

% correct sharpwaves
sw = {};
swBaseline = {};
for i = 1:3
    sw{i} = abs(r.sw{i});
    sw{i} = bsxfun(@minus, sw{i}, mean(sw{i}(:, 1:5),2) );
    sw{i} = bsxfun(@rdivide, sw{i}, max( mean(sw{i})) );
end

[trig.swPeakAmp, ipsi.swPeakAmp, cont.swPeakAmp] = deal( zeros(nRipple, 1) );

for iRipple = 1:nRipple

    trig.swPeakAmp(iRipple) = max( sw{1}(iRipple,swIdx) );
    ipsi.swPeakAmp(iRipple) = max( sw{2}(iRipple,swIdx) );
    cont.swPeakAmp(iRipple) = max( sw{3}(iRipple,swIdx) );
   
end
    
[stats.swAmp.corrIpsi, stats.swAmp.pIpsi] = corr(trig.swPeakAmp, ipsi.swPeakAmp);
[stats.swAmp.corrCont, stats.swAmp.pCont] = corr(trig.swPeakAmp, cont.swPeakAmp);

nShuffle = 1000;

for iShuffle = 1:nShuffle

   randIdx = randsample(nRipple, nRipple,1); 
   
   ipsiShuffle = ipsi.swPeakAmp(randIdx,:);
   contShuffle = cont.swPeakAmp(randIdx,:);
      
   ampCorr.ipsiShuff(iShuffle) = corr( trig.swPeakAmp, ipsiShuffle );
   ampCorr.contShuff(iShuffle) = corr( trig.swPeakAmp, contShuffle );
   
end

stats.swAmp.pIpsiMC = max( sum( ampCorr.ipsiShuff > stats.swAmp.corrIpsi) / nShuffle, 1/nShuffle);
stats.swAmp.pContMC = max( sum( ampCorr.contShuff > stats.swAmp.corrCont) / nShuffle, 1/nShuffle);
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bilateral SW Phase X Ripple Envelope Correlation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rEnv = {};
swPhase = {};
for i = 1:3
    rEnv{i} = abs(hilbert(r.rip{i}'))';
    swPhase{i} = angle(hilbert(r.sw{i}'))';
end

[~, mIdxIpsi] = max(rEnv{2}, [], 2);
[~, mIdxCont] = max(rEnv{2}, [], 2);

mIndIpsi= sub2ind( size(rEnv{1}), 1:nRipple, mIdxIpsi');
mIndCont= sub2ind( size(rEnv{1}), 1:nRipple, mIdxCont');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Bilateral Phase x Amplitude distribution vs shuffle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stats.swPhaseRipEnv.corrIpsi, stats.swPhaseRipEnv.pIpsi] = ...
        circ_corrcl(swPhase{1}(mIndIpsi), rEnv{2}(mIndIpsi));
    
[stats.swPhaseRipEnv.corrCont, stats.swPhaseRipEnv.pCont] = ...
        circ_corrcl(swPhase{1}(mIndCont), rEnv{3}(mIndCont));

phaseEnv.corrIpsi = circ_corrcl(swPhase{1}(mIndIpsi), rEnv{2}(mIndIpsi));
phaseEnv.corrCont = circ_corrcl(swPhase{1}(mIndCont), rEnv{3}(mIndCont));

[mShuffPhaseIpsi, mShuffEnvIpsi, mShuffPhaseCont, mShuffEnvCont] = deal( zeros(nShuffle, 1));

for i = 1:nShuffle
    randIdx = randsample(nRipple, nRipple);
    swPhaseShuff = swPhase{1}(randIdx,:); 
%     [mShuffPhaseIpsi(i), mShuffEnvIpsi(i)] = circ_mean_vec(swPhaseShuff(mIndIpsi), rEnv{2}(mIndIpsi));
%     [mShuffPhaseCont(i), mShuffEnvCont(i)] = circ_mean_vec(swPhaseShuff(mIndCont), rEnv{3}(mIndCont));
    
    phaseEnv.ipsiShuff(i) = circ_corrcl( swPhaseShuff(mIndIpsi), rEnv{2}(mIndIpsi));
    phaseEnv.contShuff(i) = circ_corrcl( swPhaseShuff(mIndCont), rEnv{3}(mIndCont));
end



stats.swPhaseRipEnv.pIpsiMC = max( sum( phaseEnv.ipsiShuff > stats.swPhaseRipEnv.corrIpsi) / nShuffle, 1/nShuffle);
stats.swPhaseRipEnv.pContMC = max( sum( phaseEnv.contShuff > stats.swPhaseRipEnv.corrCont) / nShuffle, 1/nShuffle);



stats.instFreq = orderfields(stats.instFreq, {'corrIpsi', 'corrCont','pIpsi', 'pCont', 'pIpsiMC', 'pContMC'});
stats.swAmp = orderfields(stats.swAmp, {'corrIpsi', 'corrCont','pIpsi', 'pCont', 'pIpsiMC', 'pContMC'});
stats.swPhaseRipEnv = orderfields(stats.swPhaseRipEnv, {'corrIpsi', 'corrCont','pIpsi', 'pCont', 'pIpsiMC', 'pContMC'});

end


% function [freq, dur, amp, rippleWindows] = calc_bilateral_ripple_stats(eeg, baseChan, ipsiChan, contChan)
% minDt = .025;
% 
% %%
% for i = 1:numel(eeg)
%     if  isfield(eeg(i), 'timestamps')
%         eeg(i).starttime = eeg(i).timestamps(1);
%     elseif ~isfield(eeg(i), 'starttime')
%         disp('No starttime member for eeg');
%         continue;
%     end
%     
%     if i == baseChan || i==ipsiChan || i==contChan
%         disp('Calculating ripple bursts');
%         [rippleWindows{i}, maxTimes{i}, maxPower{i}, ~, ripplePower{i}] = find_rip_burst(eeg(i).data, eeg(i).fs, eeg(i).starttime);
%     end
% end
% 
% %%
% %% -- Ripple Frequency Analysis
% %%
% %% get the indecies of events that occur on both sets of channels
% baseIdx = logical(zeros(size(maxTimes{baseChan})));
% ipsiIdx = logical(zeros(size(maxTimes{baseChan})));
% contIdx = logical(zeros(size(maxTimes{baseChan})));
% 
% nearestIpsi = interp1(maxTimes{ipsiChan}, maxTimes{ipsiChan}, maxTimes{baseChan}, 'nearest');
% ipsiIdx = abs(nearestIpsi - maxTimes{baseChan}) <= minDt;
% 
% nearestCont = interp1(maxTimes{contChan}, maxTimes{contChan}, maxTimes{baseChan}, 'nearest');
% contIdx = abs(nearestCont - maxTimes{baseChan}) <= minDt;
% 
% 
% %% - Calculate the dominant frequency for the selected events
% [bvbRipFreq bvbSpec bvbFreq] = dset_calc_event_peak_freq(eeg(baseChan).data, eeg(baseChan).starttime, eeg(baseChan).fs, maxTimes{baseChan});
% [bviRipFreq bviSpec bviFreq] = dset_calc_event_peak_freq(eeg(ipsiChan).data, eeg(ipsiChan).starttime, eeg(ipsiChan).fs, maxTimes{baseChan}(ipsiIdx));
% [bvcRipFreq bvcSpec bvcFreq] = dset_calc_event_peak_freq(eeg(contChan).data, eeg(contChan).starttime, eeg(contChan).fs, maxTimes{baseChan}(contIdx));
% 
% bviRho = corr(bvbRipFreq(ipsiIdx)', bviRipFreq', 'type', 'spearman');
% bvcRho = corr(bvbRipFreq(contIdx)', bvcRipFreq', 'type', 'spearman');
% 
% freq.baseVsIpsi.base = bvbRipFreq(ipsiIdx)';
% freq.baseVsIpsi.ipsi = bviRipFreq';
% 
% freq.baseVsCont.base = bvbRipFreq(contIdx)';
% freq.baseVsCont.cont = bvcRipFreq';
% 
% freq.baseVsIpsiCorr = bviRho;
% freq.baseVsContCorr = bvcRho;
% 
% %% Plot the dominant frequency relationships
% % figure('Position', [300 300 300 700]);
% % subplot(211);
% % 
% % plot(bvbRipFreq(ipsiIdx), bviRipFreq, '.');
% % title(['Correlation: ', num2str(round(bviRho*100)/100)]);
% % 
% % subplot(212);
% % plot(bvbRipFreq(contIdx), bvcRipFreq, '.');
% % title(['Correlation: ', num2str(round(bvcRho*100)/100)]);
% 
% %%
% %% -- Ripple Duration Analysis
% %%
% %% get event durations
% baseDuration = diff(rippleWindows{baseChan}');
% ipsiDuration = diff(rippleWindows{ipsiChan}');
% contDuration = diff(rippleWindows{contChan}');
% %% get indices of overlapping time windows
% 
% [baseIdxIpsi ipsiIdxIpsi] = calc_time_window_overlap(rippleWindows{baseChan}, rippleWindows{ipsiChan});
% [baseIdxCont contIdxCont] = calc_time_window_overlap(rippleWindows{baseChan}, rippleWindows{contChan});
% 
% %% Plot the overlaps to make sure they are real
% % figure;
% % axes;
% % for i = 1:numel(baseIdxIpsi)
% %    line(rippleWindows{baseChan}(baseIdxIpsi(i),:), repmat([0+.1*i],1,2));
% %    line(rippleWindows{ipsiChan}(ipsiIdxIpsi(i),:), repmat([0+.1*i]+.05,1,2), 'color', 'red');
% % end
% %%
% 
% bviRhoDur = corr(baseDuration(baseIdxIpsi)', ipsiDuration(ipsiIdxIpsi)', 'type', 'spearman');
% bvcRhoDur = corr(baseDuration(baseIdxCont)', contDuration(contIdxCont)', 'type', 'spearman');
% 
% dur.baseVsIpsi.base = baseDuration(baseIdxIpsi);
% dur.baseVsIpsi.ipsi = ipsiDuration(ipsiIdxIpsi);
% 
% dur.baseVsCont.base = baseDuration(baseIdxCont);
% dur.baseVsCont.cont = contDuration(contIdxCont);
% 
% dur.baseVsIpsiCorr = bviRhoDur;
% dur.baseVsContCorr = bvcRhoDur;
% % 
% % figure('Position', [300 300 300 700]);
% % subplot(211);
% % 
% % 
% % plot(baseDuration(baseIdxIpsi), ipsiDuration(ipsiIdxIpsi),'.');
% % title(['Correlation: ', num2str(round(bviRhoDur*100)/100)]);
% % subplot(212);
% % 
% % plot(baseDuration(baseIdxCont), contDuration(contIdxCont),'.');
% % title(['Correlation: ', num2str(round(bvcRhoDur*100)/100)]);
% % 
% % set(get(gcf, 'Children'), 'Xlim', [0 .14], 'YLim', [0 .14]);
% 
% %%
% %% -- Ripple Power Analysis
% %%
% 
% bviRhoPow = corr(maxPower{baseChan}(baseIdxIpsi)', maxPower{ipsiChan}(ipsiIdxIpsi)', 'type', 'spearman');
% bvcRhoPow = corr(maxPower{baseChan}(baseIdxCont)', maxPower{contChan}(contIdxCont)', 'type', 'spearman');
% 
% amp.baseVsIpsi.base = ripplePower{baseChan}(baseIdxIpsi)';
% amp.baseVsIpsi.ipsi = ripplePower{ipsiChan}(ipsiIdxIpsi)';
% 
% amp.baseVsCont.base = ripplePower{baseChan}(baseIdxCont)';
% amp.baseVsCont.cont = ripplePower{contChan}(contIdxCont)';
% 
% amp.baseVsIpsiCorr = bviRhoPow;
% amp.baseVsContCorr = bvcRhoPow;
% % 
% % figure('Position', [300 300 300 700]);
% % 
% % subplot(211);
% % 
% % plot(ripplePower{baseChan}(baseIdxIpsi), ripplePower{ipsiChan}(ipsiIdxIpsi),'.');
% % title(['Correlation: ', num2str(round(bviRhoPow*100)/100)]);
% % % subplot(212);
% % 
% % plot(ripplePower{baseChan}(baseIdxCont), ripplePower{contChan}(contIdxCont),'.');
% % title(['Correlation: ', num2str(round(bvcRhoPow*100)/100)]);
% % set(get(gcf,'Children'), 'Xlim', [0 5e5], 'YLim', [0 5e5]);
% 
