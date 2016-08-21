clear;
dset = dset_exp_load('/data/spl11/day13', 'sleep2');
%%
rp = dset_calc_ripple_params(dset);


%%
clear;
dset = dset_load_all('Bon', 4, 3);

rp = dset_calc_ripple_params(dset);
rpR = dset_calc_ripple_params(dset_add_ref_to_eeg(dset,1));

%%

close all; figure;
x = rp.freqs;
% ax(1) = subplot(211); imagesc(x,x, rp.spectW{1});%, x, mean(rp.spectW{3}));
% ax(2) = subplot(212); imagesc(x,x, rpR.spectW{1});%, x, mean(rpR.spectW{3}));
ax(1) = subplot(211); plot(x, mean(rp.spectW{1}), x, mean(rp.spectW{3}));
ax(2) = subplot(212); plot(x, mean(rpR.spectW{1}), x, mean(rpR.spectW{3}));


%%
figure; 
ax(1) = subplot(121);
plot(rp1.window, mean(rp1.raw{3}),'k', rp1.window, mean(rp2.raw{3}), 'r', 'linewidth', 2);
ax(2) =subplot(122);
plot(rp2.window, mean(rp1.raw{1}), 'k', rp2.window, mean(rp2.raw{1}), 'r', 'linewidth', 2 );
title('Reference Subtracted');

set(ax,'Xlim', [-75 75]);
%%
figure;
ax = [];
for i = 1:numel(ripples.run)
    r = ripples.run(i);
    ax(i) = subplot(4,5,i);
    
    bins = 150:3:225;
    occ = hist3([r.peakFrM{1}, r.peakFrM{3}], {bins, bins});
    c = corr2(r.peakFreqM{1}, r.peakFrM{3});
    imagesc(bins, bins, occ, 'Parent', ax(i));
    title([num2str(i), ' ', r.description, ' ', num2str(c)]);   
end
set(ax,'Xlim', [150 225], 'YLim', [150 225], 'YDir', 'normal');
