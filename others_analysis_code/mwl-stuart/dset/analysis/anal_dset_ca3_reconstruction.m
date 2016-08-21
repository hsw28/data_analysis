dset = dset_load_all('Bon', 4, 2);
%%
ca1Idx = strcmp('CA1', {dset.clusters.area});
ca3Idx = strcmp('CA3', {dset.clusters.area});


time_win = [min(dset.position.ts), max(dset.position.ts)];
tau = .015;
recon(1) = dset_reconstruct(dset.clusters(ca1Idx), 'time_win', time_win, 'tau', tau);
recon(2) = dset_reconstruct(dset.clusters(ca3Idx), 'time_win', time_win, 'tau', tau);

%%
figure('Position', [100 600 1130 350]);
a(1) = subplot(211);
a(2) = subplot(212);

dset_plot_reconstruction(recon(1), dset.position, 'pos_color', 'r', 'grayscale',1, 'axes', a(1), 'grayscale', 0);
dset_plot_reconstruction(recon(2), dset.position, 'pos_color', 'r', 'grayscale',1, 'axes', a(2), 'grayscale', 0 );
linkaxes(a, 'x');
pan('xon');
zoom('xon');