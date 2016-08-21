function generateFigure3
open_pool;
%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Prepare the data for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%%%%% SLEEP %%%%%
% dSleep = dset_load_all('spl11', 'day14', 'sleep2');
% eegS = dSleep.eeg; clear dSleep;
% 
% [ttId ttAnat] = load_exp_tt_anatomy('/data/spl11/day14');
% 
% muSleepL = load_exp_mu('/data/spl11/day14', 'sleep2', 'ignore_tetrode', ttId( ~strcmp(ttAnat, 'lCA1') ));
% muSleepR = load_exp_mu('/data/spl11/day14', 'sleep2', 'ignore_tetrode', ttId( ~strcmp(ttAnat, 'rCA1') ));
% 
% tbins = dset_calc_timestamps(eegS(1).starttime, numel(eegS(1).data), eegS(1).fs);
% 
% muSleepL = histc(muSleepL, tbins);
% muSleepR = histc(muSleepR, tbins);
sleepEpochs = dset_list_epochs('sleep');
runEpochs = dset_list_epochs('run');

dsetS = dset_load_all(sleepEpochs{2,1}, sleepEpochs{2,2}, sleepEpochs{2,3});    
dsetR = dset_load_all(runEpochs{1,1}, runEpochs{1,2}, runEpochs{1,3});    

burstIdx = arrayfun(@(x,y) ( muTs >= x & muTs <= y ), events(:,1), events(:,2), 'UniformOutput', 0 );


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Plot The Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


end

