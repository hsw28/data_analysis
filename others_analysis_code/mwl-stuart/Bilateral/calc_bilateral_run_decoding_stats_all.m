
clear;

eList = dset_list_epochs('Run');
nEpoch = size(eList, 1);

[pReal, pShuf, mCorr, mCorrS] = deal( nan(10, 1) );

parfor i = 1:nEpoch
    
    fprintf('\n');
    d = dset_load_all(eList{i,:});
%     [pReal(i), pShuf(i), mCorr(i), mCorrS(i), stats(i)] =...
%         calc_bilateral_run_decoding_stats_single(d);
%     d = dset_load_all(eList{i,:});
    [pReal(i), pShuf(i), mCorr(i), mCorrS(i)] =...
        calc_bilateral_run_decoding_stats_single(d);

end
%%

cmPrec = [pReal', pShuf'];
cCorr = [mCorr', mCorrS'];

pCM = ranksum(pReal, pShuf);
pCC = ranksum(mCorr, mCorrS);

close all;
f1 = figure;
boxplot(cmPrec, 'notch', 'on');
set(gca,'YLim', [0, 1], 'XTick', [1 2], 'XTickLabel', {'Real', 'Shuffle'});
title( sprintf('Precision - %1.5g', pCM) );

f2 = figure;
boxplot(cCorr, 'notch', 'on');
set(gca,'YLim', [-1 1], 'XTick', [1 2], 'XTickLabel', {'Real', 'Shuffle'});
title( sprintf('Correlation - %1.5g', pCC') );

fig1Name = 'Figure3-prec-boxplot';
fig2Name = 'Figure3-corr-boxplot';

save_bilat_figure(fig1Name, f1);
save_bilat_figure(fig2Name, f2);


%%


%%
clear;
load('~/Desktop/RunDecodingResults.mat');

%%






