function result = dset_calc_replay_corr_perspike_dist(dset)

nEvent = numel(st(1).percentCells);

per1 = st(1).percentCells; 
per2 = st(2).percentCells; 

nSpike1 = sum(reconSimp(1).spike_counts);
nSpike2 = sum(reconSimp(2).spike_counts);

bursts = dset.mu.bursts;
nBurst = size(bursts,1);
eventCorr = nan(nBurst,1);

posDist = [];

for i = 1:nBurst
    
    idx = reconSimp(1).tbins >= bursts(i,1) & reconSimp(1).tbins <= bursts(i,2) & logical(nSpike1)' & logical(nSpike2)';
    
    [~, p1] = max( reconSimp(1).pdf(:,idx));
    [~, p2] = max( reconSimp(2).pdf(:,idx));
    
    posDist = [posDist, calc_posidx_distance(p1, p2, dset.clusters(1).pf_edges)];
       
    eventCorr(i) = mean( corr_col( reconSimp(1).pdf(:, idx), reconSimp(2).pdf(:, idx) ) );  
    
end

validIdx = ~isnan(eventCorr);
per1 = per1(validIdx);
per2 = per2(validIdx);

thL1 = median(per1);
thL2 = median(per2);

thH1 = median(per1);
thH2 = median(per2);

idxLow = st(1).percentCells < thL1 & st(2).percentCells < thL2;
idxHigh = st(1).percentCells >= thH1 & st(2).percentCells >= thH2;


cat = nan * idxLow;
cat(idxLow) = 1;
cat(idxHigh) = 2;

%% - Compare the PDF correlations based upon % of cells active
highPerCorr = eventCorr(idxHigh);
lowPerCorr = eventCorr(idxLow);


[h1, p1] = kstest2(highPerCorr, lowPerCorr, .05, 'smaller');
[h2, p2] = cmtest2(highPerCorr, lowPerCorr);

fprintf('\n\nNLow:%d NHigh:%d\n', nnz(idxLow), nnz(idxHigh));
fprintf('KS:%3.3f CM:%3.3f\n', p1, p2);

figure;

subplot(221); 
hist(lowPerCorr, -1:.125:1); set(gca,'XLim', [-1 1]);

subplot(222);
hist(highPerCorr, -1:.125:1); set(gca,'XLim', [-1 1]);

subplot(223);
ecdf(highPerCorr); hold on; ecdf(lPerCorr); c = get(gca,'Children'); set(c(1), 'Color', 'r');
legend({'high', 'low'}, 'location', 'northwest');

subplot(224);
boxplot(eventCorr, cat);

%% - Compute the distances between the PDF based upon % of cells active
highPerDist = posDist(idxHigh);
lowPerDist = posDist(idxLow);

[h1, p1] = kstest2(highPerDist, lowPerDist, .05, 'smaller');
[h2, p2] = cmtest2(highPerDist, lowPerDist);

fprintf('\n\nNLow:%d NHigh:%d\n', nnz(idxLow), nnz(idxHigh));
fprintf('KS:%3.3f CM:%3.3f\n', p1, p2);

figure;

subplot(221); 
hist(lowPerDist, 0:60); set(gca,'Xlim', [-1 61]);

subplot(222);
hist(highPerDist, 0:60); set(gca,'Xlim', [-1 61]);

subplot(223);
ecdf(highPerDist); hold on; ecdf(lowPerDist); c = get(gca,'Children'); set(c(1), 'Color', 'r');
legend({'high', 'low'}, 'location', 'southeast');

subplot(224);
boxplot(posDist, cat);
%%
d1 = highPerCorr( isfinite( highPerCorr) );
d2 = lowPerCorr( isfinite( lowPerCorr) );
n1 = numel(d1);
n2 = numel(d2);

Z = ( mean(d1) - mean(d2) ) / sqrt( std(d1)/sqrt(n1) + std(d2)/sqrt(numel(d2)))


%% 
% nEvent = numel(st(1).percentCells);
% 
% per1 = st(1).percentCells; 
% per2 = st(2).percentCells; 
% 
% % per1Sorted = sort(per1);
% % per2Sorted = sort(per2);
% % 
% % cutOffLow = .5;
% % cutOffHigh = .5;
% % 
% % thL1 = per1Sorted( round( nEvent * cutOffLow ) );
% % thL2 = per2Sorted( round( nEvent * cutOffHigh ) );
% % 
% % thH1 = per1Sorted( round( nEvent * cutOffLow ) );
% % thH2 = per2Sorted( round( nEvent * cutOffHigh ) );
% 
% thL1 = median(per1);
% thL2 = median(per2);
% 
% thH1 = median(per1);
% thH2 = median(per2);
% 
% idxLow = st(1).percentCells < thL1 & st(2).percentCells < thL2;
% idxHigh = st(1).percentCells >= thH1 & st(2).percentCells >= thH2;
% 
% eventCorr = [];
% 
% bursts = dset.mu.bursts;
% 
% nSpike1 = sum(reconSimp(1).spike_counts);
% nSpike2 = sum(reconSimp(2).spike_counts);
% 
% lowPerCorr =[];
% highPerCorr = [];
% 
% for i = 1:size(bursts,1)
%     tsIdx = reconSimp(1).tbins >= bursts(i,1) & reconSimp(1).tbins <= bursts(i,2);
% 
%     idx = tsIdx & logical(nSpike1)' & logical(nSpike2)';
%     
% %     if nnz(idx)<2
% %         idx(idx) = 0;
% %     end
%     
%     eventCorr(i) = mean( corr_col( reconSimp(1).pdf(:, idx), reconSimp(2).pdf(:, idx) ) );    
%     
%     if idxLow(i) == 1
%         lowPerCorr = [lowPerCorr, corr_col( reconSimp(1).pdf(:, idx), reconSimp(2).pdf(:, idx) ) ];
%     elseif idxHigh(i) == 1
%         highPerCorr = [highPerCorr, corr_col( reconSimp(1).pdf(:, idx), reconSimp(2).pdf(:, idx) ) ];
%     end
% end
% 
% cat = nan * idxLow;
% cat(idxLow) = 1;
% cat(idxHigh) = 2;
% 
% 
% highPerCorr = eventCorr(idxHigh);
% lowPerCorr = eventCorr(idxLow);
% 
% [h1, p1] = kstest2(highPerCorr, lowPerCorr, .05, 'smaller');
% [h2, p2] = cmtest2(highPerCorr, lowPerCorr);
% 
% fprintf('\n\nNLow:%d NHigh:%d\n', nnz(idxLow), nnz(idxHigh));
% fprintf('KS:%3.3f CM:%3.3f\n', p1, p2);
% 
% figure;
% 
% subplot(221); 
% hist(lowPerCorr, -1:.1:1); set(gca,'XLim', [-1 1]);
% 
% subplot(222);
% hist(highPerCorr, -1:.1:1); set(gca,'XLim', [-1 1]);
% 
% subplot(223);
% ecdf(highPerCorr); hold on; ecdf(lPerCorr); c = get(gca,'Children'); set(c(1), 'Color', 'r');
% legend({'high', 'low'}, 'location', 'northwest');
% 
% subplot(224);
% boxplot(eventCorr, cat);
