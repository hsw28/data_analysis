function [results, idxHigh, idxLow] = dset_compare_bilateral_pdf_by_percent_cell_active(dset, st, reconSimp)

per1 = st(1).percentCells; 
per2 = st(2).percentCells; 

nSpike1 = sum(reconSimp(1).spike_counts);
nSpike2 = sum(reconSimp(2).spike_counts);

bursts = dset.mu.bursts;
nBurst = size(bursts,1);

posDist = [];
eventCorr = nan(nBurst,1);

for i = 1:nBurst
    
    idx = reconSimp(1).tbins >= bursts(i,1) & reconSimp(1).tbins <= bursts(i,2) & logical(nSpike1)' & logical(nSpike2)';
    
    [~, p1] = max( reconSimp(1).pdf(:,idx));
    [~, p2] = max( reconSimp(2).pdf(:,idx));
    
%     posDist = [posDist, calc_posidx_distance(p1, p2, dset.clusters(1).pf_edges)];
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

%% - Compute the distances between the PDF based upon % of cells active
% highPerDist = posDist(idxHigh);
% lowPerDist = posDist(idxLow);

highPerCorr = eventCorr(idxHigh);
lowPerCorr = eventCorr(idxLow);


[~, results.pVal] = kstest2(highPerCorr, lowPerCorr, .05, 'smaller');
% % [~, results.cmtest_corr] = cmtest2(highPerCorr, lowPerCorr);
% 
% [~, results.kstest_dist] = kstest2(highPerDist, lowPerDist, .05, 'larger');
% [~, results.cmtest_dist] = cmtest2(highPerDist, lowPerDist);

% results.highPerDist = highPerDist';
% results.lowPerDist = lowPerDist';

results.highPerCorr = highPerCorr;
results.lowPerCorr = lowPerCorr;


% function results = dset_compare_bilateral_pdf_by_percent_cell_active(st, rp, dset)
% 
% % 
% % replayPdf1 = reconStat(1).pdf;
% % replayPdf2 = reconStat(2).pdf;
% % 
% % validIdx = find(reconStat(1).percentCells > 0 & reconStat(2).percentCells >0);
% % 
% % per1 = reconStat(1).percentCells(validIdx);
% % per2 = reconStat(2).percentCells(validIdx);
% % 
% % 
% % 
% % replayCorr = [];
% % for i = 1 : numel( validIdx);
% %     idx = validIdx(i);
% %     
% %     for j = 1
% %         replayCorr(j,i) = mean( corr_col( replayPdf1{idx,j}, replayPdf2{idx,j} ) );
% %     end 
% %     
% % end
% % % replayCorr = max(replayCorr);
% % 
% % 
% % th1 = median(per1);
% % th2 = median(per2);
% % 
% % highIdx = per1 > th1 & per2 > th2;
% % lowIdx = per1 <= th1  & per2 <= th2;
% % 
% % 
% % highCorr = replayCorr(highIdx);
% % lowCorr = replayCorr(lowIdx);
% % 
% % [h, pVal] = kstest2(highCorr, lowCorr);
% % 
% % results.highPerCorr = highCorr;
% % results.lowPerCorr = lowCorr;
% % results.pVal = pVal
% % %%
% % 
% % bins = -1:.02:1;
% % 
% % figure;
% % [lowCts, ctr] = hist(lowCorr, bins);
% % [highCts, ctr] = hist(highCorr, bins);
% % 
% % lowCts = lowCts ./ sum(lowCts);
% % highCts = highCts ./ sum(highCts);
% % 
% % lowCts = smoothn(lowCts, 2, 'correct', 1);
% % highCts = smoothn(highCts,2 , 'correct', 1);
% % 
% % line(ctr, lowCts, 'color', 'r');
% % line(ctr, highCts, 'color', 'g');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                         Version 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % nSpikes1 = sum(recon(1).spike_counts);
% % nSpikes2 = sum(recon(2).spike_counts);
% % replayIdx = recon(1).replayIdx;
% % 
% % replayPdf1 = recon(1).pdf;
% % replayPdf2 = recon(2).pdf;
% % 
% % validIdx = nSpikes1>0 & nSpikes2>0 & replayIdx';
% % 
% % nSpikes1 = nSpikes1(validIdx);
% % nSpikes2 = nSpikes2(validIdx);
% % 
% % for i = 1:3
% %     replayPdf1{i} = replayPdf1{i}(:, validIdx);
% %     replayPdf2{i} = replayPdf2{i}(:, validIdx);
% % end
% % 
% % 
% % th1 = median(nSpikes1) ;
% % th2 = median(nSpikes2) ;
% % 
% % highIdx = nSpikes1 >= th1 & nSpikes2 >= th2;
% % lowIdx = nSpikes1 < max(th1, 1.01)  & nSpikes2 < max(th2, 1.01);
% % 
% % for i = 1:3
% %     pdfCorr(i,:) = corr_col(replayPdf1{i}, replayPdf2{i});
% % end
% % 
% % pdfCorr = max(pdfCorr);
% % 
% % highCorr = pdfCorr(highIdx);
% % lowCorr = pdfCorr(lowIdx);
% % 
% % [h, pVal] = kstest2(highCorr, lowCorr);
% % 
% % results.highPerCorr = highCorr;
% % results.lowPerCorr = lowCorr;
% % results.pVal = pVal;
% % %%
% % 
% % bins = -1:.01:1;
% % 
% % figure;
% % [lowCts, ctr] = hist(lowCorr, bins);
% % [highCts, ctr] = hist(highCorr, bins);
% % 
% % lowCts = lowCts ./ sum(lowCts);
% % highCts = highCts ./ sum(highCts);
% % 
% % lowCts = smoothn(lowCts, 2, 'correct', 1);
% % highCts = smoothn(highCts,2 , 'correct', 1);
% % 
% % line(ctr, lowCts, 'color', 'r');
% % line(ctr, highCts, 'color', 'g');
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%                                  Original Code
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% per1 = st(1).percentCells; 
% per2 = st(2).percentCells; 

