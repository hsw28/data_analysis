figure; axes;

line_browser(muTs, muRate, 'Parent', gca);
seg_plot(muBurst);
%%

[s, f, t, p] = spectrogram(mu.rate, 100, 50, 1024,  mu.Fs);

t = t - min(t);
t = t/max(t);
t = t * (max(mu.timestamps)-min(mu.timestamps));
t = t + min(muTs);

burstOnIdx = seg2binary(mu.bursts, t);
burstOffIdx = seg2binary(mu.bursts-2, t);

onIdx = find(burstOnIdx);
offIdx = find(burstOffIdx);
bothIdx = intersect(onIdx, offIdx);

onIdx = setdiff(onIdx, bothIdx);
offIdx = setdiff(offIdx, bothIdx);

%% - Plot the power ratio between the two sets of spectra

psdOn = p(:,onIdx);
psdOff = p(:, offIdx);

close all;
subplot(3,1,1:2);
plot(f, log( mean(psdOn,2)./mean(psdOff,2) ) ); set(gca, 'Xlim', [0 40]);
subplot(313);
plot(f, log( mean(psdOn,2)), f, log(mean(psdOff,2) ) ); set(gca, 'Xlim', [0 40]);

%% OTHER RANDOM STUFF UNDER HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

logPsdOn = log(p(:,onIdx));
logPsdOff = log(p(:,offIdx));

%validIdx = ~(any(~isfinite(logPsdOff)));
%logPsdOff = logPsdOff(validIdx);

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
close all;
plot(f, log( mean(psdOn,2)), f, log(mean(psdOff,2) ) ); set(gca, 'Xlim', [0 100]);



%%

figure('Position', [1600 700 1920 400]);
axes('Position', [.025 .11 .96 .84]);

imagesc(t, f, log(p) ); set(gca,'YDir', 'normal','YLim', [0 100]);

seg_plot(muBurst, 'FaceColor', 'none', 'EdgeColor', 'k', 'Height', 100);

