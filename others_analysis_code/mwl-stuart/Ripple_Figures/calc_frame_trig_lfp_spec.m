clearvars -except MU CTX HPC;
clc;
N = numel(MU);

[hpcSamp, ctxSamp, hpcAnti, ctxAnti] = deal({});
[nEvent, nAntiE] = deal([]);
% ============ PARAMETERS ==============
eventLenThold = [.25 1]; 
TRIG = 'both';

for i = 1 : N
    mu = MU(i);
    switch TRIG
        case 'hpc'
            events = find_mua_bursts(MU(i));
        case 'ctx'
            events = find_ctx_frames(MU(i));
        case 'both'
            events = seg_and( find_mua_bursts(MU(i)), find_ctx_frames(MU(i)) );
    end
    
    antiEv = logical2seg(MU(i).ts, ~seg2binary(find_mua_bursts(MU(i)), MU(i).ts));
    antiEv = durationFilter(antiEv, [3 4]);
  
    events = durationFilter(events, eventLenThold);
    nEvent(i) = size(events,1);
    nAntiE(i) = size(antiEv,1);
    
    fprintf('\n\nDataSet:%d ', i);
    fprintf('detected %d & %d \n', nEvent(i), nAntiE(i));
    trigIdx = [];
    
    fprintf('HPC:Real ');
    [~, ~, ~ , hpcSamp{i}] = meanTriggeredSpectrum(events, HPC(i).ts, HPC(i).lfp);
    fprintf('HPC:Anti ');
    [~, ~, ~ , hpcAnti{i}] = meanTriggeredSpectrum(antiEv, HPC(i).ts, HPC(i).lfp);
    fprintf('CTX:Real ');
    [~, ~, ~ , ctxSamp{i}] = meanTriggeredSpectrum(events, CTX(i).ts, CTX(i).lfp);
    fprintf('CTX:Anti ');
    [~, ~, fr, ctxAnti{i}] = meanTriggeredSpectrum(antiEv, CTX(i).ts, CTX(i).lfp);

end
fprintf('\nDONE!\n');
%%

HE = cell2mat(hpcSamp');
CE = cell2mat(ctxSamp');
HA = cell2mat(hpcAnti');
CA = cell2mat(ctxAnti');

he = nanmean(HE);
ha = nanmean(HA);
ce = nanmean(CE);
ca = nanmean(CA);

close all;
figure;
line(fr, log(he ./ ha) ,'color', 'r');
% line(fr, log(ha),'color', 'c');
line(fr, log(ce ./ ca),'color', 'k');

xlabel('Frequency');
ylabel('Ratio');
legend('Hippocampus', 'RS Cortex');
set(gca,'Xlim', [0 300]);

%%
nBoot = 250;

idx = randperm(size(HA,1),size(HE,1));

ciH = bootci(nBoot, @(x) log(nanmean(x(:, 1:350)) ./ nanmean( x(:,351:end))), [HE, HA(idx,:)]);
ciC = bootci(nBoot, @(x) log(nanmean(x(:, 1:350)) ./ nanmean( x(:,351:end))), [CE, CA(idx,:)]);


%%
fr  = 1:350;
figure;

patch([fr, fliplr(fr)], [ciH(1,:), fliplr(ciH(2,:))], 'r');
patch([fr, fliplr(fr)], [ciC(1,:), fliplr(ciC(2,:))], 'b');

set(gca,'Xlim', [1, 275], 'Ylim', [-1.1 3.75]);
%%
line( [1, 350], [1 1], 'color', 'k');
line( [10, 10], [-2, 3], 'color', 'k');
line( [18, 18], [-2, 3], 'color', 'k');
set(gca,'Xlim', [1, 50], 'Ylim', [-1.1 3.75]);




%%

r = {};
r{1} = cell2mat(hpcSamp');
r{2} = cell2mat(ctxSamp');

figure('Position', [500 165 365 720]);
ax = [];
S = {'hpc', 'ctx'};
for ii = 1:numel(r);
    ax(ii) = subplot(2,1,ii);
    
    m = mean(r{ii});
    e = std(r{ii}) * 1.96 / sqrt( size(r{ii},1) );

    [p, l] = error_area_plot(T, m, e, 'Parent', ax(ii));
    
    set(p,'FaceColor', [.7 .7 .9], 'edgecolor','none');
    set(l,'Color', 'k');

    
    title( sprintf('Trig:%s %s:MUA EventDur:[%d - %d]', upper(TRIG), upper(S{ii}), round( eventLenThold*1000)));

end

lim = win * 1000;
% text(lim(1), min(m)*1.02, sprintf('%d, ', nEvent), 'parent', ax(1) );
set(ax,'Xlim', lim);
fname = sprintf('/data/HPC_RSC/FIGURES/frame_%s_trig_lfp_spec%d_%d.svg', lower(TRIG), round(eventLenThold * 1000) );
plot2svg(fname, gcf);


