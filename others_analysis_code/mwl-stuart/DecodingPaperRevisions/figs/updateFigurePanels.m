clear;
load('/data/amplitude_decoding/REVISIONS/decode_all_results.mat');
outDir = '/data/amplitude_decoding/REVISIONS';

baseDir = '/data/spl11/day15';
[P, E, IN] = decode_feature_vs_cluster(baseDir, 4);

pos = load_linear_position(baseDir);
tb = mean(IN.decoding_segments,2);
lp = interp1(pos.ts, pos.lp, tb, 'nearest');
ts = interp1(pos.ts, pos.ts, tb, 'nearest');

%% F2 - A


figure('Position', [680 678 920 420]); 
ax = axes('Position', [.05 .11 .9 .84]);
img = 1 - repmat(P{1}, [1 1 3]);
idx = 255:549;
imagesc(idx, 0:.1:3.1, img(:, idx, :));

set(ax,'YDir','normal');

xlabel('Time Bins');
ylabel('Position(m)');

plot2svg( sprintf('%s/Fig2A.svg', outDir), gcf);
imwrite(img(:,idx,:), sprintf('%s/Fig2A-image.png', outDir), 'png');

%% F2 - B
figure('Position', [630 628 450 420]); 
ax = axes('Position', [.09 .11 .9 .84]);
img = 1 - repmat( P{1}, [1 1 3] );
idx = 256:291;
imagesc(idx, 0:.1:3.1, img(:, idx, :));
line( idx, lp(idx), 'color', 'r');

set(ax,'YDir','normal');

xlabel('Time Bins');
ylabel('Position(m)');
plot2svg( sprintf('%s/Fig2B.svg', outDir), gcf);
imwrite(img(:,idx,:), sprintf('%s/Fig2B-image.png', outDir), 'png');


%% F2 - C

figure('Position', [580 778 450 420]); 
ax = axes('Position', [.09 .11 .9 .84]);

img = normalize(E(1).confusion{1});
img = 1 - repmat(img, [1 1 3]);
imagesc(0:.1:3.1, 0:.1:3.1, img);
set(ax,'YDir','normal');

xlabel('True Position(m)');
ylabel('Predicted Position(m)');
plot2svg( sprintf('%s/Fig2C.svg', outDir), gcf);
imwrite(img, sprintf('%s/Fig2C-image.png', outDir), 'png');



%% Figure 2-D
figure;
axes;

[f1,x1] = ecdf(E(1).estimation_error);
[f2,x2] = ecdf(E(2).estimation_error);

X1 = interp1(f1, x1, .9);
line(x1,f1,'color', 'r');
line(x2,f2,'color', 'k');
line( [X1 X1], [0 1], 'Color', [.4 .4 .4], 'LineStyle', '--');

xlabel('Error(m)');
ylabel('Cumulative Density');

plot2svg(fullfile(outDir, 'Fig2D.svg'), gcf);


%% Table 1 - Data set summary
clear;
load('/data/amplitude_decoding/REVISIONS/decode_all_results.mat');

E = E4;
IN = I4;
nPlot = numel(E4);
[nS4, nS1, nT4, nT1, nU4, nU1] = deal( nan(nPlot,1) );

for iPlot = 1:nPlot
    
    nS4(iPlot) = I4{iPlot}.nSpike(1); 
    nT4(iPlot) = sum( ~cellfun(@isempty, I4{iPlot}.data{1} ) );
    nU4(iPlot) = sum( ~cellfun(@isempty, I4{iPlot}.data{2} ) );
    
    nS1(iPlot) = I1{iPlot}.nSpike(1);
    nT1(iPlot) = sum( ~cellfun(@isempty, I1{iPlot}.data{1} ) );
    nU1(iPlot) = sum( ~cellfun(@isempty, I1{iPlot}.data{2} ) );
    
end

rName = {'SL13', 'SL14', 'SL15', 'SL16', 'R1D1', 'R1D2', 'R2D1', 'R2D2', 'ESM11', 'ESM2', 'SAT2', 'FK11'};
cName = {'4Ch - N. TT', '4Ch - N. Spikes', '4Ch - N. Unit', '1Ch - N. TT', '1Ch - N. Spikes', '1Ch - N. Unit'};

table1Data = [nT4, nS4, nU4, nT1, nS1, nU1];
writeTable(cName, rName, table1Data,  '/data/amplitude_decoding/REVISIONS/table1.csv');

% Table 2 - Summary of Decoding Accuracy
[meF4, meI4, meF1, meI1] = deal( nan(nPlot,1) );

for iPlot = 1:nPlot
    meF4(iPlot) = E4{iPlot}(1).summary_error;
    meI4(iPlot) = E4{iPlot}(2).summary_error;
    
    meF1(iPlot) = E1{iPlot}(1).summary_error;
    meI1(iPlot) = E1{iPlot}(2).summary_error;
