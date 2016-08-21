function mean_plot(data, varargin)
args.n_std =2;
args.marker = '.';
args.marker_color = 'k';
args.marker_size = 5;
args.line_color = 'r';
args.line_width = 3;
args.labels = {};
args = parseArgsLite(varargin,args);


if ~isempty(args.labels) && numel(args.labels)~=size(data,2)
    error('Invalid number of labels');
end

f = figure;
a = gca();

m = nanmean(data);
s = nanstd(data);

for i=1:size(data,2)
    sd = args.n_std * s(i);% / sqrt(size(data,1));
    line([i i], [m(i)+sd, m(i)-sd],...
        'color', args.line_color, 'lineWidth', args.line_width);
    
end

    line(1:size(data,2), m, 'linestyle', 'none',...
    'marker', args.marker, 'markersize', args.marker_size, ...
    'markeredgecolor', args.marker_color, 'markerfacecolor', args.marker_color);

set(gca,'XTick', 1:size(data,2), 'Xlim', [.5 size(data,2)+.5]);

if ~isempty(args.labels)
    set(gca,'XTickLabel',args.labels);
end
grid on;
title('Mean with SE');