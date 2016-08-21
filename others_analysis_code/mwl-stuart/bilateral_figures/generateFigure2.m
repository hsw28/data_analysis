function generateFigure2
%% Load all the data required for plotting!
clear;
ripples = dset_load_ripples;

%%
clear rPhase rFreq cPhase cFreq aPhase aFreq sAmp cSAmp rAmp cRAmp
[rPhase.S, cPhase.S, aPhase.S] = calc_bilateral_ripple_phase_diff(ripples.sleep);
[rFreq.S,  cFreq.S, aFreq.S] = calc_bilateral_ripple_freq_distribution(ripples.sleep);

[rPhase.R, cPhase.R, aPhase.R] = calc_bilateral_ripple_phase_diff(ripples.run);
[rFreq.R, cFreq.R, aFreq.S] = calc_bilateral_ripple_freq_distribution(ripples.run);

[rAmp.S, cRAmp.S] = calc_bilateral_ripple_amplitude(ripples.sleep);
[rAmp.R, cRAmp.R] = calc_bilateral_ripple_amplitude(ripples.run);

[sAmp.S, cSAmp.S] = calc_bilateral_sharpwave_amplitude(ripples.sleep);
[sAmp.R, cSAmp.R] = calc_bilateral_sharpwave_amplitude(ripples.run);

%% Close any existing figures
close all;

%% Construct the figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      A, B - Bilateral Ripple Mean Freq Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

f1 = figure; 
ax(1) = subplot(221);
ax(2) = subplot(222);
ax(3) = subplot(223);
ax(4) = subplot(224);

freqBins = 150:1:225;

fDist{1} = hist3([rFreq.R.trig, rFreq.R.ipsi], {freqBins, freqBins});
fDist{2} = hist3([rFreq.S.trig, rFreq.S.ipsi], {freqBins, freqBins});
fDist{3} = hist3([rFreq.R.trig, rFreq.R.cont], {freqBins, freqBins});
fDist{4} = hist3([rFreq.S.trig, rFreq.S.cont], {freqBins, freqBins});

fCorr(1) = corr(rFreq.R.trig, rFreq.R.ipsi);
fCorr(2) = corr(rFreq.S.trig, rFreq.S.ipsi);
fCorr(3) = corr(rFreq.R.trig, rFreq.R.cont);
fCorr(4) = corr(rFreq.S.trig, rFreq.S.cont);

[b{1}, ~, ~, ~, rSq{1}] = regress( rFreq.R.ipsi, [rFreq.R.trig, ones(size(rFreq.R.trig))]);
[b{2}, ~, ~, ~, rSq{2}] = regress( rFreq.S.ipsi, [rFreq.S.trig, ones(size(rFreq.S.trig))]);
[b{3}, ~, ~, ~, rSq{3}] = regress( rFreq.R.cont, [rFreq.R.trig, ones(size(rFreq.R.trig))]);
[b{4}, ~, ~, ~, rSq{4}] = regress( rFreq.S.cont, [rFreq.S.trig, ones(size(rFreq.S.trig))]);



t = {'Ipsi Run', 'Ipsi Sleep', 'Cont Run', 'Cont Sleep'};


for i = 1:4
   
    img = fDist{i};
    
%     img = smoothn(img,.75);
    img = img - min(img(:));
    img = img ./ max(img(:));
    
    
    img = 1 - repmat( img, [1 1 3] );
    imagesc(freqBins, freqBins, img, 'Parent', ax(i));
    
    line(freqBins, freqBins * b{i}(1) + b{i}(2), 'color', 'r', 'parent', ax(i));
    
    title(ax(i),sprintf('%s  r:%3.3f R^2:%3.3f',  t{i}, fCorr(i),  rSq{i}(1)), 'FontSize', 14);
    
    imwrite(img, sprintf('/data/bilateral/fig2_img_%d.png', i), 'png');
    
    
    
end

set(ax, 'YDir', 'normal');

figName = 'Fig2_BilateralFreqDist';
save_bilat_figure(figName, f1);

return;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Ripple Freq Distribution by Animal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


freq = [];
g = [];
for i = 1:10
   freq = [freq; ripples.sleep(i).meanFreq{1}];
   g = [g; ones(size(ripples.sleep(i).peakIdx))*i];
end

f = figure; 
boxplot(freq, g);
figName = 'Fig2_sup_RippleFreqDist_ByAnimal';

save_bilat_figure(figName, f);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Ripple Freq Distribution by Animal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


