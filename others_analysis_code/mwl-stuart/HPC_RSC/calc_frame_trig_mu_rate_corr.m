function f = calc_frame_trig_mu_rate_corr(MU, fld)
win = [-.5 .5];

N = numel(MU);

[highCorr, lowCorr] = deal({});
corrThold = [-.3 .3];
% ============ PARAMETERS ==============
eventLenThold = [.2 1]; 
TRIG = 'both-hpc';
% ============ PARAMETERS ==============
nEvent = [];
c = {};
d = {};
for i = 1 : N
    
    events = seg_and( find_mua_bursts(MU(i)), find_ctx_frames(MU(i)) );
    triggerSignal = MU(i).hpc;
    
    events = durationFilter(events, eventLenThold);
    nEvent(i) = size(events,1);
    
    fprintf('%d - detected %d events\n', i, nEvent(i));
    
    c{i} = nan(1, nEvent(i));
    d{i} = diff(events,[],2);
    for j = 1:nEvent(i)
        tsIdx = MU(i).ts >= events(j, 1) & MU(i).ts <= events(j,2);
        c{i}(j) = corr( MU(i).hpc(tsIdx)', MU(i).ctx(tsIdx)');
    end
    
        
    [~, pks] = findpeaks( triggerSignal ); % find all peaks
    [~, ~, k] = inseg( events, MU(i).ts(pks) ); % find peaks during events
    pks = pks( k == 1); % select the first peak in each event
    trigTs = MU(i).ts(pks);

    [~, ts, ~, highCorr{i}] = meanTriggeredSignal(trigTs( c{i} > corrThold(2) ), MU(i).ts, MU(i).(fld), win);
    [~, ts, ~, lowCorr{i}]  = meanTriggeredSignal(trigTs( c{i} > corrThold(1) ), MU(i).ts, MU(i).(fld), win);

end
fprintf('DONE!\n');
%%

r = {};
T = ts * 1000;
r{1} = cell2mat(highCorr');
r{2} = cell2mat(lowCorr');

f = figure;
ax = [];
S = {'Corr', 'Anti'};
for ii = 1:numel(r);
    ax(ii) = subplot(3,1,ii);
    
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
    title( sprintf('%s MUR - %s -  EventDur:[%d - %d]', upper(fld), upper(S{ii}), round( eventLenThold*1000)));

    
end

lim = [-500, 500];
text(lim(1), min(m)*1.02, sprintf('%d, ', nEvent), 'parent', ax(1) );
set(ax,'Xlim', lim);

c = cell2mat(c);
d = cell2mat(d');

subplot(325);
plot( c, d, '.');
title( sprintf('Corr: %4.4f', corr(c', d) ) );
end
