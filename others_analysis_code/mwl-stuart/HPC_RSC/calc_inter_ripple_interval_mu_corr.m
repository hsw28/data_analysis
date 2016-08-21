
clearvars -except MultiUnit LFP

iriHC = [];
iriLC = [];

N = numel(LFP);
Fs = timestamp2fs(LFP{1}.ts);

corrThold = 0;
for i = 1 : N
    
    fprintf('%d ', i);
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    [muCorr, corrTs] = calc_rolling_corr(mu.ts, mu.hpc, mu.ctx);
    [ripIdx, ripWin] = detectRipples(eeg.ripple, eeg.rippleEnv, Fs);
    
    ripPkTs = eeg.ts(ripIdx);
    ripOnTs = eeg.ts(ripWin(:,1));
    
    ripCorr = interp1(corrTs, muCorr, ripPkTs, 'nearest');
    tsH = ripPkTs( ripCorr > corrThold );
    tsL = ripPkTs( ripCorr < -1 * corrThold );
    
    iriHC = [iriHC, diff(tsH)];
    iriLC = [iriLC, diff(tsL)];
  
end
fprintf('\n');

%%
bins = 0:10:500;

hIri = iriHC * 1000;
lIri = iriLC * 1000;
hIri = hIri(hIri < 250);
lIri = lIri(lIri < 250);

[numel(hIri) numel(lIri)]

figure;
subplot(211); ksdensity(hIri, 'Support', 'positive');
subplot(212); ksdensity(lIri, 'Support', 'Positive');

%%
ctsPk = histc(hIri, bins);
ctsOn = histc(lIri, bins);


%%


figure('Position', [100 260 560 420]);
ax(1) = subplot(211);
ax(2) = subplot(212);
set(ax,'FontSize', 14);

line(ts, mean(hpcTrip), 'color', 'r', 'Parent', ax(1));
line(ts, mean(hpcSolo), 'color', 'k', 'Parent', ax(1));
title(ax(1), 'Ripple Triggered HPC MU Rate');
legend(ax(1), 'Sets', 'Solo');

line(ts, mean(ctxTrip), 'color', 'r', 'Parent', ax(2));
line(ts, mean(ctxSolo), 'color', 'k', 'Parent', ax(2));
title(ax(2), 'Ripple Triggered CTX MU Rate');


set(ax,'XLim', win);
plot2svg('/data/HPC_RSC/ripple_triggered_mu_rate.svg',gcf);
% 
% figure('Position', [150 210 560 420]);
% ax(1) = subplot(211);
% ax(2) = subplot(212);
% set(ax,'FontSize', 14);
% 
% line(ts, mean(hpcTrip) ./ max( mean(hpcTrip)), 'color', 'r', 'Parent', ax(1));
% line(ts, mean(ctxTrip) ./ max( mean(ctxTrip)), 'color', 'k', 'Parent', ax(1));
% title(ax(1),'Ripple-Set Triggered MU Rate');
% legend(ax(1), 'HPC', 'CTX');
% 
% line(ts, mean(hpcSolo) ./ max( mean(hpcSolo)) , 'color', 'r', 'Parent', ax(2));
% line(ts, mean(ctxSolo) ./ max( mean(ctxSolo)) , 'color', 'k', 'Parent', ax(2));
% title(ax(2),'Solo-Ripple Triggered MU Rate');
% 
% 
% set(ax,'XLim', win);
%%
clear
allRipples = dset_load_ripples;
%%

tripIri = [];
allIri = [];

ripples = allRipples.sleep;

for iExp = 1:numel(ripples)

    rips = ripples(iExp);

    ripOnTs = rips.peakIdx /rips.fs;

    ripLen = diff(rips.eventOnOffIdx, [], 2);

    realTripIdx = filter_event_sets(ripOnTs, 3, [.5 .25 .25]);

    realTripTs = ripOnTs(realTripIdx);

    iriReal = [50; diff(ripOnTs)];

    realSetIdx = false(size(ripOnTs));

    for iRip = 1:numel(realTripTs)
        realSetIdx = realSetIdx | ( ripOnTs > realTripTs(iRip) & ripOnTs < realTripTs(iRip) + 1 );
    end
    
    tripIri = [tripIri; iriReal(realSetIdx)];
    allIri = [allIri; iriReal];

end


allIri = allIri * 1000;
tripIri = tripIri * 1000;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         KDE - Inter Ripple Intervals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot(b, hTrip.sleep{1}); hold on;

[kAll, X] = ksdensity(allIri( allIri < 1000) , 0:1000, 'support', [0 1000], 'width', .25);
[kTrip, ~] = ksdensity(tripIri( tripIri < 1000) , 0:1000, 'support', [0 1000], 'width', .25);

[~, pkIdx] = findpeaks(kTrip);

idx = 1:500;

