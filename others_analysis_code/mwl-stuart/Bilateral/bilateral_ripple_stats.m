clear;

epList = dset_list_epochs('run');
for i = 1:size(epList)
    fprintf('Running: %s %d %d\n', epList{i,1}, epList{i,2}, epList{i,3});
    dset = dset_load_all(epList{i,1}, epList{i,2}, epList{i,3});
    eeg = dset.eeg;
    ca1Idx = strcmp('CA1', {eeg.area});
    
    eeg = eeg(ca1Idx);
    
    leftIdx = find(strcmp({eeg.hemisphere}, 'left'));
    rightIdx = find(strcmp({eeg.hemisphere}, 'right'));
    if numel(leftIdx)>1
        baseChan = leftIdx(1);
        ipsiChan = leftIdx(2);
        contChan = rightIdx(1);
    else
        baseChan = rightIdx(1);
        ipsiChan = rightIdx(2);
        contChan = leftIdx(1);
    end
    
    [freq(i), dur(i), amp(i)] = calc_bilateral_ripple_stats(eeg, baseChan, ipsiChan, contChan);  

end
%%
% 
% idx = 1;
% epoch = 2;
% for i=3:7
%     disp(i);
%     dset = dset_load_all('Bon', i, epoch);
%     eeg = dset.eeg;
%     ca1Idx = strcmp('CA1', {eeg.area});
%     
%     eeg = eeg(ca1Idx);
%     
%     leftIdx = find(strcmp({eeg.hemisphere}, 'left'));
%     rightIdx = find(strcmp({eeg.hemisphere}, 'right'));
%     if numel(leftIdx)>1
%         baseChan = leftIdx(1);
%         ipsiChan = leftIdx(2);
%         contChan = rightIdx(1);
%     else
%         baseChan = rightIdx(1);
%         ipsiChan = rightIdx(2);
%         contChan = leftIdx(1);
%     end
%     
%     [freq(idx), dur(idx), amp(idx)] = calc_bilateral_ripple_stats(eeg, baseChan, ipsiChan, contChan);
%     
%     idx = idx+1;
% end
% %%
% for i=2
%     disp(i);
%     eeg = dset_load_eeg('Dud', i, epoch,1:30);
% 
%     ca1Idx = strcmp('CA1', {eeg.area});
%     
%     eeg = eeg(ca1Idx);
%     
%     leftIdx = find(strcmp({eeg.hemisphere}, 'left'));
%     rightIdx = find(strcmp({eeg.hemisphere}, 'right'),1);
%     if numel(leftIdx)>1
%         baseChan = leftIdx(1);
%         ipsiChan = leftIdx(2);
%         contChan = rightIdx(1);
%     else
%         baseChan = rightIdx(1);
%         ipsiChan = rightIdx(2);
%         contChan = leftIdx(1);
%     end
%     
%     
%     [freq(idx), dur(idx), amp(idx)] = calc_bilateral_ripple_stats(eeg, baseChan, ipsiChan, contChan);
%     
%     idx = idx+1;
% end
% 
% %%
% for i=7
%     disp(idx);
%     eeg = dset_load_eeg('Fra', i, epoch,1:30);
%     if (isempty(eeg))
%         disp('EMPTY');
%         continue;
%     end
%     ca1Idx = strcmp('CA1', {eeg.area});
%     
%     eeg = eeg(ca1Idx);
%     
%     leftIdx = find(strcmp({eeg.hemisphere}, 'left'));
%     rightIdx = find(strcmp({eeg.hemisphere}, 'right'));
%     if numel(leftIdx)>2
%         baseChan = leftIdx(1);
%         ipsiChan = leftIdx(2);
%         contChan = rightIdx(1);
%     else
%         baseChan = rightIdx(1);
%         ipsiChan = rightIdx(2);
%         contChan = leftIdx(1);
%     end
%     
%     [freq(idx), dur(idx), amp(idx)] = calc_bilateral_ripple_stats(eeg, baseChan, ipsiChan, contChan);
%     
%     idx = idx+1;
% end
%%
figure; 
subplot(131);
boxplot([cell2mat({freq.baseVsIpsiCorr}); cell2mat({freq.baseVsContCorr})]', 'notch', 'on');

subplot(132);
boxplot([cell2mat({dur.baseVsIpsiCorr}); cell2mat({dur.baseVsContCorr})]', 'notch', 'on');

subplot(133);
boxplot([cell2mat({amp.baseVsIpsiCorr}); cell2mat({amp.baseVsContCorr})]', 'notch', 'on');
%% plot the relationship between ripple frequencies between the hemispheres
bib = [];
bii = [];
bcb = [];
bcc = [];

for i = 1:numel(freq)
    bib = [bib; freq(i).baseVsIpsi.base];
    bii = [bii; freq(i).baseVsIpsi.ipsi];
    bcb = [bcb; freq(i).baseVsCont.base];
    bcc = [bcc; freq(i).baseVsCont.cont];
    %dFreqIpsi = [dFreqIpsi; abs(freq(i).baseVsIpsi.base - freq(i).baseVsIpsi.ipsi)];
    %dFreqCont = [dFreqIpsi; abs(freq(i).baseVsCont.base - freq(i).baseVsCont.cont)];
end

a = [];

figure('Position', [ 403   644   749   310]);
a(1) = subplot(121);
plot(bib, bii, '.');
title('Ipsilateral Ripple Frequency')
a(2) = subplot(122);
plot(bcb, bcc, '.');
title('Contralateral Ripple Frequency')
linkaxes(a);
set(a,'XLim', [125 260], 'YLim', [125 260]);

disp('Frequency Comparisons');
[rho p] = corr(bib, bii, 'type', 'spearman');
fprintf('ipsilateral:\t %2.3f %2.2e\n', rho, p);
[rho p] = corr(bcb, bcc, 'type', 'spearman');
fprintf('contralateral:\t %2.3f %2.2e\n', rho, p);

%%
%% plot the relationship between ripple durations between the hemispheres
bib = [];
bii = [];
bcb = [];
bcc = [];

for i = 1:numel(freq)
    bib = [bib; dur(i).baseVsIpsi.base'];
    bii = [bii; dur(i).baseVsIpsi.ipsi'];
    bcb = [bcb; dur(i).baseVsCont.base'];
    bcc = [bcc; dur(i).baseVsCont.cont'];
    %dFreqIpsi = [dFreqIpsi; abs(freq(i).baseVsIpsi.base - freq(i).baseVsIpsi.ipsi)];
    %dFreqCont = [dFreqIpsi; abs(freq(i).baseVsCont.base - freq(i).baseVsCont.cont)];
end

a = [];

figure('Position', [ 403   644   749   310], 'Name', 'Ripple Duration Comparisons');
a(1) = subplot(121);
plot(bib, bii, '.');
title('Ipsilateral Ripple Duration')
a(2) = subplot(122);
plot(bcb, bcc, '.');
title('Contralateral Ripple Duration')
linkaxes(a);
set(a,'XLim', [0 .2], 'YLim', [0 .25]);


disp('Duration Comparisons');
[rho p] = corr(bib, bii, 'type', 'spearman');
fprintf('ipsilateral:\t %2.3f %2.2e\n', rho, p);
[rho p] = corr(bcb, bcc, 'type', 'spearman');
fprintf('contralateral:\t %2.3f %2.2e\n', rho, p);

%% plot the relationship between ripple Amplitude between the hemispheres
bib = [];
bii = [];
bcb = [];
bcc = [];

for i = 1:numel(freq)
    bib = [bib; amp(i).baseVsIpsi.base];
    bii = [bii; amp(i).baseVsIpsi.ipsi];
    bcb = [bcb; amp(i).baseVsCont.base];
    bcc = [bcc; amp(i).baseVsCont.cont];
    %dFreqIpsi = [dFreqIpsi; abs(freq(i).baseVsIpsi.base - freq(i).baseVsIpsi.ipsi)];
    %dFreqCont = [dFreqIpsi; abs(freq(i).baseVsCont.base - freq(i).baseVsCont.cont)];
end

a = [];

figure('Position', [ 403   644   749   310], 'Name', 'Ripple Amplitude Comparisons');
a(1) = subplot(121);
plot(bib, bii, '.');
title('Ipsilateral Ripple Amplitude')
a(2) = subplot(122);
plot(bcb, bcc, '.');
title('Contralateral Ripple Amplitude')

linkaxes(a);
set(a, 'Xlim', [0 6e5], 'Ylim', [0 6e5]);


disp('Amplitude Comparisons');
[rho p] = corr(bib, bii, 'type', 'spearman');
fprintf('ipsilateral:\t %2.3f %2.2e\n', rho, p);
[rho p] = corr(bcb, bcc, 'type', 'spearman');
fprintf('contralateral:\t %2.3f %2.2e\n', rho, p);


%%
[rhoIpsi pIpsi] = corr(bib, bii, 'type', 'spearman');
[rhoCont pCont] = corr(bcb, bcc, 'type', 'spearman');

z = ( atanh(rhoIpsi) - atanh(rhoCont) ) / sqrt( 1/(numel(bib)-3) + 1/(numel(bcb)-3) );


%% 
clearvars -except eeg ca1Idx 
%%
for i = 1:numel(eeg)
    [rippleWindows{i}, maxTimes{i}, ~, ripplePower{i}] = find_rip_burst(eeg(i).data, eeg(i).fs, eeg(i).starttime);
end

%% Select channels for analysis
baseChan = 3;
ipsiChan = 4;
contChan = 2;

%%
%% -- Ripple Frequency Analysis
%%
%% get the indecies of events that occur on both sets of channels
baseIdx = logical(zeros(size(maxTimes{baseChan})));
ipsiIdx = logical(zeros(size(maxTimes{baseChan})));
contIdx = logical(zeros(size(maxTimes{baseChan})));
minDt = .015;

nearestIpsi = interp1(maxTimes{ipsiChan}, maxTimes{ipsiChan}, maxTimes{baseChan}, 'nearest');
ipsiIdx = abs(nearestIpsi - maxTimes{baseChan}) <= minDt;

nearestCont = interp1(maxTimes{contChan}, maxTimes{contChan}, maxTimes{baseChan}, 'nearest');
contIdx = abs(nearestCont - maxTimes{baseChan}) <= minDt;


%% - Calculate the dominant frequency for the selected events
[bvbRipFreq bvbSpec bvbFreq] = dset_calc_event_peak_freq(eeg(baseChan).data, eeg(baseChan).starttime, eeg(baseChan).fs, maxTimes{baseChan});
[bviRipFreq bviSpec bviFreq] = dset_calc_event_peak_freq(eeg(ipsiChan).data, eeg(ipsiChan).starttime, eeg(ipsiChan).fs, maxTimes{baseChan}(ipsiIdx));
[bvcRipFreq bvcSpec bvcFreq] = dset_calc_event_peak_freq(eeg(contChan).data, eeg(contChan).starttime, eeg(contChan).fs, maxTimes{baseChan}(contIdx));

bviRho = corr(bvbRipFreq(ipsiIdx)', bviRipFreq');
bvcRho = corr(bvbRipFreq(contIdx)', bvcRipFreq');


%% Plot the dominant frequency relationships
figure('Position', [300 300 300 700]);
subplot(211);

plot(bvbRipFreq(ipsiIdx), bviRipFreq, '.');
title(['Correlation: ', num2str(round(bviRho*100)/100)]);

subplot(212);
plot(bvbRipFreq(contIdx), bvcRipFreq, '.');
title(['Correlation: ', num2str(round(bvcRho*100)/100)]);

%%
%% -- Ripple Duration Analysis
%%
%% get event durations
baseDuration = diff(rippleWindows{baseChan}');
ipsiDuration = diff(rippleWindows{ipsiChan}');
contDuration = diff(rippleWindows{contChan}');
%% get indices of overlapping time windows

[baseIdxIpsi ipsiIdxIpsi] = calc_time_window_overlap(rippleWindows{baseChan}, rippleWindows{ipsiChan});
[baseIdxCont contIdxCont] = calc_time_window_overlap(rippleWindows{baseChan}, rippleWindows{contChan});

%% Plot the overlaps to make sure they are real
% figure;
% axes;
% for i = 1:numel(baseIdxIpsi)
%    line(rippleWindows{baseChan}(baseIdxIpsi(i),:), repmat([0+.1*i],1,2));
%    line(rippleWindows{ipsiChan}(ipsiIdxIpsi(i),:), repmat([0+.1*i]+.05,1,2), 'color', 'red');
% end
%%

figure('Position', [300 300 300 700]);
subplot(211);

bviRhoDur = corr(baseDuration(baseIdxIpsi)', ipsiDuration(ipsiIdxIpsi)');
bvcRhoDur = corr(baseDuration(baseIdxCont)', contDuration(contIdxCont)');

plot(baseDuration(baseIdxIpsi), ipsiDuration(ipsiIdxIpsi),'.');
title(['Correlation: ', num2str(round(bviRhoDur*100)/100)]);
subplot(212);

plot(baseDuration(baseIdxCont), contDuration(contIdxCont),'.');
title(['Correlation: ', num2str(round(bvcRhoDur*100)/100)]);

set(get(gcf, 'Children'), 'Xlim', [0 .14], 'YLim', [0 .14]);

%%
%% -- Ripple Power Analysis
%%



figure('Position', [300 300 300 700]);

bviRhoPow = corr(ripplePower{baseChan}(baseIdxIpsi)', ripplePower{ipsiChan}(ipsiIdxIpsi)');
bvcRhoPow = corr(ripplePower{baseChan}(baseIdxCont)', ripplePower{contChan}(contIdxCont)');

subplot(211);

plot(ripplePower{baseChan}(baseIdxIpsi), ripplePower{ipsiChan}(ipsiIdxIpsi),'.');
title(['Correlation: ', num2str(round(bviRhoPow*100)/100)]);
subplot(212);

plot(ripplePower{baseChan}(baseIdxCont), ripplePower{contChan}(contIdxCont),'.');
title(['Correlation: ', num2str(round(bvcRhoPow*100)/100)]);
set(get(gcf,'Children'), 'Xlim', [0 5e5], 'YLim', [0 5e5]);

