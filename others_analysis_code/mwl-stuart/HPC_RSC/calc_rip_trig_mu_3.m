function f = calc_rip_trig_mu(MU, HPC, fld, p)
clearvars -except MU HPC fld p
win = [-.25 .5];
N = numel(MU);
Fs = timestamp2fs(HPC(1).ts);

ripSamp = {  };
for i = 1 : N
    clear idx1 idx2 idx3 ripIdx startIdx setLen setId ripWin ripTs
    fprintf('%d ', i);
%     mu = MultiUnit{i};
    if isempty(p)
        [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs, 'pos_struct', [], 'ts', HPC(i).ts);
    else
        [ripIdx, ripWin] = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, Fs, 'pos_struct', p(i), 'ts', HPC(i).ts);
    end
    ripTs = HPC(i).ts(ripIdx);
    ripTs = ripTs( ripTs - win(1)*2 > MU(i).ts(1)  & ripTs + win(2)*2 < MU(i).ts(end) );
    %     ripTs = eeg.ts(ripWin(:,1));
    
%     doubletIdx = filter_event_sets(ripTs, 2, [.5 .25 .5]);
%     [tripletIdx, singletIdx] = filter_event_sets(ripTs, 3, [.5 .25 .5]);
    [startIdx, setLen, setId] = group_events(ripTs, [.5 .25]);
    
    idx1 = startIdx( setLen == 1 );
    idx2 = startIdx( setLen == 2 );
    idx3 = startIdx( setLen > 2 )+1;
        
    fprintf(' %d\t->\t%d\t%d\t%d\n', numel(ripTs), nnz(idx1), nnz(idx2), nnz(idx3) )
    
    [ripSamp{1,i}, ts] = meanTriggeredSignal(ripTs, MU(i).ts, MU(i).(fld), win);
    ripSamp{2,i} = meanTriggeredSignal(ripTs(idx1), MU(i).ts, MU(i).(fld), win);
    ripSamp{3,i} = meanTriggeredSignal(ripTs(idx2), MU(i).ts, MU(i).(fld), win);
    ripSamp{4,i} = meanTriggeredSignal(ripTs(idx3), MU(i).ts, MU(i).(fld), win);
    
    
    %     [ctxTrip(i,:), ts] = meanTriggeredSignal(setTs, mu.ts, mu.ctx, win);
    %     [ctxSolo(i,:), ts] = meanTriggeredSignal(soloTs, mu.ts, mu.ctx, win);
    
    
end
fprintf('\n');

%%
f = figure;
ax = axes('NextPlot', 'add');
T = ts * 1000;
c = [0 0 0; .5 0 0; 0 .5 0; 0 0 .5];
[pt, l] = deal([]);
for i = [1 2 3 4]
    r = cell2mat({ ripSamp{i,:}}');
    
%     for j = 1:size(r,1)
%         rr = r(j,:);
%         rr = rr - min(rr);
%         rr = rr / max(rr);
%         r(j,:) = rr;
%     end
    
    m = mean(r);
    e = std(r) * 1.96 / sqrt( size(r,1) );
    
    [pt(i), l(i)] = error_area_plot(T, m, e, 'Parent', ax);
    set(pt(i),'EdgeColor', 'none', 'FaceColor', c(i,:) + .4);
    set(l(i), 'color', c(i,:));
    
    [~, mIdx] = findpeaks(m);
    
    mTs = T(mIdx);
    mTs = mTs(mTs > 0 & mTs < 100);
    for j = 1:numel(mTs)
        line( mTs(j) * [1 1], [min(m), max(m)], 'color', 'k');
    end
    
    
    set(gca,'XTick', unique([get(gca,'XTick'), mTs]) );
    
end

set(ax,'Xlim', win * 1000);
% legend(p, {'All', 'Singlets', 'Doublets', 'Triplets'});

% plot2svg( sprintf('/data/HPC_RSC/ripple_triggered_%s_mu.svg', upper(fld)) ,gcf);

end
