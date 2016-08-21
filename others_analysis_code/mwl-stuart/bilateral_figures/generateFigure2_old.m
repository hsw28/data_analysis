function generateFigure2
%% Load all the data required for plotting!
% open_pool;
%%
clear;

ripples = dset_load_ripples;

ripPhaseSleep = calc_bilateral_ripple_phase_diff(ripples.sleep);
ripFreqSleep = calc_bilateral_ripple_freq_distribution(ripples.sleep);

ripPhaseRun = calc_bilateral_ripple_phase_diff(ripples.run);
ripFreqRun = calc_bilateral_ripple_freq_distribution(ripples.run);

data = load('/data/thesis/bilateral_ripple_coherence.mat');
ripCohere = data.rippleCoherence;
% ripCohere.sleep.shuffleCoherence = ripCohere.sleep.shuffleCoherence(1);
% ripCohere.run.shuffleCoherence = ripCohere.run.shuffleCoherence(1);

clear data;

%% Close any existing figures
% close all;
%% Setup Figure

if exist('f2Handle', 'var'), delete( f2Handle( ishandle(f2Handle) ) ); end
if exist('axF2', 'var'), delete( axF2( ishandle(axF2) ) ); end

f2Handle = figure('Position', [650 50  581 492], 'NumberTitle','off','Name', 'Bilat Fig 2' );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       A - Ripple Peak Triggered LFP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(1) = axes('Position', [.055 .57 .35 .38]);


% rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.sleep());
rTrigLfp = calc_ripple_triggered_mean_lfp(ripples.sleep([10:13]));

