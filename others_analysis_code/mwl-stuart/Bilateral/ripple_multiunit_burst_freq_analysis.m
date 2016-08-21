    
% This analys showed a nice differential effect during run in the following
% animals:
% spl11= d11 d13 d14
%ch_ignore ={'eeg1.ch8', 'eeg2.ch5'};

epoch = 'sleep3';
ch_ignore = {'none'};
ex = exp_load('/data/fabian/fk18/day07', 'epochs', epoch, 'data_types', {'eeg', 'mu'}, 'ignore_eeg_channel', ch_ignore);
ex = process_loaded_exp(ex, 'operations', [2,4,8]);

ca1Ind = strcmp(ex.(epoch).eeg.loc, 'lCA1') | strcmp(ex.(epoch).eeg.loc, 'rCA1');

ex.(epoch).eeg.data = ex.(epoch).eeg.data(:,ca1Ind);
ex.(epoch).eeg.loc = ex.(epoch).eeg.loc(ca1Ind);
ex.(epoch).eeg.ch = ex.(epoch).eeg.ch(ca1Ind);
eeg = ex.(epoch).eeg;
mu = ex.(epoch).mu;
%%
velThold = .15;
nChan = size(eeg.loc,2);


%pos = exp.run.pos;
%isMoving = abs(pos.lv)>velThold;f
%eegMoving = interp1(pos.ts, isMoving, eeg.ts, 'nearest');
%eegMoving(isnan(eegMoving))=0;
%eegMoving=logical(eegMoving);

 idx = 1:12;
 eeg.data = eeg.data(:,idx);
 eeg.loc = eeg.loc(idx);
 eeg.ch = eeg.ch(idx);
 nChan = numel(idx);

disp('Filtering and calculating the ripple bursts');
[ripBurst,~,~,eeg.ripple] = find_rip_burst(eeg);
for i=1:nChan
     eeg.ripEnvelope(:,i) = abs(hilbert(eeg.ripple(:,i)));
end
%%
m = mean(eeg.ripEnvelope);
s = std(eeg.ripEnvelope);
n_std = 3;
for i=1:size(eeg.ripple,2)
    eeg.ripBin(:,i) = eeg.ripEnvelope(:,i)>= m(i)+s(i)*n_std;
end
%%


%%
disp('Computing PSTH of MU - Ripple Trig');
rippPsth = [];

nSamples = 500;
muPsth = zeros(nChan, 2*nSamples+1);

tbins = (-1*nSamples:nSamples)*mean(diff(mu.ts));

for j=1:nChan
    
    %[p bins] = peri_stim_eeg_ave(eeg.ripEnvelope(:,i), eeg.ts, ripBurst{j}(:,1), nSamples);
    [p bins] = peri_stim_eeg_ave(mu.global, mu.ts, ripBurst{j}(:,1), nSamples);
    %[p bins] = peri_stim_eeg_ave(eeg.ripBin(:,i), eeg.ts, mean(ripBurst{j},2), nSamples);
    muPsth(j,:) = mean(p);
    
  %  wb = my_waitbar(cycleCount/nChan^2, wb);
end

signal = smoothn(mean(muPsth),5,'correct',1);
[m i] = findpeaks(signal);
figure; 
ax = axes();
plot(tbins, signal, 'linewidth', 2); hold on;
plot(tbins(i), signal(i), 'r.', 'markersize', 20);
for idx = i;
    if tbins(idx)> -.12 & tbins(idx) < .12
        text(tbins(idx), signal(idx)+100, [num2str(tbins(idx))], 'fontsize', 16);
    end
end
set(ax,'Xlim', [-.15 .15], 'YTick', [], 'FontSize', 16);
title('Average MU Rate - LFP Triggers');

%%
disp('Computing PSTH of MU - Multi-Unit Burst Trig');
rippPsth = [];

nSamples = 500;
muPsth = zeros(nChan, 2*nSamples+1);

tbins = (-1*nSamples:nSamples)*mean(diff(mu.ts));
clear ax  psth1  bins;

figure('Position', [2000 300 320 750]);

ax(1) = subplot(211);
    [psth1 bins] = peri_stim_eeg_ave(mu.global, mu.ts, mu.global_bursts(:,1), nSamples);
    signal1 = smoothn(mean(psth1),5,'correct',1);
    plot(tbins, signal1, 'linewidth',2); hold on;
    [m i1] = findpeaks(signal1);
    plot(tbins(i1), signal1(i1), 'r.');
    for idx = i1;
        if tbins(idx)> -.12 & tbins(idx) < .12
            text(tbins(idx), signal1(idx), [num2str(tbins(idx))], 'fontsize', 16);
        end
    end
title('Ave MU - Burst Onset Triggers', 'fontsize',16);
    
ax(2) = subplot(212);
    [psth2 bins] = peri_stim_eeg_ave(mu.global, mu.ts, mu.global_bursts(:,2), nSamples);
    signal2 = smoothn(mean(psth2),5,'correct',1);
    plot(tbins, signal2, 'linewidth',2); hold on;
    [m1 i2] = findpeaks(signal2);
    plot(tbins(i2), signal2(i2), 'r.');
    for idx = i2;
        if tbins(idx)> -.12 & tbins(idx) < .12
            text(tbins(idx), signal2(idx), [num2str(tbins(idx))], 'fontsize', 16);
        end
    end    
title('Ave MU - Burst Offset Triggers', 'fontsize',16);    
set(ax,'Xlim', [-.12 .12], 'YTick', [], 'FontSize', 16);

%%