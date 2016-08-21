clearvars -except MU CTX HPC

win = [-.15 .35];

N = numel(CTX);

[hpcSamp1, hpcSamp2, ctxSamp1, ctxSamp2] = deal({});
Fs = timestamp2fs( HPC(1).ts);
for i = 1 : N
     
    [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs);
    
    ripTs = HPC(i).ts(ripIdx);
      
    [setIdx, soloIdx] = filter_event_sets(ripTs, 2, [1 .2 1]);
    
    fprintf('%d %d\t->\t%d\t:\t%d\n', i, numel(ripTs), numel(setIdx), numel(soloIdx));
    
    setTs = ripTs(setIdx);
    soloTs = ripTs(soloIdx);
    
    [~, ts, hpcSamp1{i}] = meanTriggeredSignal(setTs,  HPC(i).ts, HPC(i).lfp, win);
    [~, ts, hpcSamp2{i}] = meanTriggeredSignal(soloTs, HPC(i).ts, HPC(i).lfp, win);
    
    [~, ts, ctxSamp1{i}] = meanTriggeredSignal(setTs,  CTX(i).ts, CTX(i).lfp, win);
    [~, ts, ctxSamp2{i}] = meanTriggeredSignal(soloTs, CTX(i).ts, CTX(i).lfp, win);
    
end
fprintf('\n');

%%
R = { {hpcSamp1, hpcSamp2}, {ctxSamp1, ctxSamp2} };
T = ts * 1000;
n = 0;
figure('Position', [500 175 600 875]);
ax = [];
c = [.7  1 .7; .7 .7 1];
for ii = 1:2
    ax(ii) = subplot(2,1,ii);
    for jj = [2 1]
                
        r = cell2mat(R{ii}{jj}');
        m = nanmean(r);
        e = nanstd(r) * 1.96 ./sqrt(size(r,1));
        
        [p, l] = error_area_plot(T, m, e, 'Parent', ax(ii));    
        set(p,'FaceColor', c(jj,:), 'edgecolor','none');
        set(l,'Color', 'k');
    end
end
set(ax,'XLim', win * 1000);
fname = '/data/HPC_RSC/FIGURES/rip_trig_lfp.svg';
plot2svg(fname, gcf);