freqT = [];
freqS = [];
freqI = [];
freqC = [];

for i = 1:10
   nRip = numel( ripples.sleep(i).peakIdx );
   idx = randsample(nRip, nRip, 1);
   
   freqS = [freqS; ripples.sleep(i).meanFreq{1}(idx)];
   freqT = [freqT; ripples.sleep(i).meanFreq{1}];
   freqI = [freqI; ripples.sleep(i).meanFreq{2}];
   freqC = [freqC; ripples.sleep(i).meanFreq{3}];
  
end


freqBins = 150:1:225;

fDist{1} = hist3([freqT, freqI], {freqBins, freqBins});
fDist{2} = hist3([freqT, freqC], {freqBins, freqBins});

fDist{3} = hist3([freqS, freqI], {freqBins, freqBins});
fDist{4} = hist3([freqS, freqC], {freqBins, freqBins});

c(1) = corr(freqT, freqI);
c(2) = corr(freqT, freqC);
c(3) = corr(freqS, freqI);
c(4) = corr(freqS, freqC);

t = {'Ipsilateral', 'Contralateral', 'Ipsi-Shuffle', 'Contra-Shuffle'};

f = figure;  
ax(1) = subplot(221);
ax(2) = subplot(222);
ax(3) = subplot(223);
ax(4) = subplot(224);

for i = 1:numel(ax);
   
    img = fDist{i};
    
    img = smoothn(img,.75);
    img = img - min(img(:));
    img = img ./ max(img(:));
    
    
    img = 1 - repmat( img, [1 1 3] );
    imagesc(freqBins, freqBins, img, 'Parent', ax(i));
    
    imwrite(img, sprintf('/data/bilateral/fig2_img_shuf_%d.png', i), 'png');
    title(ax(i), sprintf('%s R^2:%3.3f', t{i}, c(i)) );
end

set( ax, 'YDir', 'normal');
figName = 'Fig2_BilateralFreqDist_Sleep_WithShuffle';

save_bilat_figure(figName, f);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Ripple Freq Corr vs Shuffles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%


f = figure;
axes('NextPlot','Add');

[f,x] = ksdensity(cFreq.S.contShuf);

line(x,f,'Color', 'b');

line(cFreq.S.cont * [1 1], max(f) * [0 1], 'color', 'r');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Ripple Frequency Distributions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
freqBins = 150:1:225;

[muS, sigS, muCiS, sigCiS] = normfit(rFreq.S.trig);
[muR, sigR, muCiR, sigCiR] = normfit(rFreq.R.trig);

fS(1,:) = normpdf(freqBins, muCiS(1), sigCiS(1));
fS(2,:) = normpdf(freqBins, muCiS(2), sigCiS(1));
fS(3,:) = normpdf(freqBins, muCiS(1), sigCiS(2));
fS(4,:) = normpdf(freqBins, muCiS(2), sigCiS(2));

fR(1,:) = normpdf(freqBins, muCiR(1), sigCiR(1));
fR(2,:) = normpdf(freqBins, muCiR(2), sigCiR(1));
fR(3,:) = normpdf(freqBins, muCiR(1), sigCiR(2));
fR(4,:) = normpdf(freqBins, muCiR(2), sigCiR(2));


f = figure;

ax = axes;
x = [freqBins, fliplr(freqBins)];
y1 = [max(fS), fliplr( min(fS))];
y2 = [max(fR), fliplr( min(fR))];


p(1) = patch( x, y2, 'b', 'Parent', ax);
p(2) = patch( x, y1, 'r', 'Parent', ax); 

set(p, 'EdgeColor', 'none');
xlabel('Frequency');
ylabel('Probability');
legend({'Run', 'Sleep'});

figName = 'Fig2_SleepVsRun_FreqDist';
save_bilat_figure(figName, f);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E- Ripple Amplitude Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
f1 = figure; 
ax(1) = subplot(221);
ax(2) = subplot(222);
ax(3) = subplot(223);
ax(4) = subplot(224);

rAmpBins = 0:5:800;

rAmpDist{1} = hist3([rAmp.R.trig, rAmp.R.ipsi], {rAmpBins, rAmpBins});
rAmpDist{2} = hist3([rAmp.S.trig, rAmp.S.ipsi], {rAmpBins, rAmpBins});
rAmpDist{3} = hist3([rAmp.R.trig, rAmp.R.cont], {rAmpBins, rAmpBins});
rAmpDist{4} = hist3([rAmp.S.trig, rAmp.S.cont], {rAmpBins, rAmpBins});