end


mError = [meF4, meI4, meF1, meI1];
cName = {'4Ch - Feature', '4Ch - Identity', '1Ch - Feature', '1Ch - Identity'};
writeTable(cName, rName, mError, '/data/amplitude_decoding/REVISIONS/table2.csv');


%% Figure 4

figure;
ax = axes('fontsize', 14);
boxplot( mError(:,[1,3]) );
line(1:2, mError(:,[1,3]), 'color', [.7 .7 .7]);
set(ax,'Xtick', [1 2], 'XTickLabel', {'Feature 4Ch', 'Feature 1Ch'});
ylabel('Median Error(m)');

plot2svg('/data/amplitude_decoding/REVISIONS/Fig4.svg', gcf)

%% Figure 5


figure;
ax = [];
ax(1) = subplot(221);
ax(2) = subplot(223);
set(ax,'NextPlot', 'add', 'FontSize', 14);

line(1:2, mError(:, 1:2), 'Parent', ax(1), 'Color', [.7 .7 .7] );
boxplot(ax(1), mError(:,1:2));

line(1:2, mError(:, 3:4), 'Parent', ax(2), 'Color', [.7 .7 .7] );
boxplot(ax(2), mError(:,3:4));


set(ax,'YLim', [0 1]);
ylabel(ax(1), 'Median Error(m');
ylabel(ax(2), 'Median Error(m');

title(ax(1), '4 Channels');
title(ax(2), '1 Channel');

set(ax,'XTick', [1 2], 'XTickLabel', {'Feature', 'Identity'});

[~, pT4] = ttest2(mError(:,1), mError(:,2), .05, 'left');
pS4 = signrank(mError(:,1), mError(:,2), .05, 'tail', 'left');
% text(.65, .97, sprintf('p = %3.4e -  tTest', pT4), 'Parent', ax(1), 'HorizontalAlignment', 'left');
% text(.65, .92, sprintf('p = %3.4e -  signRank', pS4), 'Parent', ax(1), 'HorizontalAlignment', 'left');


[~, pT1] = ttest2(mError(:,3), mError(:,4), .05, 'left');
pS1 = signrank(mError(:,3), mError(:,4), .05, 'tail', 'left');
% text(.65, .97, sprintf('p = %3.4e -  tTest', pT1), 'Parent', ax(2), 'HorizontalAlignment', 'left');
% text(.65, .92, sprintf('p = %3.4e -  signRank', pS1), 'Parent', ax(2), 'HorizontalAlignment', 'left');

ax(3) = subplot(222);
ax(4) = subplot(224);

line(mError(:,1), mError(:,2), 'marker', '.', 'linestyle', 'none', 'marker', 'x', 'color', 'k', 'Parent', ax(3));
line([0 1], [0 1], 'color', 'k', 'Parent', ax(3));
xlabel(ax(3), 'Median Error(m) - Feature');
ylabel(ax(3), 'Median Error(m) - Identity');

line(mError(:,3), mError(:,4), 'marker', '.', 'linestyle', 'none', 'marker', 'x', 'color', 'k', 'Parent', ax(4));
line([0 1], [0 1], 'color', 'k', 'Parent', ax(4));
xlabel(ax(4), 'Median Error(m) - Feature');
ylabel(ax(4), 'Median Error(m) - Identity');

plot2svg('/data/amplitude_decoding/REVISIONS/Fig5.svg', gcf)

%% Figure 6
clear;
[P, E] = decode_feature_realtime('/data/spl11/day15', 4);
%%
ax = [];
figure;

nLap = numel(E);
nPlot = 4;
for iPlot = 1:nPlot

    ax(iPlot) = subplot(2,nPlot,iPlot);
    
    img = 1 - repmat( P{iPlot+1}, [1 1 3]);
    img( isnan(img) ) = 1;
   
    imagesc( [], 0:.1:3.1, img );    
    title(ax(iPlot), sprintf('Lap %d', iPlot+1), 'FontSize', 14);
    imwrite(img, sprintf('/data/amplitude_decoding/REVISIONS/Fig6A_%d-image.png',  iPlot), 'png');
end

iPlot = iPlot+1;

ax(iPlot) = subplot(2,1,2);
set(ax, 'YDir', 'normal', 'FontSize', 14);

lapError = [nan, E.summary_error];

line(1:nLap, lapError,'marker', 'o');
line([1 nLap], nanmean(lapError) * [1 1], 'color', [.6 .6 .6], 'linestyle', '--', 'Parent', ax(iPlot));
set(ax(iPlot),'XLim', [.5 32.5], 'YLim', [0 .25]);

ylabel(ax(iPlot), 'Median Error(m)');
xlabel(ax(iPlot), 'Lap');
plot2svg('/data/amplitude_decoding/REVISIONS/Fig6.svg', gcf);





