
clearvars -except MultiUnit LFP

iriPk = [];
iriOn = [];

N = numel(LFP);
Fs = timestamp2fs(LFP{1}.ts);
lastFr = [];
firstFr = [];
%%
for i = 6 : N
    
    fprintf('%d ', i);
    mu = MultiUnit{i};
    eeg = LFP{i};
    
    [ripIdx, ripWin] = detectRipples(eeg.ripple, eeg.rippleEnv, Fs);
    ripFr = [];
    
    iFreq = calc_inst_freq(eeg.ripple, Fs);
    
    for ii = 1:numel(ripIdx)
%         [~, pks] = findpeaks( eeg.ripple( ripWin(ii,1):ripWin(ii,2) ) );
%         ripFr(i) = Fs / mean( diff(pks) );        
        ripFr(ii) = nanmean( iFreq( ripWin(ii,1):ripWin(ii,2) ) );
    end
    
    
    ripTs = eeg.ts(ripIdx);
    [setIdx, soloIdx, setLen] = filter_event_sets(ripTs, 3, [1 .15 1] );
    
%     setIdx = cell2mat(arrayfun(@colon, setIdx, setIdx+setLen, 'UniformOutput', 0)');
        
    lastFr = [lastFr, ripFr(setIdx + setLen)];
    firstFr = [firstFr, ripFr(setIdx)];
end

fprintf('\n');

%%
[f1,x1] = ksdensity(lastFr);
[f2,x2] = ksdensity(firstFr);

figure;
axes;
line(x1,f1,'color','r');
line(x2,f2,'color','g');


%%
bins = 0:10:500;

idx = iriPk <.5;
iri = iriPk(idx);
fr = ripFr(idx);


g = ones(size(fr)) * 4;
g( iri < .375) = 3;
g( iri < .25) = 2;
g( iri < .125) =1;

close all; figure;
boxplot(fr, g, 'notch', 'on');


%%


pkIri = iriPk * 1000;
pkIri = pkIri(pkIri < 500);


figure('Position', [100 260 600 300]);
axes('FontSize', 14);

ksdensity(pkIri, 'Support', 'positive');
xlabel('Interval(ms)');
ylabel('Probability');

plot2svg('/data/HPC_RSC/inter_ripple_interval.svg',gcf);



%%
ctsPk = histc(pkIri, bins);
ctsOn = histc(onIri, bins);


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










