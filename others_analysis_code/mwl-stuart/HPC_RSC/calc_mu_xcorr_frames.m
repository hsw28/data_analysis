function f = calc_mu_xcorr_frames(MU, method)
%%

N = numel(MU);
Fs = timestamp2fs( MU(1).ts );

eventLenThold = [.2 Inf ]; %<============

XC = cell(N,1);

maxLag = 100;
nLag = maxLag * 2 +1;

for ii = 1 : N
          
    events = durationFilter( find_mua_bursts(MU(ii)), eventLenThold);
  
    nEvent = size(events,1);
    
    %
    if nEvent < 2
        continue;
    end
    
    xc = nan(nEvent, nLag);
    xcWin = bsxfun(@plus, events, maxLag/Fs * [-1 1]);
    eventIdx = interp1(MU(ii).ts, 1:numel(MU(ii).ts), xcWin, 'nearest');
    eventIdx = eventIdx(all(~isnan(eventIdx)'),:); % remove idx with nan
    
    nEvent = size(eventIdx,1);
    fprintf('%d - detected %d events\n', ii, nEvent);

    for iEvent = 1:nEvent
        
        idx = eventIdx(iEvent,1):eventIdx(iEvent,2);
        h = MU(ii).hpc(idx)';
        c = MU(ii).ctx(idx)';
        
        switch method
            case 'none'
                xc(iEvent,:) = xcorr(c, h, maxLag, 'coeff');
            case 'wrap'
                h = repmat(h(:), 20, 1);
                c = repmat(c(:), 20, 1);
                
                xc(iEvent,:) = xcorr(c, h, maxLag, 'coeff');
        end
        
    end
    XC{ii} = xc;
    
end
fprintf('DONE!\n');


%%

f = figure;

x = cell2mat(XC);
ts = ((1:nLag) - maxLag -1) / Fs;
plot(ts, mean(x));

[~, pks] = findpeaks(mean(x));

pkTs = ts(pks);
pkTs = pkTs(pkTs > -.1 & pkTs < .25);

for i = 1:numel(pkTs)
    line( pkTs(i) * [1 1], get(gca,'YLim'), 'Color', 'k');
end

set(gca, 'Xtick', unique([ get(gca,'XTick'), pkTs]));
set(gca,'XLim', [-.5 .5]);