function plotPhaseAtAnatomy(d,m,i)

  for n = 1:numel(i.clust)

    [x,y,c] = trode_pos_and_color(i.clust{n}.trode, ...
                                  d.trode_groups, ...
                                  d.rat_conv_table);

    c_p     = find( strcmp(i.clust{n}.featurenames, ...
                           'theta_phase'), 1, 'first');

    bins    = linspace(0,2*pi,48);
    counts  = histc(mod(i.clust{n}.data(:,c_p)', 2*pi), bins);
    bins    = bins(1:(end-1));
    counts  = counts(1:(end-1));

    gh_add_polar(bins,counts,...
                 'max_r', 0.1,...
                 'pos',   [x,y]);

    hold on;

  end

end
