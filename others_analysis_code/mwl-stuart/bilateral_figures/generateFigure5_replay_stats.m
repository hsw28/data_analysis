function [t1 t2 t3 r1 r2 r3] =  generateFigure5_replay_stats(ep)
%%

clear stats cHigh cLow stats
eList = dset_list_epochs(ep);
nEpoch = size(eList,1);


for i = 1:nEpoch
    %%
    d = dset_load_all( eList{i,:} );
    
    lIdx = strcmp({d.clusters.hemisphere}, 'left');
    rIdx = strcmp({d.clusters.hemisphere}, 'right');
    
 
    args = {'time_win', d.epochTime, 'tau', .02};
    
    recon(1) = dset_reconstruct(d.clusters(lIdx), args{:} );
    recon(2) = dset_reconstruct(d.clusters(rIdx), args{:} );
    
    [cHigh(i), cLow(i), stats(i)] = dset_compare_bilateral_pdf_by_n_mu_spike(d, recon);
    
end

%%

bC = [stats.burstCorr]';
bS = [stats.burstCorr]';
for i = 1:10
   nBurst = numel(stats(i).burstRate{1});
   
   idx = randsample(nBurst, nBurst, 1);
   
   bS(i) = corr( stats(i).burstRate{1}(idx), stats(i).burstRate{2});
end
close all;

figure;
s = stats(9);
bins = 0:.025:1;

b1 = s.burstRate{1};
b2 = s.burstRate{2};

b1 = b1 - min(b1);
b2 = b2 - min(b2);
b1 = b1 ./ max(b1);
b2 = b2 ./ max(b2);
cts = hist3( [b1 , b2 ], {bins, bins});


subplot(1,3,1:2);

imagesc(bins, bins, cts);
set(gca,'YDir', 'normal');

subplot(133)
set(gca, 'NextPlot', 'add');

line(1:2, [bC, bS], 'color', [.8 .8 .8]);
boxplot([bC, bS]);
set(gca,'XTick', [1, 2], 'XTickLabel', {'Coincident', 'Shuffled'});
    
%%

f = figure;
axes('NextPlot', 'add');

line([1 2], [cLow', cHigh'], 'color', [.8 .8 .8]);
boxplot([cLow', cHigh']); 

p = signrank( cLow, cHigh, 'tail', 'left');
title( sprintf( 'SignRank:%4.4f', p) );

set(gca,'XTick', [1 2], 'XTickLabel', {'Low', 'High'});


figName = sprintf('Figure5-EventCorr-BurstRate-boxplot-%s',ep);
save_bilat_figure(figName, f);

%%

bC = [stats.burstCorr]';
bS = [stats.burstCorr]';
for i = 1:10
   nBurst = numel(stats(i).burstRate{1});
   
   idx = randsample(nBurst, nBurst, 1);
   
   bS(i) = corr( stats(i).burstRate{1}(idx), stats(i).burstRate{2});
end
close all;

figure;
s = stats(9);
bins = 0:.025:1;

b1 = s.burstRate{1};
b2 = s.burstRate{2};

b1 = b1 - min(b1);
b2 = b2 - min(b2);
b1 = b1 ./ max(b1);
b2 = b2 ./ max(b2);
cts = hist3( [b1 , b2 ], {bins, bins});

cts = smoothn(cts, .5);
cts = cts - min(cts(:));
cts = cts ./ max(cts(:));
cts = 1 - repmat( cts, [1 1 3]);

subplot(1,3,1:2);

imagesc(bins, bins, cts);
set(gca,'YDir', 'normal');

subplot(133)
set(gca, 'NextPlot', 'add');

line(1:2, [bC, bS], 'color', [.8 .8 .8]);
boxplot([bC, bS]);
set(gca,'XTick', [1, 2], 'XTickLabel', {'Coincident', 'Shuffled'});


figure('Position', get(gcf,'Position') + [100 0 0 0]);


subplot(1,3,1:2);

plot(b1, b2, '.');


subplot(133)
set(gca, 'NextPlot', 'add');

line(1:2, [bC, bS], 'color', [.8 .8 .8]);
boxplot([bC, bS]);
set(gca,'XTick', [1, 2], 'XTickLabel', {'Coincident', 'Shuffled'});

cts = imresize(cts, 5, 'method', 'nearest');
imwrite(cts, '~/Desktop/Bilateral_MU_BurstRate_Dist.png', 'png');
    
%%

f = figure();
axes('NextPlot', 'add');

line([1 2], [cLow', cHigh'], 'color', [.8 .8 .8]);
boxplot([cLow', cHigh']); 

p = signrank( cLow, cHigh, 'tail', 'left');
title( sprintf( 'SignRank:%4.4f', p) );

