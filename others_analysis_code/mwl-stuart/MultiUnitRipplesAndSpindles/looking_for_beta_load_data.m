%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Load Sleep Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('~/Desktop/looking_for_beta.mat', 'file')
    load ~/Desktop/looking_for_beta.mat;
    return;
end

fprintf('Loading the data!\n');
sleepEpochs = dset_list_epochs('sleep');
runEpochs = dset_list_epochs('run');

if ~exist('ripSleep', 'var') || ~exist('ripRun', 'var')
	ripples = dset_load_ripples;
	ripSleep = ripples.sleep(2);
	ripRun = ripples.run(1);
	clear ripples;
end

if ~exist('eegSlp', 'var') || ~exist('eegRun', 'var')
	dsetSlp = dset_load_all(sleepEpochs{2,1}, sleepEpochs{2,2}, sleepEpochs{2,3});    
	dsetRun = dset_load_all(runEpochs{1,1}, runEpochs{1,2}, runEpochs{1,3});  

	eegSlp.data = dsetSlp.eeg(1).data;
	eegSlp.starttime = dsetSlp.eeg(1).starttime;
	eegRun.data = dsetRun.eeg(1).data;
	eegRun.starttime = dsetRun.eeg(1).starttime;

end

fprintf('Computing MUA!\n');
Fs = 1500;
nSamp = round( .25 * Fs );
win = [-nSamp:nSamp];

%%%% SLEEP
tsSlp = dset_calc_timestamps(dsetSlp.eeg(1).starttime, numel(dsetSlp.eeg(1).data), dsetSlp.eeg(1).fs);
muRateSlp = interp1(dsetSlp.mu.timestamps, dsetSlp.mu.rate, tsSlp);
muRateSlp(isnan(muRateSlp))=0;

ripWinSlp = bsxfun(@plus, win, ripSleep.peakIdx);
muaSlp = muRateSlp(ripWinSlp);
meanMuaSleep = mean(muaSlp);

%%%% RUN

tsRun = dset_calc_timestamps(dsetRun.eeg(1).starttime, numel(dsetRun.eeg(1).data), dsetRun.eeg(1).fs);
muRateRun = interp1(dsetRun.mu.timestamps, dsetRun.mu.rate, tsRun);
muRateRun(isnan(muRateRun))=0;

ripWinRun = bsxfun(@plus, win, ripRun.peakIdx);
muaRun = muRateRun(ripWinRun);
meanMuaRun = mean(muaRun);