fCorr(1) = corr(rAmp.R.trig, rAmp.R.ipsi);
fCorr(2) = corr(rAmp.S.trig, rAmp.S.ipsi);
fCorr(3) = corr(rAmp.R.trig, rAmp.R.cont);
fCorr(4) = corr(rAmp.S.trig, rAmp.S.cont);

t = {'Ipsi Run', 'Ipsi Sleep', 'Cont Run', 'Cont Sleep'};


for i = 1:4
   
    img = rAmpDist{i};
    
    img = smoothn(img,1);
    img = img - min(img(:));
    img = img ./ max(img(:));
    
    
    img = 1 - repmat( img, [1 1 3] );
    imagesc(rAmpBins, rAmpBins, img, 'Parent', ax(i));
    title(ax(i),sprintf('%s  R^2:%3.3f',  t{i}, fCorr(i) ), 'FontSize', 14);
    
    imwrite(img, sprintf('/data/bilateral/ripAmpDist2_img_%d.png', i), 'png');
    
end

set(ax, 'YDir', 'normal');


figName = 'Fig2_BilateralRipAmpDist';
save_bilat_figure(figName, f1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E- SharpWave Amplitude Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
f1 = figure; 
ax(1) = subplot(221);
ax(2) = subplot(222);
ax(3) = subplot(223);
ax(4) = subplot(224);

sAmpBins = 0:10:2000;
swAmpDist{1} = hist3([sAmp.R.trig, sAmp.R.ipsi], {sAmpBins, sAmpBins});
swAmpDist{2} = hist3([sAmp.S.trig, sAmp.S.ipsi], {sAmpBins, sAmpBins});
swAmpDist{3} = hist3([sAmp.R.trig, sAmp.R.cont], {sAmpBins, sAmpBins});
swAmpDist{4} = hist3([sAmp.S.trig, sAmp.S.cont], {sAmpBins, sAmpBins});

t = {'Ipsi Run', 'Ipsi Sleep', 'Cont Run', 'Cont Sleep'};
fCorr(1) = cSAmp.R.ipsi;
fCorr(2) = cSAmp.S.ipsi;
fCorr(3) = cSAmp.R.cont;
fCorr(4) = cSAmp.S.cont;

for i = 1:4
   
    
    img = swAmpDist{i};
    img(1,:) = 0;
    img(:,1) = 0;
    img = smoothn(img,1, 'correct', 1);
    img = img - min(img(:));
    img = img ./ max(img(:));
    
    
    img = 1 - repmat( img, [1 1 3] );
    imagesc(sAmpBins, sAmpBins, img, 'Parent', ax(i));
    title(ax(i),sprintf('%s  R^2:%3.3f',  t{i}, fCorr(i) ), 'FontSize', 14);
    
    imwrite(img, sprintf('/data/bilateral/swAmpDist2_img_%d.png', i), 'png');
    
end

set(ax, 'YDir', 'normal');


figName = 'Fig2_BilateralSharpWaveAmpDist';
save_bilat_figure(figName, f1);

return;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E, F - Bilateral Ripple Peak Phase Distribution
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bins = -(pi) : pi/8 : (pi + pi/8);

[h(1), ax(1)]  = polar_hist( rPhase.S.trig - rPhase.S.ipsi, bins);


title( sprintf('%s - Ipsi:%3.2f Cont:%3.2f', 'Sleep', cPhase.S.ipsi, cPhase.S.cont), 'fontsize', 14);

[h(2), ax(2)] = polar_hist(rPhase.S.trig - rPhase.S.cont, bins);
% [h(3), ax(2)] = polar_hist( rPhase.R.trig - rPhase.R.ipsi, bins);
% h(4) = polar_hist(ax(2), rPhase.R.trig - rPhase.R.cont, bins);
title(sprintf('%s - Ipsi:%3.2f Cont:%3.2f', 'Run', cPhase.R.ipsi, cPhase.R.cont), 'fontsize', 14);

set(h(2), 'FaceColor', 'r');
set(h, 'linewidth',2);

f1 = get(ax(1),'Parent');
f2 = get(ax(2),'Parent');

figName1 = 'Fig2_deltaRipplePhase_sleep';
figName2 = 'Fig2_deltaRipplePhase_run';

save_bilat_figure(figName1, f1);
save_bilat_figure(figName2, f2);


% rose2(ripPhaseSleep.dPhaseCont, bins, 'Parent', axF2(1));


% title('Ripple Phase difference distribution', 'Parent', axF2(2));

% set(axF2(4), 'XLim', [-1.05 1.05] * pi , 'XTick', -pi:pi/2:pi);
% set(axF2(4), 'XTickLabel', {'-pi','-pi/2',  '0', 'pi/2', 'pi'});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Ripple Frequency Distributions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
freqBins = 150:1:225;

A1 = rAmp.S.trig;
A2 = rAmp.S.ipsi;
F = rFreq.S.trig;

ampThold = 225;
idxH = A1 > 175 & A2 > ampThold;
idxL = A1 < 175 & A2 < ampThold;

fHigh = F(idxH);
fLow = F(idxL);

[muH, sigH, muCiH, sigCiH] = normfit(fHigh);
[muL, sigL, muCiL, sigCiL] = normfit(fLow);

fH(1,:) = normpdf(freqBins, muCiH(1), sigCiH(1));
fH(2,:) = normpdf(freqBins, muCiH(2), sigCiH(1));
fH(3,:) = normpdf(freqBins, muCiH(1), sigCiH(2));
fH(4,:) = normpdf(freqBins, muCiH(2), sigCiH(2));

fL(1,:) = normpdf(freqBins, muCiL(1), sigCiL(1));
fL(2,:) = normpdf(freqBins, muCiL(2), sigCiL(1));
fL(3,:) = normpdf(freqBins, muCiL(1), sigCiL(2));
fL(4,:) = normpdf(freqBins, muCiL(2), sigCiL(2));

fR(1,:) = normpdf(freqBins, muCiR(1), sigCiR(1));
fR(2,:) = normpdf(freqBins, muCiR(2), sigCiR(1));
fR(3,:) = normpdf(freqBins, muCiR(1), sigCiR(2));
fR(4,:) = normpdf(freqBins, muCiR(2), sigCiR(2));

f = figure;

ax = axes;
x = [freqBins, fliplr(freqBins)];
y1 = [max(fH), fliplr( min(fH))];
y2 = [max(fL), fliplr( min(fL))];
y3 = [max(fR), fliplr( min(fR))];

% patch( x, y3, 'g', 'Parent', ax);
patch( x, y2, 'b', 'Parent', ax);
patch( x, y1, 'r', 'Parent', ax); 


set( get(gca,'Children'), 'EdgeColor', 'none');
xlabel('Frequency');
ylabel('Probability');
% legend({'Run', 'Sleep - Low', 'Sleep - High'});
legend({'Sleep - Low', 'Sleep - High'});

figName = 'Ripple_freq_distribution_High_vs_Low_Amplitude';
save_bilat_figure(figName, f);

%%
% 
% close all;
% 
% % [F, X, U] = ksdensity(rAmp.S.trig);
% 
% A = rAmp.S.trig;
% idxL = A < 200;
% idxH = A > 150;
% 
% [m1, s1] = normfit(A(idxL));
% [m2, s2] = normfit(A(idxH));
% 
% bins = 0:5:800;
% 
% f1 = normpdf(bins, m1, s1);
% f2 = normpdf(bins, m2, s2);
% 
% f1C = sum(f1) / (sum(f1) + sum(f2));
% f2C = sum(f2) / (sum(f1) + sum(f2));
% 
% 
% 
% [F, X] = ksdensity(A, bins, 'width',  20);
% 
% figure;
% axes('NextPlot','add');
% 
% bar(X, F, 1, 'g');
% line(bins, f1/3, 'color', 'r', 'linewidth', 2);
% line(bins, f2/1.75, 'color', 'b', 'linewidth', 2);


% %
% close all;
% 
% [F, X, U] = ksdensity(rAmp.S.trig);
% 
% A = rAmp.S.ipsi;
% idxL = A < 200;
% idxH = A > 150;
% 
% [m1, s1] = normfit(A(idxL));
% [m2, s2] = normfit(A(idxH));
% 
% 
% bins = 0:10:800;
% 
% gmfit = gmdistribution.fit(A,2);
% f = pdf(gmfit, bins');
% 
% [F, X] = ksdensity(A, bins, 'width', 2);
% 
% close all;
% figure; axes('NextPlot', 'add')
% bar(X,F,1);
% line(bins, f, 'color', 'r', 'linewidth', 2);
% 
% xlabel('Amplitude');
% 


%%

end