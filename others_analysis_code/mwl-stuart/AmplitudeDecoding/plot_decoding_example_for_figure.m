function plot_decoding_example_for_figure(input, output, varargin)

args.axes = [];
args = parseArgsLite(varargin,args);
if isempty(args.axes)
    figure;
    args.axes = axes;
    
end

F = 0:.002:1;
for i=1:numel(output.stats.errors)
    [f x] = ecdf(output.stats.errors{i});
    X(:,i) = interp1(f,x,F);
end
i1 = input.nShuffle+1;
i2 = input.nShuffle*2+1;
X1 = X(:,1);
X2 = mean(X(:,2:i1)')';
X3 = mean(X(:,i1+1:i2)')';
X4 = mean(X(:,i2+2:end)')';
c = 'rbk';

line(X1, F, 'color', 'r', 'linewidth',2, 'parent', args.axes);

if input.nShuffle>1
    line(X2, F, 'color', 'b', 'linewidth',2, 'parent', args.axes);

    line(X3, F, 'color', 'k', 'linewidth',2, 'parent', args.axes);

    line(X4, F, 'color', 'g', 'linewidth',2, 'Parent', args.axes);

end


xlabel('Distance (m)', 'FontSize', 14);
ylabel('Fraction of Errors', 'fontsize', 14);

grid on;
legend(input.method, 'Location', 'southeast');
