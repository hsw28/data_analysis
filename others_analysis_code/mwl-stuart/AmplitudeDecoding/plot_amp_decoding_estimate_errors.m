function [me e f x fl fu ismoving] =  plot_amp_decoding_estimate_errors(input, output, varargin)
args.decode_range = [nan nan];
args.n_spike = {};
args.dt = .25;
args.dp = .1;
args.legend = {};
args.vel_thold = .15;
args.plot_ks = 0;
args.smooth = 0;
args.area = 0;
args.line_width =3;
args.font_size = 16;
args.shuffle = 0;
args.plot_shuffle_cdf = 0;
args.nPlot = numel(output.stats.errors);

args.axes = ones(0,1);

args = parseArgsLite(varargin,args);

p = input.exp.(input.ep).pos;

isMoving = abs(p.lv)>args.vel_thold;
isMoving = logical(interp1(p.ts, isMoving, output.tbins, 'nearest'));


c= 'rkbgmrkbgmrkbgmrkbg';
s = {'--', '-', '-.'};

if isempty(args.axes)
    figure('Position', [155 177 1334 875], 'name', input.exp.edir);
    args.axes = gca;
end

for i=1:(args.nPlot)
        
        [f x] = ecdf(output.stats.errors{i}(isMoving));
        line(x, f, 'color',c(i), 'LineWidth', args.line_width, 'LineStyle', s{mod(i-1,3)+1}, 'Parent', args.axes);
end
 
set(args.axes,'XTick', 0:.25:3.1, 'YLim', [0 1], 'FontSize', args.font_size);
grid on;
title('CDF of Decoding Errors', 'fontsize',args.font_size);
xlabel('meters', 'fontsize', args.font_size);
ylabel('% errors', 'fontsize', args.font_size);

legend( input.method, 'location', 'southeast');
end