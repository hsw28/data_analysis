function f = calc_frame_trig_mu(MU, fld, p)
win = [-.5 .5];

N = numel(MU);
Fs = timestamp2fs(MU(1).ts);

muSamp = {};

% ============ PARAMETERS ==============
eventLenThold = [.05 1]; 

% ============ PARAMETERS ==============
nEvent = [];
for i = 1 : N
    
    if ~isempty(p)
        events = find_mua_bursts(MU(i), 'pos_struct', p(i));
    else
        events = find_mua_bursts(MU(i));
    end
    triggerSignal = MU(i).hpc;
    
    events = durationFilter(events, eventLenThold);
    d = diff(events,[],2);
    iShort = d > .15;
    
    nEvent(i) = size(events,1);
    
    fprintf('%d - detected %d events\n', i, nEvent(i));
     
    [~, pks] = findpeaks( triggerSignal ); % find all peaks
    [~, ~, k] = inseg( events, MU(i).ts(pks) ); % find peaks during events
    pks = pks( k == 1); % select the first peak in each event
    trigTs = MU(i).ts(pks);

    [~, ts, ~, muSamp{1,i}] = meanTriggeredSignal(trigTs, MU(i).ts, MU(i).(fld), win);
    [~, ts, ~, muSamp{2,i}] = meanTriggeredSignal(trigTs(iShort), MU(i).ts, MU(i).(fld), win);

end
fprintf('DONE!\n');
%%

f = figure;
ax = axes('NextPlot', 'add');

T = ts * 1000;

c = [0 0 0; .5 0 0; 0 .5 0; 0 0 .5];

[p, l] = deal([]);

for i = [1 2]
    r = cell2mat({ muSamp{i,:}}');
    
    m = mean(r);
    e = std(r) * 1.96 / sqrt( size(r,1) );
    
    [p(i), l(i)] = error_area_plot(T, m, e, 'Parent', ax);
    set(p(i),'EdgeColor', 'none', 'FaceColor', c(i,:) + .4);
    set(l(i), 'color', c(i,:));
    
    [~, mIdx] = findpeaks(m);
    
    mTs = T(mIdx);
    mTs = mTs(mTs > 0 & mTs < 100);
    for j = 1:numel(mTs)
        line( mTs(j) * [1 1], [min(m), max(m)], 'color', 'k');
    end
    
    set(gca,'XTick', unique([get(gca,'XTick'), mTs]) );
    
end

set(ax,'Xlim', [-200 300]);

end