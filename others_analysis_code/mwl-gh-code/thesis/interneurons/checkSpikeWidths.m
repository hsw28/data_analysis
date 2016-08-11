function checkSpikeWidths(sdat)
  for n = [1:numel(sdat.clust)]
    c_w = find(strcmp(sdat.clust{n}.featurenames,'t_maxwd'));
    d   = sdat.clust{n}.data(:,c_w);
    bins = bin_centers_to_edges(0:32);
    c = histc(d,bins);
    plot(bins,c);
    hold on;
  end
end