f = figure;
line( X(idx), kAll(idx) );
line( X(idx), kTrip(idx), 'color', 'r');

legend({'All Ripples', 'Triplets'});
distPeakTs = X(pkIdx(2));
line(distPeakTs * [1 1], [0 max(kAll)*1.1]);

set(gca,'XTick', [0 distPeakTs 100], 'XLim', [0 500])

figName = 'figure3-InterRipIntervalDistribution';



%%

longIri = allIri(allIri/1000 < 10)/ 1000; 
short = allIri( allIri<1000 );
close all;
figure;

subplot(211)
hist(longIri, 0:.1:10);

set(gca,'XTick', [0:10], 'XLim', [-.1 10.1]);

subplot(212); hold on;
hist(short, (0:10:1000))

set(gca,'XTick', 0:100:1000, 'XLim', [-10 1010]);

[F, X] = ksdensity( short, 0:1:1000, 'support', 'positive', 'width', .2);
line(X,F * 15000,'Color', 'r', 'LineWidth', 1);



title('Inter Ripple Interval')




%%


%%
% 
% b = 0 : 0.0025 : 0.25;
% 
% 
% for ep = {'sleep', 'run'}
%     
%     ep = char(ep);
%    
%     for i = 1:2
%         hTrip.(ep){i} = histc(tripIri.(ep){i}, b);
%         hAll.(ep){i} = histc(allIri.(ep){i}, b);
% 
%         hTrip.(ep){i} = hTrip.(ep){i}./sum(hTrip.(ep){i});
%         hAll.(ep){i} = hAll.(ep){i}./sum(hAll.(ep){i});
%         
%         hTrip.(ep){i} = smoothn(hTrip.(ep){i}, 2);
%         hAll.(ep){i} = smoothn(hAll.(ep){i}, 2);
%     end
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Inter Ripple Intervals
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     f = figure('Position', [150 500 900 400]);
%     ax = [];
%     ax(1) = subplot(121);
% 
%     line(b, hTrip.sleep{1}, 'color', 'b', 'Parent', ax(1), 'linewidth', 2);
%     line(b, hAll.sleep{1}, 'color', 'r', 'Parent', ax(1), 'linewidth', 2);
% 
%     %line(b, hTrip.sleep{2}, 'color', 'r', 'Parent', ax(1), 'linewidth', 2)
%     
%     title('Sleep');
%     legend('Triplets', 'All Ripples');
% 
%     ax(2) = subplot(122);
%     
%     line(b, hTrip.run{1}, 'color', 'b', 'Parent', ax(2), 'linewidth', 2);
%     line(b, hAll.run{1}, 'color', 'r', 'Parent', ax(2), 'linewidth', 2);
% 
%     title('Run');
%     legend('Triplets', 'All Ripples');
%     
%     
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%% Inter Ripple Intervals - JITTERED
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% 
%     f = figure('Position', [250 400 900 400]);
%     ax = [];
%     ax(1) = subplot(121);
% 
%     line(b, hTrip.sleep{2}, 'color', 'b', 'Parent', ax(1), 'linewidth', 2);
%     line(b, hAll.sleep{2}, 'color', 'r', 'Parent', ax(1), 'linewidth', 2);
% 
%     %line(b, hTrip.sleep{2}, 'color', 'r', 'Parent', ax(1), 'linewidth', 2)
%     
%     title('Sleep - Jittered');
%     legend('Triplets', 'All Ripples');
% 
%     ax(2) = subplot(122);
%     
%     line(b, hTrip.run{2}, 'color', 'b', 'Parent', ax(2), 'linewidth', 2);
%     line(b, hAll.run{2}, 'color', 'r', 'Parent', ax(2), 'linewidth', 2);
% 
%     title('Run - Jittered');
%     legend('Triplets', 'All Ripples');
% 
%     set(ax,'XLim', [0 .25]);

    %%

b = 0:10:1000;
figure; 

subplot(121)
hist(iriSleep * 1000, b);
title('Sleep IRI')

subplot(122);
hist(iriRun * 1000, b);
title('Sleep IRI')

set(get(gcf,'Children'), 'XLim', [0 450]);


    %% Fit the IRI distributions to an INVERSE GAUSSIAN distribution
    
    figure;
        
    ax = axes('NextPlot', 'add');
    X = allIri.sleep{i};
    X = X(X<.25);
    h = histc(X, b);
    h = smoothn(h, 2, 'correct', 1);
    h = h/max(h);
    
    line(b, h, 'Color', 'b', 'linewidth', 2,'Parent', ax); 
    
    probDistSleep = fitdist(X, 'gamma');
    pdfSleep = probDistSleep.pdf(b);
    pdfSleep = pdfSleep ./ max(pdfSleep);
    
    line(b, pdfSleep, 'color', 'k', 'linewidth', 2);










