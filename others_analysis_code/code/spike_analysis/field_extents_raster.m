function h = field_extents_raster( place_cells, fe, varargin )
% h = FIELD_EXTENTS_RASTER( place_cells, fe, ['inds_to_plot', unit_subset])
% draw raster plot of spikes, with row height set by linear track
% position of the unit in question
% argument 'fe' is the output of FIELD_EXTENTS()

p = inputParser();
p.addParamValue('inds_to_plot', 1:numel(fe))
p.addParamValue('timewin',[-Inf,Inf]);
p.addParamValue('line_width',2);
p.addParamValue('Color',[]);
p.parse(varargin{:});
opt = p.Results;

 for n = opt.inds_to_plot
     stimes = place_cells.clust{n}.stimes;
     stimes = stimes(stimes > opt.timewin(1) & stimes < opt.timewin(2));
     xs = [];
     ys = [];
     n_extents = size(fe(n).field_extents,1);
     for m = 1:n_extents
         %disp(['n :', num2str(n), '  m: ', num2str(m) ]);
         [this_xs, this_ys] = gh_raster_points( stimes, 'y_range',...
             fe(n).field_extents(m,:));
         xs = [xs, this_xs];
         ys = [ys, this_ys];
     end
     %plot(xs,ys,'-', 'Color', fe(n).color,'LineWidth',opt.line_width);
     if(isempty(opt.Color))
         c = gh_colors(n);
     else
         c = opt.Color;
     end
     plot(xs,ys,'-', 'Color', c,'LineWidth',opt.line_width);
     hold on;
 end