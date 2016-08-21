
if ~exist('meanMuaSleep', 'var') || ~exist('meanMuaRun', 'var')
	looking_for_beta_load_data
end
close all;
figure;
axes();
% line(win, meanMuaRun, 'color', 'r', 'linewidth', 2);
% line(win, meanMuaSleep, 'color', 'g', 'linewidth', 2);
ar(1) = area(win, meanMuaSleep); hold on;
ar(2) = area(win, meanMuaRun);
set(ar(1), 'FaceColor', 'y');
set(ar(2), 'FaceColor', 'b');
set(get(ar(1), 'Children'), 'FaceAlpha', .5);
set(get(ar(2), 'Children'), 'FaceAlpha', .5);
%%


idx = fliplr(1:362);
x = 0:(numel(idx)-1);

ySlp = meanMuaSleep(idx);
yRun = meanMuaRun(idx);

ySlp = ySlp - min(ySlp) + .0000001;
ySlp = ySlp ./ max(ySlp);

yRun = yRun - min(yRun) + .0000001;
yRun = yRun ./ max(yRun);
yRun(300:end) = min(yRun);

Fs = 1500;
zSlp = log(ySlp);
zRun = log(yRun);

nReg = 150;
pSlp = polyfit(x, zSlp,1);
pRun = polyfit(x(1:nReg), zRun(1:nReg),1);

ySlpHat = exp( x*pSlp(1) + pSlp(2) );
%ySlpHat = ySlpHat / max(ySlpHat);

yRunHat = exp( x*pRun(1) + pRun(2) );
yRunHat = yRunHat / max(yRunHat);

ySlpDiff = ySlp - ySlpHat;
yRunDiff = yRun - yRunHat;

[~, peakLocsSlp] = findpeaks( ySlpDiff );
[~, peakLocsRun] = findpeaks( yRunDiff );

peakTsSlp = peakLocsSlp / Fs;
peakTsRun = peakLocsRun / Fs;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        PLOT THE RESULTS
%                              SLEEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
subplot(221);
ar(1) = area(win, meanMuaSleep); 
set(ar(1), 'FaceColor', 'y');
set(get(ar(1), 'Children'), 'FaceAlpha', .5);

subplot(222);

plot(x / Fs, ySlp); hold on;
plot(x / Fs, ySlpHat,'r' );
line(x(peakLocsSlp) / Fs, ySlp(peakLocsSlp), 'color', 'k', 'Marker', 'o', 'linestyle', 'none');
xlabel('Time');
ylabel('MU Rate');
title('Ripple Triggered MUA');
set(gca,'Xlim', [0, .250]);

%legend({'Data', 'ExpModel'});
subplot(224);
plot(x/Fs, ySlpDiff, 'g');
set(gca,'Xlim', [0, .250]);


line(x(peakLocsSlp) / Fs, ySlpDiff(peakLocsSlp), 'color', 'r', 'Marker', '.', 'linestyle', 'none', 'markersize', 20);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        PLOT THE RESULTS
%                              RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
subplot(221);
ar(1) = area(win, meanMuaRun); 
set(ar(1), 'FaceColor', 'y');
set(get(ar(1), 'Children'), 'FaceAlpha', .5);

subplot(222);

plot(x / Fs, yRun); hold on;
plot(x / Fs, yRunHat,'r' );
line(x(peakLocsRun) / Fs, yRun(peakLocsRun), 'color', 'k', 'Marker', 'o', 'linestyle', 'none');
xlabel('Time');
ylabel('MU Rate');
title('Ripple Triggered MUA');
set(gca,'Xlim', [0, .250]);

%legend({'Data', 'ExpModel'});
subplot(224);
plot(x/Fs, yRunDiff, 'g');
set(gca,'Xlim', [0, .250]);


line(x(peakLocsRun) / Fs, yRunDiff(peakLocsRun), 'color', 'r', 'Marker', '.', 'linestyle', 'none', 'markersize', 20);


%saveFigure(gcf,'/home/slayton/Desktop/', 'ripple_beta');
%%
close all;
% plot(x, ySlp, x, yRun); 
 plot(x, zSlp, x, zRun);
%%
close all; figure;

plot(x / Fs, ySlpHat,'g' ); hold on;
plot(x / Fs, yRunHat,'r' );