set(gca,'XTick', [1 2], 'XTickLabel', {'Low', 'High'});


figName = sprintf('Figure5-EventCorr-BurstRate-boxplot-%s',ep);
save_bilat_figure(figName, f);



%%
% 
% s = stats(6);
% eventCorr = s.colCorr;
% 
% bRateL = s.burstRate{1};
% bRateR = s.burstRate{2};
% 
% tholdL = quantile(bRateL, .5);
% tholdR = quantile(bRateR, .5);
% 
% idxLow  = bRateL < tholdL & bRateR < tholdR;
% idxHigh = bRateL > tholdL & bRateR > tholdR;
% % idxHigh = n > quantile(n, .75);
% 
% corrLow = mean( eventCorr( idxLow) );
% corrHigh = mean( eventCorr( idxHigh ) );

% %%
% 
% figure;
% axes('NextPlot', 'add');
% 
% w = .35;
% bins = -1:.05:1;
% [F2, X2, U2] = ksdensity(eventCorr( idxLow) , bins, 'support', [-1 1], 'Width', w);  
% [F3, X3, U3] = ksdensity(eventCorr( idxHigh) ,bins, 'support', [-1 1], 'Width', w); 
% 
% % line(X1, F1, 'Color', 'k');
% line(X2, F2, 'Color', 'g');
% line(X3, F3, 'Color', 'r');
% 
% legend({'Low Rate`', 'High Rate'});
% 
% 
% figure;
% g = 0 .* eventCorr;
% g(idxLow) = 1;
% g(idxHigh) = 2;
% 
% boxplot(eventCorr,g, 'notch', 'on');
% 
% 
% %% 
% 
% for i = 1:numel(stats)
% 
%     s = stats(i);
%     eventCorr = s.colCorr;
% 
%     bRateL = s.burstRate{1};
%     bRateR = s.burstRate{2};
% 
%     tholdL = quantile(bRateL, .5);
%     tholdR = quantile(bRateR, .5);
% 
%     idxLow  = bRateL < tholdL & bRateR < tholdR;
%     idxHigh = bRateL > tholdL & bRateR > tholdR;
%     % idxHigh = n > quantile(n, .75);
% 
%     corrLow = eventCorr( idxLow);
%     corrHigh = eventCorr( idxHigh );
%     
%     [~, p] = ttest2(eventCorr(idxLow), eventCorr(idxHigh), .05,  'left');
%     if p<.05
%         i
%     end
% end
% 
% 
% 
% %%
% 
% 
% % %%
% % h = cHigh;
% % l = cLow;
% % s = stats;
% % 
% % C = {stats.colCorr};
% % N = {stats.nSpike};
% % 
% % hh = [];
% % ll = [];
% % 
% % hhh = [];
% % lll = [];
% % for i = 1:nEpoch
% %     
% %     c = C{i};
% %     n = N{i};
% %     
% %     quantile(n, .5)
% %     idxM = n < quantile(n, .5);
% %     idxL = n < quantile(n, .33);
% %     idxH = n > quantile(n, .66);
% %     
% %     ll(end+1) = mean(c(idxL));
% %     hh(end+1) = mean(c(idxH));   
% %     
% %     lll(end+1) = mean(c(idxM));
% %     hhh(end+1) = mean(c(~idxM));
% %  
% % end
% % 
% % 
% % fig = figure('Name', ep);
% % subplot(131);
% % boxplot([l', h']); hold on;
% % line([1 2], [l', h'])
% % set(gca,'XTick', [1 2], 'XTickLabel', {'<25%', '>75%'});
% % [~, t1] = ttest2(h, l, .05, 'right');
% % r1 = ranksum(h, l, 'tail', 'right');
% % title( sprintf('%2.3g %2.3g', [t1, r1]))
% % 
% % subplot(132);
% % boxplot([ll', hh']); hold on;
% % set(gca,'XTick', [1 2], 'XTickLabel', {'<33%', '>66%'});
% % [~, t2] = ttest2(hh, ll, .05, 'right');
% % r2 = ranksum(hh, ll, 'tail', 'right');
% % title( sprintf('%2.3g %2.3g', [t2, r2]))
% % 
% % 
% % subplot(133);
% % boxplot([lll', hhh']); hold on;
% % set(gca,'XTick', [1 2], 'XTickLabel', {'<50%', '>50%'});
% % [~, t3] = ttest2(hhh, lll, .05, 'right');
% % r3 = ranksum(hhh, lll, 'tail', 'right');
% % title( sprintf('%2.3g %2.3g', [t3, r3]))
% % 
% % set( get(gcf,'Children'), 'YLim', [-.1 1]);
% 
% 
% 
% %%
% eList(find( (h' - l') < 0), :)
% 
% 
% %%
end
