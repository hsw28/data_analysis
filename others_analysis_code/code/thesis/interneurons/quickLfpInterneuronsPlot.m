function quickLfpInterneuronsPlot(d,i,m)
% QUICKLFPINTERNEURONSPLOT put up the lfp and some mua on shared time axis
  tw = [4700,4900];
  ax(1) = subplot(2,1,1);
  gh_plot_cont(contwin(d.thetaRaw, tw));
  hold on;
  gh_plot_cont(contwin(d.theta, tw));

  ax(2) = subplot(2,1,2);
  sdat_raster(sdat_filter_group(i.mua, d.trode_groups,'CA1'));

  linkaxes(ax,'x');
  end
