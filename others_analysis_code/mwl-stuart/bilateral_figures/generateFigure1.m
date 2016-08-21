function generateFigure1
open_pool;

%% Load Data for Panels A, B

% For ripple detection code see fig1_sandbox.m
clear;
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

data = load('/data/thesis/bilateral_ripple_coherence.mat');
ripCohere = data.rippleCoherence;
%ripCohere.run.shuffleCoherence = ripCohere.run.shuffleCoherence(1);

clear data;

ripPhaseRun = calc_bilateral_ripple_phase_diff(ripples.run);
ripFreqRun = calc_bilateral_ripple_freq_distribution(ripples.run);

%% Setup Figure
% close all;
if exist('f1Handle', 'var'), delete( f1Handle( ishandle(f1Handle) ) ); end
if exist('axF1', 'var'), delete( axF1( ishandle(axF1) ) ); end
%%
f1Handle = figure('Position', [650 50  581 975], 'NumberTitle','off','Name', 'Bilat Fig 1' );
% Panel A - Ripple Detection
%   - Raw LFP
%   - Filtered LFP
%   - Envelope
%   - Detected Events

xlim = [5892.70 5893.25];
plotIdx = eeg.ts >= xlim(1) & eeg.ts <= xlim(2);
plotChan = 10;
bursts = b{plotChan};
bIdx = bursts(:,1) > xlim(1) & bursts(:,2) < xlim(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      A - Ripple Detection Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF1(1) = axes('Position', [.05 .8 .94 .169], 'Color', 'k');

line(eeg.ts(plotIdx), 1.5 *eeg.eeg(plotIdx,plotChan) + 100, 'Color', 'w', 'Parent', axF1(1));
line(eeg.ts(plotIdx), 1.5*rip(plotIdx, plotChan) - 2100, 'Color','y', 'Parent', axF1(1) );
line(eeg.ts(plotIdx), 1.5*ripEnv(plotIdx, plotChan) - 3600, 'Color','c', 'Parent', axF1(1)); hold on;
seg_plot(bursts(bIdx,:), 'YOffset', -4500, 'Height', 500, 'FaceColor', [.8 .2 .2], 'Alpha', 1, 'Axis', axF1(1));
%stairs(eeg.ts(plotIdx), 500 * hBin(plotIdx) - 4500, 'w', 'Parent', axF1(1));

%line(eeg.ts(plotIdx), ( h(plotIdx, plotChan) > std(h(,:))*5) - 4500);
set(axF1(1), 'XLim', xlim, 'YLim', [-4800 1500], 'Ytick', [],'XTick', [5892:.25:5894], 'Box', 'on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       B - Ripple Synchrony Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF1(2) = axes('Position', [.05 .504 .94 .267], 'color', 'k');

plotIdx = eeg.ts >= xlim(1) & eeg.ts <= xlim(2);
l_cols = [ repmat( [ .7 1 1], 3, 1); repmat( [1 .7 .7], 3, 1) ];
b_cols = [ repmat( [ 0 .5 .5], 3, 1); repmat( [.5 0 0], 3, 1) ];

plotChan = [2 3 4 7 8 10];
pOffset = 2400;

line_browser(eeg.ts(plotIdx), eeg.eeg(plotIdx,plotChan), 'color', l_cols, 'Parent', axF1(2), 'offset', pOffset);
draw_bounding_boxes(b(plotChan), pOffset - pOffset/2-300, pOffset-400, pOffset, 5892.7, 5893.5, b_cols , axF1(2)); 
line_browser(eeg.ts(plotIdx), eeg.eeg(plotIdx,plotChan), 'color', l_cols, 'Parent', axF1(2), 'offset', pOffset);

set(axF1(2), 'Xlim', xlim, 'YLim', [800 pOffset*6 + 800*1.5], 'Ytick', [],'XTick', [5892:.25:5894]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Ripple Peak Triggered LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF1(3) = axes('Position', [.05 .27 .35 .19]);

%rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.run([3 15 5 17 18 6]));
rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.run([2 3 4 5 10]));

% error_area_plot(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', axF1(3));
line(rTrigLfp.ts, -1 * rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', axF1(3)); 
line(rTrigLfp.ts, -1 * rTrigLfp.meanLfp{2}, 'Color', [0 1 0 ], 'Parent', axF1(3));
line(rTrigLfp.ts, -1 * rTrigLfp.meanLfp{3}, 'Color', [0 0 1 ], 'Parent', axF1(3));

set(axF1(3),'XLim', [-.075 .075], 'YTick', []);

%t = title('SPL11 Rip trig LFP');
%set(t,'Position', [0 460, 1]);

%plot_ripple_trig_lfp(rTrigLfp, axF1(3));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Bilateral Ripple Peak Phase Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF1(4) = axes('Position', [.55 .25 .35 .19]);

bins = -(pi) : pi/8 : (pi + pi/8);
 %[T,R] = rose(ripPhaseRun.dPhaseCont, bins);

rose2(ripPhaseRun.dPhaseIpsi, bins, [], 'r', 'Parent', axF1(4)); hold on;
rose2(ripPhaseRun.dPhaseCont, bins, 'Parent', axF1(4));
title('Ripple Phase difference distribution');
% set(axF1(4), 'XLim', [-1.05 1.05] * pi , 'XTick', -pi:pi/2:pi);
% set(axF1(4), 'XTickLabel', {'-pi','-pi/2',  '0', 'pi/2', 'pi'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E - Bilateral Ripple Mean Freq Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF1(5) = axes('Position', [.05 .025 .35 .19]);

freqBins = 150:3:225;
bilatFreqDistRun = hist3([ripFreqRun.base, ripFreqRun.cont], {freqBins, freqBins});
%occ = smoothn(occ,1);

imagesc(freqBins, freqBins, bilatFreqDistRun, 'Parent', axF1(5));

set(axF1(5),'Xlim', [150 225], 'YLim', [150 225], 'YDir', 'normal');
t = title('Bilateral Ripple Mean Freq Dist', 'Parent', axF1(5));
set(t,'Position', [187.5 225, 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E - Bilateral Coherence Around Ripples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF1(6) = axes('Position', [.55 .025 .35 .19]);

F = ripCohere.run.F;
mCoCont = mean(ripCohere.run.cohereCont);
sCoCont = std(ripCohere.run.cohereCont);

mCoIpsi = mean(ripCohere.run.cohereIpsi);
sCoIpsi = std(ripCohere.run.cohereIpsi);

n = size(ripCohere.run.cohereIpsi,1);
nStd = 3;

mShufCont = mean(ripCohere.run.shuffleCont);
sShufCont= std(ripCohere.run.shuffleCont);

mShufIpsi = mean(ripCohere.run.shuffleIpsi);
sShufIpsi= std(ripCohere.run.shuffleIpsi);


[p(1), l(1)] = error_area_plot(F, mCoCont, nStd * sCoCont / sqrt(n), 'Parent', axF1(6));
 [p(2), l(2)] = error_area_plot(F, mCoIpsi, nStd * sCoIpsi / sqrt(n), 'Parent', axF1(6));
[p(3), l(3)] = error_area_plot(F, mShufCont, nStd * sShufCont / sqrt(n), 'Parent', axF1(6));
 [p(4), l(4)] = error_area_plot(F, mShufIpsi, nStd * sShufIpsi / sqrt(n), 'Parent', axF1(6));

set(l(1), 'Color', [1 0 0], 'LineWidth', 2);
set(l(2), 'Color', [0 1 0], 'LineWidth', 2);

set(l(3), 'Color', [0 1 1], 'LineWidth', 2);
set(l(4), 'Color', [1 0 1], 'LineWidth', 2);

set(p(1), 'FaceColor', [1 .7 .7], 'edgecolor', 'none');
set(p(2), 'FaceColor', [.7 1 .7], 'edgecolor', 'none');

set(p(3), 'FaceColor', [.7 1 1], 'edgecolor', 'none');
set(p(4), 'FaceColor', [1 .7 1], 'edgecolor', 'none');


legend(l, {'Co-Cont', 'Co-Ipsi', 'Sh-Cont', 'Sh-Ipsi'});

set(gca,'Xlim', [0 400], 'XTick', [0:100:400]);

t = title('Bilateral Ripple Coherence');
set(t,'Position', [200 .5 1]);


%% Save the figure

save_bilat_figure('figure1', f1Handle);
% saveDir = '/data/bilateral/figures';
% figName = ['figure1-', datestr(now, 'yyyymmdd')];
% 
% saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');
% save(fullfile(saveDir, 'figure1-data.mat'))
end