% 
% nSpike1 = sum( rp(1).spike_counts);
% nSpike2 = sum( rp(2).spike_counts);
% 
% bursts = dset.mu.bursts;
% nBurst = size(bursts,1);
% 
% posDist = [];
% eventCorr = nan(nBurst,3);
% 
% for i = 1:nBurst
%     
%     idx = rp(1).tbins >= bursts(i,1) &  rp(1).tbins <= bursts(i,2) & logical(nSpike1)' & logical(nSpike2)';
%     
% %     [~, p1] = max(  rp(1).pdf(:,idx));
% %     [~, p2] = max(  rp(2).pdf(:,idx));
% %     
% %     posDist = [posDist, calc_posidx_distance(p1, p2, dset.clusters(1).pf_edges)];
%     for j = 1:3
%         eventCorr(i,j) = mean( corr_col(  rp(1).pdf{j}(:, idx),  rp(2).pdf{j}(:, idx) ) );  
%     end
% 
% end
% 
% validIdx = ~isnan(eventCorr);
% 
% per1 = per1(validIdx);
% per2 = per2(validIdx);
% 
% 
% 
% thL1 = median(per1);
% thL2 = median(per2);
% 
% thH1 = median(per1);
% thH2 = median(per2);
% 
% idxLow = st(1).percentCells < thL1 & st(2).percentCells < thL2 & st(1).percentCells > 0 & st(2).percentCells > 0;
% idxHigh = st(1).percentCells >= thH1 & st(2).percentCells >= thH2;
% 
% %% - Compute the distances between the PDF based upon % of cells active
% % size(posDist)
% % max(find(idxHigh))
% % highPerDist = posDist(idxHigh);
% % lowPerDist = posDist(idxLow);
% 
% highPerCorr = eventCorr(idxHigh);
% lowPerCorr = eventCorr(idxLow);
% 
% 
% [~, results.kstest_corr] = kstest2(highPerCorr, lowPerCorr, .05, 'smaller');
% % [~, results.cmtest_corr] = cmtest2(highPerCorr, lowPerCorr);
% % 
% % [~, results.kstest_dist] = kstest2(highPerDist, lowPerDist, .05, 'larger');
% % [~, results.cmtest_dist] = cmtest2(highPerDist, lowPerDist);
% % 
% % results.highPerDist = highPerDist';
% % results.lowPerDist = lowPerDist';
% 
% [~, results.pVal] = kstest2(highPerDist, lowPerDist, .05, 'larger');
% results.highPerCorr = highPerCorr;
% results.lowPerCorr = lowPerCorr;
% 
