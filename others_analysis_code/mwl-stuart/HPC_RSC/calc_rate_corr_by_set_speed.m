function f = calc_rate_corr_by_set_speed(MU, HPC, fld, p)

win = [-.1 .2];
N = numel(MU);
Fs = timestamp2fs(HPC(1).ts);

IRI = [];

slowD = .075;
fastD = .075;

CORR = [];

for i = 1 : N
    fprintf('%d\n',i);
    %     mu = MultiUnit{i};
    if ~exist('p', 'var') || isempty(p)
        [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs, 'pos_struct', [], 'ts', HPC(i).ts);
    else
        [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs, 'pos_struct', p(i), 'ts', HPC(i).ts);
    end
    ripTs = HPC(i).ts(ripIdx);
    
    [startIdx, setLen] = group_events(ripTs, [.5 .125]);
    
    evIdx = startIdx( setLen >= 2 ); % get events with 2 ripples or more
    evLen = setLen( setLen >= 2); % get lengths for events with 2 ripples or more
    evTs  = ripTs(evIdx);
    
    iri = [.5, diff(ripTs)];
    meanIri =[];
    
    for j = 1:numel(evIdx)
        r = iri( evIdx(j)+1 : evIdx(j)+evLen(j)-1 );
        meanIri(j) = mean(r);
    end
    
    IRI = [IRI, meanIri];
    
%     slowIdx = meanIri > slowD;
%     fastIdx = meanIri < fastD;
%     
%     slowIdx(end) = false;
%     fastIdx(end) = false;
%     
%     slowTs = evTs( find(slowIdx)+0 );
%     fastTs = evTs( find(fastIdx)+0 );
    
    ctx = meanTriggeredSignal(evTs, MU(i).ts, MU(i).ctx, win);
    hpc = meanTriggeredSignal(evTs, MU(i).ts, MU(i).hpc, win);
    
    CORR = [CORR, corr_col(diff(ctx'), diff(hpc')) ];
    
    
%     ctxSlow = meanTriggeredSignal(slowTs, MU(i).ts, MU(i).ctx, win);
%     hpcSlow = meanTriggeredSignal(slowTs, MU(i).ts, MU(i).hpc, win);
%     
%     ctxFast = meanTriggeredSignal(fastTs, MU(i).ts, MU(i).ctx, win);
%     hpcFast = meanTriggeredSignal(fastTs, MU(i).ts, MU(i).hpc, win);
%     
%     
%     iriS = [iriS, meanIri(slowIdx)];
%     iriF = [iriF, meanIri(fastIdx)];
    
%     fprintf('%d - nFast:%d nSlow:%d\n', i, numel(fastTs), numel(slowTs));
%     
%     [ripSamp{1,i}, ts] = meanTriggeredSignal(slowTs, MU(i).ts, MU(i).(fld), win);
%     [ripSamp{2,i}, ts] = meanTriggeredSignal(fastTs, MU(i).ts, MU(i).(fld), win);
%     
    
    %     [ripSamp{3,i}, ts] = meanTriggeredSignal(ripTs, MU(i).ts, MU(i).(fld), win);
    %     ripSamp{3,i} = ripSamp{1,i}(idx2,:);
    %     ripSamp{4,i} = ripSamp{1,i}(idx3,:);
    
    %     [ctxTrip(i,:), ts] = meanTriggeredSignal(setTs, mu.ts, mu.ctx, win);
    %     [ctxSolo(i,:), ts] = meanTriggeredSignal(soloTs, mu.ts, mu.ctx, win);
    
    
end
fprintf('\n');

%%
f = figure;
ax = axes('NextPlot','add');
T = ts * 1000;
c = [0 0 0; .5 0 0; 0 .5 0; 0 0 .5];
[pt, l] = deal([]);

for i = [1 2 ]
    r = cell2mat({ ripSamp{i,:}}');
    
    
    m = mean(r);
    e = std(r) * 1.96 / sqrt( size(r,1) );
    
    idx = round(T) >= -100 & round(T) <= 400;
    
    [pt(i), l(i)] = error_area_plot(T(idx), m(idx), e(idx), 'Parent', ax);
    set(pt(i),'EdgeColor', 'none', 'FaceColor', c(i,:) + .4);
    set(l(i), 'color', c(i,:));
    
    [~, mIdx] = findpeaks(m);
    
    mTs = T(mIdx);
    mTs = mTs(mTs > 0 & mTs < 150);
    for j = 1:numel(mTs)
        line( mTs(j) * [1 1], [min(m), max(m)], 'color', 'k');
    end
    
    set(gca,'XTick', unique([get(gca,'XTick'), mTs]) );
    title(fld)
end


set(ax,'Xlim', [-100 400]);

% plot2svg( sprintf('/data/HPC_RSC/ripple_triggered_%s_mu.svg', upper(fld)) ,gcf);

end
