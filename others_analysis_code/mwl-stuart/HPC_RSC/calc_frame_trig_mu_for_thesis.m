clearvars -except MU HPC CTX

win = [-.5 .5];

N = numel(MU);

[hpcSamp, ctxSamp] = deal({});

% ============ PARAMETERS ==============
eventLenThold = [.2 inf]; 
TRIG = 'both-hpc';
% ============ PARAMETERS ==============
nEvent = [];
for i = 1 : N
    
    mu = MU(i);
    
    switch TRIG
        case 'hpc'
            events = find_mua_bursts(mu);
            triggerSignal = mu.hpc;
        case 'ctx'
            events = find_ctx_frames(mu);
            triggerSignal = mu.ctx;
        case 'both-hpc'
            events = seg_and( find_mua_bursts(mu), find_ctx_frames(mu) );
            triggerSignal = mu.hpc;
        case 'both-ctx'
            events = seg_and( find_mua_bursts(mu), find_ctx_frames(mu) );
            triggerSignal = mu.ctx;
        case 'only-hpc'
            events = seg_excl( find_mua_bursts(mu), find_ctx_frames(mu) );
            triggerSignal = mu.hpc;
        case 'only-ctx'
            events = seg_excl( find_ctx_frames(mu), find_mua_bursts(mu) );
            triggerSignal = mu.ctx;           
    end
    
    
    events = durationFilter(events, eventLenThold);
    nEvent(i) = size(events,1);
    
    fprintf('%d - detected %d events\n', i, nEvent(i));
    trigIdx = [];
   
    [~, pks] = findpeaks( triggerSignal ); % find all peaks
    [~, ~, k] = inseg( events, mu.ts(pks) ); % find peaks during events
    pks = pks( k == 1); % select the first peak in each event
    trigTs = mu.ts(pks);

    [~, ts, ~, hpcSamp{i}] = meanTriggeredSignal(trigTs, mu.ts, mu.hpc, win);
    [~, ts, ~, ctxSamp{i}] = meanTriggeredSignal(trigTs, mu.ts, mu.ctx, win);

end
fprintf('DONE!\n');
%%
r = {};
T = ts * 1000;
r{1} = cell2mat(hpcSamp');
r{2} = cell2mat(ctxSamp');

figure;
ax = [];
S = {'hpc', 'ctx'};
for ii = 1:numel(r);
    ax(ii) = subplot(2,1,ii);
    
    m = mean(r{ii});
    e = std(r{ii}) * 1.96 / sqrt( size(r{ii},1) );

    [p, l] = error_area_plot(T, m, e, 'Parent', ax(ii));
    
    set(p,'FaceColor', [.7 .7 .9], 'edgecolor','none');
    set(l,'Color', 'k');

    [~, idx] = findpeaks(m);
    pkTs = T(idx);
    pkTs = pkTs(pkTs > -150 & pkTs<200);

    for i = 1:numel(pkTs)
        line( pkTs(i) * [1 1], minmax(m), 'Color', 'k');
    end
    
    set( ax(ii), 'XTick', unique([-500 250 0 250 500, pkTs]));
    set( ax(ii), 'YLim', [min(m-e), max(m+e)]);
    title( sprintf('Trig:%s %s:MUA EventDur:[%d - %d]', upper(TRIG), upper(S{ii}), round( eventLenThold*1000)));

end

lim = [-500, 500];
text(lim(1), min(m)*1.02, sprintf('%d, ', nEvent), 'parent', ax(1) );
set(ax,'Xlim', lim);



tmp = round(eventLenThold*1000);
drawnow;

fname = sprintf('/data/HPC_RSC/FIGURES/frame_%s_trig_mu_%d_%d.svg', lower(TRIG), round(eventLenThold * 1000) );
plot2svg( fname, gcf);

