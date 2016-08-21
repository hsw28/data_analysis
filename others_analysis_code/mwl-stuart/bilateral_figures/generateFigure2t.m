function generateFigure2
%% Load all the data required for plotting!
open_pool;
clear;

% For ripple detection code see fig1_sandbox.m

fname = '/data/misc/spl11_d14_sleep_rip_burst.mat';
data = load(fname);
b = data.b;
lInd = data.lInd;
rInd = data.rInd;
clear fname data;

eeg = load('/data/misc/spl11_d14_sleep2.mat');
eeg.eeg = eeg.eeg';
rip_filt = getfilter(2000, 'ripple', 'win');
rip = filtfilt(rip_filt, 1, double(eeg.eeg));
ripEnv = abs(hilbert(rip));
hBin = zeros(size(ripEnv));
ripples = dset_load_ripples;

ripPhaseRun = calc_bilateral_ripple_phase_diff(ripples.sleep);
ripFreqRun = calc_bilateral_ripple_freq_distribution(ripples.sleep);

%% Setup Figure
close all;
fHandle = figure('Position', [650 50  825 875]);
ax = [];
% Panel A - Ripple Detection
%   - Raw LFP
%   - Filtered LFP
%   - Envelope
%   - Detected Events
if numel(ax) > 0 && ishandle(ax(1))
    delete(ax(1));
end


xlim = [5892.7 5893.5];
plotIdx = eeg.ts >= xlim(1) & eeg.ts <= xlim(2);
plotChan = 10;
bursts = b{plotChan};
bIdx = bursts(:,1) > xlim(1) & bursts(:,2) < xlim(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      A - Ripple Detection Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(ax) > 0 && ishandle(ax(1)), delete(ax(1)); end
ax(1) = axes('Position', [.05 .743 .94 .2514], 'Color', 'k');

line(eeg.ts(plotIdx), 1.5 *eeg.eeg(plotIdx,plotChan) + 100, 'Color', 'w', 'Parent', ax(1));
line(eeg.ts(plotIdx), 1.5*rip(plotIdx, plotChan) - 2100, 'Color','y', 'Parent', ax(1) );
line(eeg.ts(plotIdx), 1.5*ripEnv(plotIdx, plotChan) - 3600, 'Color','c', 'Parent', ax(1)); hold on;
seg_plot(bursts(bIdx,:), 'YOffset', -4500, 'Height', 500, 'FaceColor', [.8 .2 .2], 'Alpha', 1, 'Axis', ax(1));
%stairs(eeg.ts(plotIdx), 500 * hBin(plotIdx) - 4500, 'w', 'Parent', ax(1));

%line(eeg.ts(plotIdx), ( h(plotIdx, plotChan) > std(h(,:))*5) - 4500);
set(ax(1), 'XLim', xlim, 'YLim', [-4800 1500], 'Ytick', [], 'Box', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       B - Ripple Synchrony Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(ax) > 1 && ishandle(ax(2)), delete(ax(2)); end

ax(2) = axes('Position', [.05 .35 .94 .33], 'color', 'k');

xlim = [5892.7 5893.5];
plotIdx = eeg.ts >= xlim(1) & eeg.ts <= xlim(2);
l_cols = [ repmat( [ .7 1 1], 3, 1); repmat( [1 .7 .7], 3, 1) ];
b_cols = [ repmat( [ 0 .5 .5], 3, 1); repmat( [.5 0 0], 3, 1) ];

plotChan = [2 3 4 7 8 10];
pOffset = 2400;

line_browser(eeg.eeg(plotIdx,plotChan), eeg.ts(plotIdx),'color', l_cols, 'axes', ax(2), 'offset', pOffset);
draw_bounding_boxes(b(plotChan), pOffset - pOffset/2-300, pOffset-400, pOffset, 5892.7, 5893.5, b_cols , ax(2)); 
line_browser(eeg.eeg(plotIdx,plotChan), eeg.ts(plotIdx),'color', l_cols, 'axes', ax(2), 'offset', pOffset);

set(ax(2), 'Xlim', [5892.7 5893.5], 'YLim', [800 pOffset*6 + 800*1.5]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Ripple Peak Triggered LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.sleep);

if numel(ax) > 2 && ishandle(ax(3)), delete(ax(3)); end

ax(3) = axes('Position', [.05 .04 .28 .25], 'Color', 'k');
% error_area_plot(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', ax(3));
line(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', ax(3)); 
line(rTrigLfp.ts, rTrigLfp.meanLfp{2}, 'Color', [0 1 0 ], 'Parent', ax(3));
set(ax(3),'XLim', [-.075 .075]);
%plot_ripple_trig_lfp(rTrigLfp, ax(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Bilateral Ripple Peak Phase Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(ax) > 3 && ishandle(ax(4)), delete(ax(4)); end
ax(4) = axes('Position', [.375 .04 .28 .25]);

bins = -(pi) : pi/8 : (pi + pi/8)
[T,R] = rose(ripPhaseRun.dPhase, bins);
compass(bins, occ);
% rose(ripPhase.dPhase, bins);

% set(ax(4), 'XLim', [-1.05 1.05] * pi , 'XTick', -pi:pi/2:pi);
% set(ax(4), 'XTickLabel', {'-pi','-pi/2',  '0', 'pi/2', 'pi'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E - Bilateral Ripple Mean Freq Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numel(ax) > 4 && ishandle(ax(5)), delete(ax(5)); end

bins = 150:3:225;
occ = hist3([ripFreqRun.base, ripFreqRun.cont], {bins, bins});
occ = smoothn(occ,1);
ax(5) = axes('Position', [.7 .04 .28 .25]);

imagesc(bins, bins, occ, 'Parent', ax(5));

set(ax(5),'Xlim', [150 225], 'YLim', [150 225], 'YDir', 'normal');

%% Save the figure

saveDir = '/data/bilateral/figures';
figName = ['figure1-', datestr(now, 'yyyymmdd')];

saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');

end