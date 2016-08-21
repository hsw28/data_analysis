function plot_decoding_example(input, output, varargin)

args.time_range = input.d_range;
args = parseArgsLite(varargin,args);

p = input.exp.(input.ep).pos;
est = zeros(size(output.est{1},1),size(output.est{1},2),3);
est(:,:,1) = output.est{1};
est(:,:,2) = output.est{1};
est(:,:,3) = output.est{1};

est = 1-est;
est(isnan(est)) = 1;

%% Plot Reconstruction

warning off;
posRec = interp1(p.ts, p.lp, output.tbins, 'nearest');
warning on;
posRec(isnan(posRec)) = 0;

figure; 
% subplot(311);
% imagesc(output.edges.time , output.edges.pos, est);
% set(gca,'YDir', 'normal');
% subplot(312);
% plot(output.tbins, posRec, 'b', 'linewidth',2);
% subplot(313);
imagesc(output.tbins ,output.edges.pos, est); hold on;
line(output.tbins, posRec, 'color', 'b', 'linewidth',2);
set(gca,'YDir', 'normal');

%set(gca,'YLim', [0 3.1], 'XLim', args.time_range);
%% Plot CDF with Shuffles

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

figure; 
axes;
c = 'rbkg';

line(X1, F, 'color', 'r', 'linewidth',2);

if input.nShuffle>1
    line(X2, F, 'color', 'b', 'linewidth',2);

    line(X3, F, 'color', 'k', 'linewidth',2);

    line(X3, F, 'color', 'g', 'linewidth',2);

end



xlabel('Distance (m)', 'FontSize', 14);
ylabel('Fraction of Errors', 'fontsize', 14);

grid on;
legend(input.method, 'Location', 'southeast');
