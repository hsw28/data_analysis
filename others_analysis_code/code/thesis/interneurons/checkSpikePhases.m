function checkSpikePhases(sdat)
  for n = 1:numel(sdat.clust)
    c_p = find(strcmp(sdat.clust{n}.featurenames, 'theta_phase'));
    p   = sdat.clust{n}.data(:,c_p);
    bins = linspace(0,2*pi,48);
    c    = histc(mod(p,2*pi), bins);
    plot(bins(1:(end-1)),c(1:(end-1)));
    hold on;
  end
end
