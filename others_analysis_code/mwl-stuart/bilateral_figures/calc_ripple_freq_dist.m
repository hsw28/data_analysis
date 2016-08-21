clear;
allRipples = dset_load_ripples;
%%
clearvars -except allRipples

peakIdx = find(allRipples.sleep(1).window == 0);

sleep.meanFreq = {[],[],[]};
sleep.instFreq = {[],[],[]};

for i = 1:numel( allRipples.sleep)
    r = allRipples.sleep(i);
   
    for j = 1:3
        sleep.meanFreq{j} = [sleep.meanFreq{j}; r.meanFreq{j}(:)];
        sleep.instFreq{j} = [sleep.instFreq{j}; r.instFreq{j}(:, peakIdx)];
    end
end
    
run.meanFreq = {[],[],[]};
run.instFreq = {[],[],[]};


for i = 1:numel( allRipples.run)
    r = allRipples.run(i);
    
    for j = 1:3
        run.meanFreq{j} = [run.meanFreq{j}; r.meanFreq{j}(:)];
        run.instFreq{j} = [run.instFreq{j}; r.instFreq{j}(:, peakIdx)];
    end
    
end
%%
close all;
figure('Position', [143 485 1030 420]); 
fld = 'meanFreq';


subplot(121); hold on;
plot(run.(fld){1}, run.(fld){2}, 'b.');
plot(run.(fld){1}, run.(fld){3}, 'r.');

subplot(122); hold on;
plot(sleep.(fld){1}, sleep.(fld){2}, 'b.');
plot(sleep.(fld){1}, sleep.(fld){3}, 'r.');

set(get(gcf,'Children'), 'XLim', [150 230], 'YLim', [150 230]);

%%

bins = 140:1:225;
h1 = hist3([sleep.meanFreq{1}, sleep.meanFreq{3}], {bins, bins});
h2 = hist3([run.meanFreq{1}, run.meanFreq{3}], {bins, bins});

h1 = h1 > quantile(h1(:), .1);
h2 = h2 > quantile(h2(:), .2);

h1 = smoothn(h1, 2);
h2 = smoothn(h2, 2);

figure('Position', [143 485 1030 420]); 

subplot(121);
imagesc(bins, bins, h1);

subplot(122); 
imagesc(bins, bins, h2);

set(get(gcf,'Children'), 'XLim', [150 220], 'YLim', [150 220], 'YDir', 'normal');

%% 
figure;
img = h1;
img(:,:,2) = h2;
img(:,:,3) = 0;

img = 1 - img/2;
imagesc(bins, bins, img-.0001);
set(gca,'YDir', 'normal');
%%

%% Ripple Freq Correlations
idxR = ~isnan(run.instFreq{1}) & ~isnan(run.instFreq{2}) & ~isnan(run.instFreq{3});
idxS = ~isnan(sleep.instFreq{1}) & ~isnan(sleep.instFreq{2}) & ~isnan(sleep.instFreq{3});

runInstCorr = corr([run.instFreq{1}(idxR), run.instFreq{2}(idxR), run.instFreq{3}(idxR)]);
sleepInstCorr = corr([sleep.instFreq{1}(idxS), sleep.instFreq{2}(idxS), sleep.instFreq{3}(idxS)]);


runMeanCorr = corr([run.meanFreq{1}(idxR), run.meanFreq{2}(idxR), run.meanFreq{3}(idxR)]);
sleepMeanCorr = corr([sleep.meanFreq{1}(idxR), sleep.meanFreq{2}(idxR), sleep.meanFreq{3}(idxR)]);

fprintf('\n\n---------------------------------------------------------------------\n');
fprintf('Corr Run\tInst Freq\tIpsi:%3.3f\tContra:%3.3f\n', runInstCorr(2:3));
fprintf('Corr Sleep\tInst Freq\tIpsi:%3.3f\tContra:%3.3f\n', sleepInstCorr(2:3));
fprintf('---------------------------------------------------------------------\n');
fprintf('Corr Run\tMean Freq\tIpsi:%3.3f\tContra:%3.3f\n', runMeanCorr(2:3));
fprintf('Corr Sleep\tMean Freq\tIpsi:%3.3f\tContra:%3.3f\n', sleepMeanCorr(2:3));

%%
fld = 'meanFreq';
bins = 140:1:220;

hSleep = histc(sleep.(fld), bins);
hRun = histc(run.(fld), bins);

hSleep = smoothn(hSleep, 2);
hRun = smoothn(hRun, 2);

hSleep = hSleep ./ sum(hSleep);
hRun = hRun ./ sum(hRun);

figure;
axes;
line(bins, hSleep, 'color', 'r');
line(bins, hRun, 'color', 'b');
legend({'Sleep', 'Run'});

%%

[sleep.mu sleep.sigma, sleep.muCI, sleep.sigmaCI] = normfit(sleep.(fld));
[run.mu run.sigma, run.muCI, run.sigmaCI] = normfit(run.(fld));