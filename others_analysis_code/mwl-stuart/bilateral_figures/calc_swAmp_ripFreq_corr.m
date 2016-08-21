clear;
allRipples = dset_load_ripples;
%%
clear;
dset = dset_load_all('Bon', 5, 3);

%%
% d = dset_filter_eeg_theta_band(d);
d = dset_calc_ripple_params(dset);
%%

figure;
axes;
imagesc(d.ripples.sw{1});

%%
figure; axes;

ts = d.ripples.window / d.ripples.fs;
line(ts,  mean( d.ripples.sw{1} ) , 'color', 'k', 'linewidth', 2);
line(ts,  mean( d.ripples.sw{2} ) , 'color', 'b', 'linewidth', 2);
line(ts,  mean( d.ripples.sw{3} ) , 'color', 'r', 'linewidth', 2);

set(gca,'XLim', [-.15 .15]);

%%
for i = 1:3
    swPeak{i} = max( d.ripples.sharpwave{i}, [], 2);
    hRip{i} = hilbert( d.ripples.rip{i}')';
end
%%
instFreqEst = [];
for i = 1:size(d.ripples.sw{1},1 )
    instFreqEst(i,:) = calc_inst_freq( d.ripples.rip{1}(i,:) , 1500);
end