%% Get ripple burst times for SPL11/D14
epoch = 'sleep2';
ch_ignore = {'none'};
exp = exp_load('/data/spl11/day14', 'epochs', epoch, 'data_types', {'eeg'}, 'ignore_eeg_channel', ch_ignore);
exp = process_loaded_exp(exp, 'operations', [8]);


lInd = strcmp(exp.(epoch).eeg.loc, 'lCA1');
rInd = strcmp(exp.(epoch).eeg.loc, 'rCA1');
ca1Ind = lInd | rInd;

exp.(epoch).eeg.data = exp.(epoch).eeg.data(:,ca1Ind);
exp.(epoch).eeg.loc = exp.(epoch).eeg.loc(ca1Ind);
exp.(epoch).eeg.ch = exp.(epoch).eeg.ch(ca1Ind);
eeg = exp.(epoch).eeg;
b = {};

parfor iChan = 1 : 16
    [b{iChan}]  = find_rip_burst(eeg.data(:,iChan), eeg.fs, eeg.ts(1));  
end

outFile = '/data/misc/spl11_d14_sleep_rip_burst.mat';
save(outFile, 'b', 'lInd', 'rInd');
 
%% Open raw unbuffered eeg
clear;
inFiles = {'/data/spl11/day14/eeg1.buf', '/data/spl11/day14/eeg2.buf'};
outFiles = {'/data/misc/eeg1.eeg', '/data/misc/eeg2.eeg'};
%% Debuffer and save
for i = 1:2
    debuffer_eeg_file(inFiles{i}, outFiles{i}, 'Fs', 1500);
end


%% Get a small snippet of the EEG

for i = 1:2
    data(i) = load( mwlopen( outFiles{i} ) );
end

sleepWin = [5800 6200];

% firstTs = max( [data(1).timestamp(1) data(2).timestamp(1)]);
% lastTs = min( [data(1).timestamp(end) data(2).timestamp(end)]);
ts = sleepWin(1): 1/2000:(sleepWin(2) - 1/2000);



%% Interpolate
for i = 1:2
    for j = 1:8
        chanStr = sprintf('channel%d', j);
        data(i).(chanStr) = interp1(data(i).timestamp, single( data(i).(chanStr) ), ts);
    end
    data(i).timestamp = ts;
end

%% Combine

eeg = [data(1).channel1; data(1).channel2; data(1).channel3; data(1).channel4; ...
            data(1).channel5; data(1).channel6; data(1).channel7; data(1).channel8; ...
            data(2).channel1; data(2).channel2; data(2).channel3; data(2).channel4; ...
            data(2).channel5; data(2).channel6; data(2).channel7; data(2).channel8];
        
%% Save
saveFile = '/data/misc/spl11_d14_sleep2.mat';

save(saveFile, 'eeg', 'ts');
 