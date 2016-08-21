function pdf =  plot_amp_est(est, tbins, pbins, pos, varargin)
args.methods = repmat({'na'}, size(est));
args.errors = {};
args.error_color = 'b';
args.pos_color='r';
args.pos_marker = '.';
args.pos_line_style = '-';
args.pos_line_width = 1;
args.marker_size = 5;
args.n_axes = 1;
args = parseArgsLite(varargin, args);
if ~iscell(est)
    est = {est};
end
if ~iscell(tbins)
    tbins = {tbins};
end
if ~iscell(pbins)
    pbins = {pbins};
end
for i=1:numel(est)
    ax_n = 1;
    if numel(tbins{i})==size(est{i},2)+1
        tbins{i} = tbins{i}(1:end-1) + mean(diff(tbins{i}));
    end
    figure('Name', args.methods{i});
    if args.n_axes==2
        subplot(211);
    end
    a(ax_n) = gca();
    e = est{i};
    e(isnan(e)) = 0;
    pdf(:,:,1) = e;
    pdf(:,:,2) = e;
    pdf(:,:,3) = e;
    
	pdf = 1-pdf;
    imagesc(tbins{i}, pbins{i}, pdf, 'Parent', a);
    set(a,'YDir', 'normal');
    
    p = interp1(pos.ts, pos.lp, tbins{i});
    t = tbins{i};
    
    if ~isempty(args.errors)
        disp('plotting error');
        er = args.errors{i};
        for j = 1:numel(er)
            line([t(j) t(j)],[p(j), p(j)+er(j)], 'color', args.error_color, 'parent', a);
        end
        
    end
    
    
    if args.n_axes==2
        subplot(212);
        ax_n = 2;
        a(ax_n) = gca;
        linkaxes(a,'x');
    end
    line(t,p,'LineStyle', args.pos_line_style,'linewidth', args.pos_line_width, 'Marker', args.pos_marker, 'Color', args.pos_color, 'markerSize', args.marker_size, 'Parent', a(ax_n), 'linesmoothing', 'off');
    set(a,'YLim', [0 3.1], 'XLim', [min(tbins{i}) max(tbins{i})]); 
    pan('xon');
    zoom('xon');

end