% error_area_plot(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', axF2(3));
line(rTrigLfp.ts, rTrigLfp.meanLfp{1}, 'Color', [1 0 0 ], 'Parent', axF2(1)); 
line(rTrigLfp.ts, rTrigLfp.meanLfp{2}, 'Color', [0 1 0 ], 'Parent', axF2(1));
line(rTrigLfp.ts, rTrigLfp.meanLfp{3}, 'Color', [0 0 1 ], 'Parent', axF2(1)); 


set(axF2(1),'XLim', [-.075 .075], 'YTick', []);
t = title('Bon4 Rip trig LFP');
set(t,'Position', [0 200, 1]);
%plot_ripple_trig_lfp(rTrigLfp, axF2(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       B - Bilateral Ripple Peak Phase Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(2) = axes('Position', [.55 .55 .35 .38]);

bins = -(pi) : pi/8 : (pi + pi/8);

rose2(ripPhaseSleep.dPhaseIpsi, bins, [], 'r', 'Parent', axF2(2)); hold on;
rose2(ripPhaseSleep.dPhaseCont, bins, 'Parent', axF2(2));


title('Ripple Phase difference distribution', 'Parent', axF2(2));

% set(axF2(4), 'XLim', [-1.05 1.05] * pi , 'XTick', -pi:pi/2:pi);
% set(axF2(4), 'XTickLabel', {'-pi','-pi/2',  '0', 'pi/2', 'pi'});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Bilateral Ripple Mean Freq Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(3) = axes('Position', [.055 .065 .35 .38]);

freqBins = 150:3:225;
biFreqSlpCont = hist3([ripFreqSleep.base, ripFreqSleep.cont], {freqBins, freqBins});
biFreqRunCont = hist3([ripFreqRun.base, ripFreqRun.cont], {freqBins, freqBins});

biFreqSlpIpsi = hist3([ripFreqSleep.base, ripFreqSleep.ipsi], {freqBins, freqBins});
biFreqRunIpsi = hist3([ripFreqRun.base, ripFreqRun.ipsi], {freqBins, freqBins});

% occ = smoothn(occ,1);
img = repmat( biFreqSlpCont ,[1 1 3]);
img = img - min(img(:));
img = img / max(img(:));
imagesc(freqBins, freqBins,  1-img, 'Parent', axF2(3));

[r2(1) pR2(1)] = corr(ripFreqSleep.base, ripFreqSleep.cont);
[r2(2) pR2(2)] = corr(ripFreqRun.base, ripFreqRun.cont);
[r2(3) pR2(3)] = corr(ripFreqSleep.base, ripFreqSleep.ipsi);
[r2(4) pR2(4)] = corr(ripFreqRun.base, ripFreqRun.ipsi);

fprintf('R Sq\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', r2);
fprintf('P Sq\t%0.2g\t%0.2g\t%0.2g\t%0.2g\n', pR2 * 1000);


set(axF2(3),'Xlim', [150 225], 'YLim', [150 225], 'YDir', 'normal');
set(axF2(3),'XTick',150:25:225,'YTick', 150:25:225);
t = title('Bilateral Ripple Mean Freq Dist', 'Parent', axF2(3));
set(t,'Position', [187.5 225, 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       D - Bilateral Coherence Around Ripples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axF2(4) = axes('Position', [.55 .065 .35 .38]);

F = ripCohere.run.F;
mCoCont = mean(ripCohere.sleep.cohereCont);
sCoCont = std(ripCohere.sleep.cohereCont);

mCoIpsi = mean(ripCohere.sleep.cohereIpsi);
sCoIpsi = std(ripCohere.sleep.cohereIpsi);

n = size(ripCohere.sleep.cohereIpsi,1);
nStd = 3;

mShufCont = mean(ripCohere.sleep.shuffleCont);
sShufCont= std(ripCohere.sleep.shuffleCont);

mShufIpsi = mean(ripCohere.sleep.shuffleIpsi);
sShufIpsi= std(ripCohere.sleep.shuffleIpsi);


[p(1), l(1)] = error_area_plot(F, mCoCont, nStd * sCoCont / sqrt(n), 'Parent',axF2(4));
[p(2), l(2)] = error_area_plot(F, mCoIpsi, nStd * sCoIpsi / sqrt(n), 'Parent', axF2(4));
[p(3), l(3)] = error_area_plot(F, mShufCont, nStd * sShufCont / sqrt(n), 'Parent', axF2(4));
[p(4), l(4)] = error_area_plot(F, mShufIpsi, nStd * sShufIpsi / sqrt(n), 'Parent', axF2(4));

set(l(1), 'Color', [1 0 0], 'LineWidth', 2);
set(l(2), 'Color', [0 1 0], 'LineWidth', 2);

set(l(3), 'Color', [0 1 1], 'LineWidth', 2);
set(l(4), 'Color', [1 0 1], 'LineWidth', 2);

set(p(1), 'FaceColor', [1 .7 .7], 'edgecolor', 'none');
set(p(2), 'FaceColor', [.7 1 .7], 'edgecolor', 'none');

set(p(3), 'FaceColor', [.7 1 1], 'edgecolor', 'none');
set(p(4), 'FaceColor', [1 .7 1], 'edgecolor', 'none');

legend(l, {'Co-Cont', 'Co-Ipsi', 'Sh-Cont', 'Sh-Ipsi'});

set(axF2(4),'Xlim', [0 400], 'XTick', [0:100:400]);t = title('Bilateral Ripple Coherence', 'Parent', axF2(4));
set(t,'Position', [200 .5 1]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E- Bilateral Freq Distribution : RUN VS SLEEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

fig2E = figure;%('Position', [280 450 800 420]);
ax2E = axes;%('Position', [.0775 .122 .4279 .8150], 'NextPlot', 'add'); 
% ax2E(2) = axes('Position', [.5563 .122 .4279 .8150], 'NextPlot', 'add'); 

nShuffle = 3;
freqBins = 150:3:225;

for i = 1:nShuffle
    drawnow;
    nSleep = numel(ripFreqSleep.base);
    nRun = numel(ripFreqRun.base);
    
    slpIdx = randi(nSleep, round(nSleep * .90), 1);
    runIdx = randi(nRun, round(nRun*.90), 1);
    
    dataSC = hist3([ripFreqSleep.base(slpIdx), ripFreqSleep.cont(slpIdx)], {freqBins, freqBins});
    dataRC = hist3([ripFreqRun.base(runIdx), ripFreqRun.cont(runIdx)], {freqBins, freqBins});
% 
%     dataSC = biFreqSlpCont;
%     dataRC = biFreqRunCont;
    % dataSI = biFreqSlpIpsi;
    % dataRI = biFreqRunIpsi;

    % dataS = dataS ./ max(dataS(:));
    % dataR = dataR ./ max(dataR(:));

    dataRC = smoothn(dataRC,2);
    dataSC = smoothn(dataSC,2);

    % dataRI = smoothn(dataRI,2);
    % dataSI = smoothn(dataSI,2);

    tholdS = quantile( dataRC(:), .5 );
    tholdR = quantile( dataSC(:), .5 );
    % 
    % tholdI = quantile( dataRI(:), .5 );
    % tholdI = quantile( dataSI(:), .5 );

    c{1} = contourc(freqBins, freqBins, biFreqSlpCont, [0 0] + tholdS); hold on;
    c{2} = contourc(freqBins, freqBins, biFreqRunCont, [0 0] + tholdR);

    % c{3} = contourc(freqBins, freqBins, biFreqSlpIpsi, [0 0] + tholdS); hold on;
    % c{4} = contourc(freqBins, freqBins, biFreqRunIpsi, [0 0] + tholdR);

    for i = 1:numel(c)
        result = parse_contour_matrix( c{i} );
        cont(i) = result(1);
    end

    % cSleep = contour(freqBins, freqBins, bilatFreqDistSleep, 3); hold on;
    % cRun = contour(freqBins, freqBins, bilatFreqDistRun, 3);
    % nPt = size(cSleep,2);
    % 
    % line(cSleep(2,1:(nPt/2)), cSleep( (1 + nPt/2):nPt),'linestyle', 'none', 'marker','.', 'color','r');
    % line(cRun(,1:(nPt/2)), cRun( (1 + nPt/2):nPt), 'linestyle', 'none', 'marker','.', 'color','k');

    for i = 1:numel(cont)
        [e(i).Z, e(i).A, e(i).B, e(i).ALPHA] = fitellipse( [cont(i).x; cont(i).y] );
        [el(i).x, el(i).y] = ellipse_points( e(i).Z, e(i).A, e(i).B, e(i).ALPHA );
    end

    p = [];
    p(1) = patch(el(2).x, el(2).y, [.5 1 1], 'Parent', ax2E);
    % p(4) = patch(el(4).x, el(4).y, [1 1 .5], 'Parent', ax2E(2));
    p(2) = patch(el(1).x, el(1).y, [1 .5 .5], 'Parent', ax2E);
    % p(2) = patch(el(2).x, el(2).y, [.5 .5 1], 'Parent', ax2E(2));

    set(ax2E,'XLim', [150 225], 'YLim', [150 225]);

    set(p(2), 'EdgeColor', [1 .5 .5], 'linewidth', 1);
    set(p(1), 'EdgeColor', [.5 .5 1], 'linewidth', 1);
    set(p, 'FaceColor', 'none');

end

set(ax2E, 'Units', 'Pixels');
axP = get(ax2E, 'Position');
set(ax2E,'Position', axP([1,2,4,4]) );



xlabel('Source Ripple Freq (Hz)');
ylabel('Test Ripple Freq (Hz)');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      F - Bilateral Ripple Coherence : RUN VS SLEEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
fig2F = figure;
ax2F = axes();
set(ax2F,'Xlim', [0 400], 'XTick', 0:100:400); 

F = ripCohere.sleep.F;

mCoSleep = mean(ripCohere.sleep.cohereCont);
mCoRun = mean(ripCohere.run.cohereCont);

sCoSleep = std(ripCohere.sleep.cohereCont);
sCoRun = std(ripCohere.run.cohereCont);

nRun = size(ripCohere.run.cohereCont,1);
nSleep = size(ripCohere.sleep.cohereCont,1);
nStd = 1.96;

rError = (nStd * sCoRun)/sqrt(nRun);
sError = (nStd * sCoSleep)/sqrt(nSleep);

rCorr{1} = mCoRun + rError;
rCorr{2} = mCoRun - rError;

sCorr{1} = mCoSleep + sError;
sCorr{2} = mCoSleep - sError;


X1 = [F; flipud(F)];
Y1 = [sCorr{2}./rCorr{1}, fliplr(sCorr{1}./rCorr{2})]';

mCoSleepSh = mean(ripCohere.sleep.shuffleCont);
mCoRunSh = mean(ripCohere.run.shuffleCont);

sCoSleepSh = std(ripCohere.sleep.shuffleCont);
sCoRunSh = std(ripCohere.run.shuffleCont);

nRun = size(ripCohere.sleep.shuffleCont,1);
nSleep = size(ripCohere.sleep.shuffleCont,1);
nStd = 1.96;

rError = (nStd * sCoRunSh)/sqrt(nRun);
sError = (nStd * sCoSleepSh)/sqrt(nSleep);

rCorr{1} = mCoRunSh + rError;
rCorr{2} = mCoRunSh - rError;

sCorr{1} = mCoSleepSh + sError;
sCorr{2} = mCoSleepSh - sError;


X2 = [F; flipud(F)];
Y2 = [sCorr{2}./rCorr{1}, fliplr(sCorr{1}./rCorr{2})]';
    
    
   
p(1) = patch(X1,Y1, [ .5 .7 .7] ,'Parent', ax2F);
p(2) = patch(X2,Y2, [ .7 .5 .7] ,'Parent', ax2F);

set(p,'edgecolor', 'none');

%line(F, mCoSleep./mCoRun, 'Color', [0 0 0 ], 'Parent', ax2F(2), 'linewidth', 1.5);

set(ax2F,'Xlim', [0 400], 'XTick', 0:100:400, 'YColor', 'k');
set(ax2F, 'Ylim', [.9 2.1]);

ylabel('Ratio');
xlabel(ax2F, 'Frequency Hz');

% fig2F = figure;
% ax2F = plotyy(1,1,1,1);
% 
% F = ripCohere.sleep.F;
% mCoSleep = mean(ripCohere.sleep.rippleCoherence);
% mCoRun = mean(ripCohere.run.rippleCoherence);
% 
% sCoSleep = std(ripCohere.sleep.rippleCoherence);
% sCoRun = std(ripCohere.run.rippleCoherence);
% 
% n = size(ripCohere.sleep.rippleCoherence,1);
% nStd = 3;
% 
% [p(1), l(1)] = error_area_plot(F, mCoSleep, nStd * sCoSleep / sqrt(n), 'Parent', ax2F(1));
% [p(2), l(2)] = error_area_plot(F, mCoRun, nStd * sCoRun / sqrt(n), 'Parent', ax2F(1));
% 
% % set(l(1), 'Color', [1 0 0], 'LineWidth', 1.5);
% % set(l(2), 'Color', [0 0 1], 'LineWidth', 1.5);
% 
% delete(l(1:2));
% 
% set(ax2F,'Xlim', [0 400], 'XTick', 0:100:400); 
% 
% set(p(1), 'FaceColor', [1 .7 .7], 'edgecolor', 'none');
% set(p(2), 'FaceColor', [.7 .7 1], 'edgecolor', 'none');
% uistack(p(2), 'top')
% 
% rError = (nStd * sCoRun)/sqrt(n);
% sError = (nStd * sCoSleep)/sqrt(n);
% 
% rCorr{1} = mCoRun + rError;
% rCorr{2} = mCoRun - rError;
% 
% sCorr{1} = mCoSleep + sError;
% sCorr{2} = mCoSleep - sError;
% 
% 
% X = [F; flipud(F)];
% Y = [sCorr{2}./rCorr{1}, fliplr(sCorr{1}./rCorr{2})]';
% 
% p(3) = patch(X,Y, [ .5 .7 .7] ,'Parent', ax2F(2));
% set(p(3),'edgecolor', 'none')
% 
% %line(F, mCoSleep./mCoRun, 'Color', [0 0 0 ], 'Parent', ax2F(2), 'linewidth', 1.5);
% 
% set(ax2F,'Xlim', [0 400], 'XTick', 0:100:400, 'YColor', 'k');
% set(ax2F(1),'YLim', [.15 .5], 'YTick', [0:.1:.5], 'box', 'off');
% set(ax2F(2), 'Ylim', [.9 2.1]);
% 
% uistack(ax2F(1),'top');
% set(ax2F(2),'Color', 'w');
% set(ax2F(1),'Color', 'none');
% ylabel(ax2F(1), 'Ripple Coherence');
% ylabel(ax2F(2), 'Sleep to Run Ratio');
% xlabel(ax2F(1), 'Frequency Hz');

%%

%% Save the figure
save_bilat_figure('figure2-abcd', f2Handle);
save_bilat_figure('figure2-e', fig2E);
save_bilat_figure('figure2-f', fig2F);
% 
% saveDir = '/data/bilateral/figures';
% figName = ['figure2-', datestr(now, 'yyyymmdd')];
% 
% saveFigure(fHandle, saveDir, figName, 'png', 'fig', 'svg');
% save(fullfile(saveDir, 'figure2-data.mat'))
%%
end
