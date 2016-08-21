figure; axes;

line_browser(muTs, muRate, 'Parent', gca);
seg_plot(muBurst);
%%

[s, f, t, p] = spectrogram(muRate, 300, 100, 1024,  muFs);

t = t - min(t);
t = t/max(t);
t = t * (max(muTs)-min(muTs));
t = t + min(muTs);

burstOnIdx = seg2binary(muBurst, t);
burstOffIdx = seg2binary(muBurst-2, t);

onIdx = find(burstOnIdx);
offIdx = find(burstOffIdx);
bothIdx = intersect(onIdx, offIdx);

onIdx = setdiff(onIdx, bothIdx);
offIdx = setdiff(offIdx, bothIdx);
%%
logPsdOn = log(psdOn);
logPsdOff = log(psdOff);

validIdx = ~(any(~isfinite(logPsdOff)));
logPsdOff = logPsdOff(validIdx);

logSmPsdOn = smoothn( logPsdOn, 3, 'correct', 1);
logSmPsdOff = smoothn( logPsdOff, 3, 'correct', 1);

figure;
imagesc([], f, [ logSmPsdOn, logSmPsdOff] );
set(gca,'YLim', [0 50]);


%%
randIdx = randsample(onIdx, numel(onIdx), 1);


psdOn = p(:,onIdx);
psdOff = p(:, offIdx);

close all;
plot(f, nanmean(logSmPsdOn,2)./nanmean(logSmPsdOff,2)); set(gca, 'Xlim', [0 100]);


%%


randIdx = randsample(onIdx, numel(onIdx), 1);


psdOn = p(:,onIdx);
psdOff = p(:, offIdx);


close all;
plot(f, log( mean(psdOn,2)./mean(psdOff,2) ) ); set(gca, 'Xlim', [0 100]);



%%

figure('Position', [1600 700 1920 400]);
axes('Position', [.025 .11 .96 .84]);

imagesc(t, f, log(p) ); set(gca,'YDir', 'normal','YLim', [0 100]);

seg_plot(muBurst, 'FaceColor', 'none', 'EdgeColor', 'k', 'Height', 100);

