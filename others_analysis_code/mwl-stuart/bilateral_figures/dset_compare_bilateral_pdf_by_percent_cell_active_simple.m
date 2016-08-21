function results = dset_compare_bilateral_pdf_by_percent_cell_active_simple(reconSimp)

nSpikes1 = sum(reconSimp(1).spike_counts);
nSpikes2 = sum(reconSimp(2).spike_counts);
replayIdx = reconSimp(1).replayIdx;

replayPdf1 = reconSimp(1).pdf;
replayPdf2 = reconSimp(2).pdf;

validIdx = nSpikes1>0 & nSpikes2>0 & replayIdx';

nSpikes1 = nSpikes1(validIdx);
nSpikes2 = nSpikes2(validIdx);

replayPdf1 = replayPdf1(:, validIdx);
replayPdf2 = replayPdf2(:, validIdx);


th1 = median(nSpikes1) ;
th2 = median(nSpikes2) * 1.1;

highIdx = nSpikes1 >= th1 * 1.1 & nSpikes2 >= th2 * 1.1;
lowIdx = nSpikes1 < max(th1 * .9, 2) & nSpikes2 < max(th2 *.9, 2);

pdfCorr = corr_col(replayPdf1, replayPdf2);

highCorr = pdfCorr(highIdx);
lowCorr = pdfCorr(lowIdx);

[h, pVal] = kstest2(highCorr, lowCorr, .05, 'smaller');

results.highPerCorr = highCorr;
results.lowPerCorr = lowCorr;
results.pVal = pVal;

%%
% 
% bins = -1:.025:1;
% 
% figure;
% [lowCts, ctr] = hist(lowCorr, bins);
% [highCts, ctr] = hist(highCorr, bins);
% 
% lowCts = lowCts ./ sum(lowCts);
% highCts = highCts ./ sum(highCts);
% 
% lowCts = smoothn(lowCts, 2, 'correct', 1);
% highCts = smoothn(highCts,2 , 'correct', 1);
% 
% line(ctr, lowCts, 'color', 'r');
% line(ctr, highCts, 'color', 'g');