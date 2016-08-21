function generateFigure3_2B
open_pool;
%% Ripple Triggered Average Multi-unit Activity

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Load Sleep Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
% %%%%% SLEEP %%%%%
% sleepEpochs = dset_list_epochs('sleep');
% % runEpochs = dset_list_epochs('run');
% ripples = dset_load_ripples;
% ripples = ripples.sleep(2);
% 
% dset = dset_load_all(sleepEpochs{2,1}, sleepEpochs{2,2}, sleepEpochs{2,3});    
% % dsetR = dset_load_all(runEpochs{1,1}, runEpochs{1,2}, runEpochs{1,3});    
% %%
% Fs = dset.eeg(1).fs;
% nSamp = round( .25 * Fs );
% win = [-nSamp:nSamp];
% 
% ts = dset_calc_timestamps(dset.eeg(1).starttime, numel(dset.eeg(1).data), dset.eeg(1).fs);
% muRate = interp1(dset.mu.timestamps, dset.mu.rate, ts);
% muRate(isnan(muRate))=0;
% 
% ripWin = bsxfun(@plus, win, ripples.peakIdx);
% mua = muRate(ripWin);
% meanMuaSleep = mean(mua);
looking_for_beta_load_data;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Bilateral EEG XCORR during Sleep
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fsEeg = dsetSlp.eeg(1).fs;

tsEegRun = dset_calc_timestamps(dsetRun.eeg(1).starttime, numel(dsetRun.eeg(1).data), dsetRun.eeg(1).fs);
tsEegSlp = dset_calc_timestamps(dsetSlp.eeg(1).starttime, numel(dsetSlp.eeg(1).data), dsetSlp.eeg(1).fs);

eventsRun = dsetSlp.mu.bursts;
eventsSleep = dsetSlp.mu.bursts;

burstIdxRun = arrayfun(@(x,y) ( tsEegRun >= x & tsEegRun <= y ), eventsRun(:,1), eventsRun(:,2), 'UniformOutput', 0 );
burstIdxRun = sum(cell2mat(burstIdxRun));

burstIdxSleep = arrayfun(@(x,y) ( tsEegSlp >= x & tsEegSlp <= y ), eventsSleep(:,1), eventsSleep(:,2), 'UniformOutput', 0 );
burstIdxSleep = sum(cell2mat(burstIdxSleep));

eegRunBase = dsetRun.eeg(1).data .* burstIdxRun';
eegRunCont = dsetRun.eeg(3).data .* burstIdxRun';

eegSleepBase = dsetSlp.eeg(1).data .* burstIdxSleep';
eegSleepCont = dsetSlp.eeg(3).data .* burstIdxSleep';

xcWin = .25;
[xcSleepEeg, lagsEeg] = xcorr(eegSleepBase, eegSleepCont, ceil( xcWin * fsEeg), 'coef' );
[xcRunEeg, lagsEeg] = xcorr(eegRunBase, eegRunCont, ceil( xcWin * fsEeg), 'coef' );
lagsEeg = lagsEeg / fsEeg;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Bilateral MU RATE XCORR during Sleep
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fsMu = dsetSlp.mu.fs;

tsMuRun = dsetSlp.mu.timestamps;
tsMuSlp = dsetRun.mu.timestamps;

eventsRun = dsetSlp.mu.bursts;
eventsSleep = dsetSlp.mu.bursts;

burstIdxRun = arrayfun(@(x,y) ( tsMuRun >= x & tsMuRun <= y ), eventsRun(:,1), eventsRun(:,2), 'UniformOutput', 0 );
burstIdxRun = sum(cell2mat(burstIdxRun));

burstIdxSleep = arrayfun(@(x,y) ( tsMuSlp >= x & tsMuSlp <= y ), eventsSleep(:,1), eventsSleep(:,2), 'UniformOutput', 0 );
burstIdxSleep = sum(cell2mat(burstIdxSleep));

muBaseRun = dsetRun.mu.rateL .* burstIdxRun';
muContRun = dsetRun.mu.rateR .* burstIdxRun';

muBaseSleep = dsetSlp.mu.rateL .* burstIdxSleep';
muContSleep = dsetSlp.mu.rateR .* burstIdxSleep';

xcWin = .25;
[xcSleepMu, lagsMu] = xcorr(muBaseSleep, muContSleep, ceil( xcWin * fsMu), 'coeff' );
[xcRunMu, lagsMu] = xcorr(muBaseRun, muContRun, ceil( xcWin * fsMu), 'coeff' );
lagsMu = lagsMu / fsMu;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Plot Ripple Triggered MU Rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f1 = figure;
a = axes;

line(1000 * win/ Fs, meanMuaRun, 'color', [1 0 0], 'linewidth', 2);
line(1000 * win / Fs, meanMuaSleep, 'Color', [0 0 1], 'linewidth', 2);

line([0 0], get(gca,'Ylim'));
set(gca,'XLim', [-250 250]);
line([0 0], get(gca,'Ylim'), 'Color', 'k');
set(gca,'YTick', []);
xlabel('Time (ms)');
ylabel('Multiunit Rate');

title('RipTrig Average MUA');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Plot Bilateral MUR XCorr during MU BURSTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


f2 = figure;
a = axes;

% xcRunMu = smoothn(xcRunMu,2, 'Correct', 1);
% xcSleepMu = smoothn(xcSleepMu,2, 'Correct', 1);

line(lagsMu, xcRunMu, 'color', [1 0 0], 'linewidth', 2);
line(lagsMu, xcSleepMu, 'Color', [0 0 1], 'linewidth', 2);

xlabel('Time (ms)');
ylabel('Correlation');

set(a, 'XLim', xcWin*[-1 1],'YLim',  minmax( [xcRunMu(:); xcSleepMu(:)]' ) .* [.9 1.1]);
legend('Sleep', 'Run');

title('Bilateral MUR XCorr during MUB');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Plot Bilateral EEG XCorr during MU BURSTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


f3 = figure;
a = axes;

xcRunEeg = smoothn(xcRunEeg,2, 'Correct', 1);
xcSleepEeg = smoothn(xcSleepEeg,2, 'Correct', 1);

line(lagsEeg, xcRunEeg, 'color', [1 0 0], 'linewidth', 2);
line(lagsEeg, xcSleepEeg, 'Color', [0 0 1], 'linewidth', 2);

xlabel('Time (ms)');
ylabel('Correlation');

legend('Sleep', 'Run');

set(a, 'XLim', xcWin*[-1 1],'YLim',  minmax( [xcRunEeg(:); xcSleepEeg(:)]' ) .* [1.1 1.1]);


title('Bilateral EEG XCorr during MUB');


%%


save_bilat_figure('figure3-2B1', f1);
save_bilat_figure('figure3-2B2', f2);
save_bilat_figure('figure3-2B2', f3);


end


