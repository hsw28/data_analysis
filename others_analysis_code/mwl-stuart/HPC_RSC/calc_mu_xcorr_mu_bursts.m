function f = calc_mu_xcorr_frames(MU, method)
%%
end
clearvars -except MultiUnit LFP

N = numel(MultiUnit);
Fs = timestamp2fs( MultiUnit{1}.ts );

eventLenThold = [.175 Inf ]; %<============

XC = cell(N,1);

maxLag = 100;
nLag = maxLag * 2 +1;

for ii = 1 : N
    
    mu = MultiUnit{ii};
      
    events = durationFilter( find_mua_bursts(mu), eventLenThold);
  
    nEvent = size(events,1);
    
    %
    if nEvent < 2
        continue;
    end
    
    % Classify burst by SWS state
    %     swsIdx = inseg(sws, muBursts, 'partial');
    muPkIdx = [];
    
    xc = nan(nEvent, nLag);
    xcWin = bsxfun(@plus, events, maxLag/Fs * [-1.5 1.5]);
    eventIdx = interp1(mu.ts, 1:numel(mu.ts), xcWin, 'nearest');
    eventIdx = eventIdx(all(~isnan(eventIdx)'),:); % remove idx with nan
    
    nEvent = size(eventIdx,1);
    fprintf('%d - detected %d events\n', ii, nEvent);

    for iEvent = 1:nEvent
        
        idx = eventIdx(iEvent,1):eventIdx(iEvent,2);
        xc(iEvent,:) = xcorr( mu.ctx(idx)', mu.hpc(idx)', maxLag, 'coeff');
        
    end
    XC{ii} = xc;
    
end
fprintf('DONE!\n');
ts = 1000 * ((1:nLag) - maxLag -1) / Fs;


%%

clearvars -except MultiUnit LFP

N = numel(MultiUnit);
Fs = timestamp2fs( MultiUnit{1}.ts );

eventLenThold = [.25 Inf ]; %<============

XC = cell(N,1);

maxLag = 40;
nLag = maxLag * 2 +1;

for ii = 1 : N
    
    mu = MultiUnit{ii};
    nTs = numel(mu.ts);
    
    events = find_mua_bursts(mu);
    
%     events = logical2seg( ~seg2binary(events, mu.ts) ); % invert segments
    
    events = durationFilter( events, eventLenThold);
  
   
    eventIdx = interp1(mu.ts, 1:numel(mu.ts), events, 'nearest');
    eventIdx = eventIdx(all(~isnan(eventIdx)'),:); % remove idx with nan
    eventIdx = bsxfun(@plus, eventIdx, maxLag * [-1 1]);
    eventIdx = eventIdx( all(eventIdx > 1 + maxLag , 2) & all(eventIdx < nTs - maxLag , 2), :);
    
    nEvent = size(eventIdx,1);
    xc = nan(nEvent, nLag);

    fprintf('%d - detected %d events\n', ii, nEvent);

    for iEvent = 1:nEvent
        
        idx = eventIdx(iEvent,1):eventIdx(iEvent,2);
        xc(iEvent,:) = xcorr_win( mu.ctx, mu.hpc, idx, maxLag, 'coeff');
        
    end
    XC{ii} = xc;
    
end
fprintf('DONE!\n');
ts = 1000 * ((1:nLag) - maxLag -1) / Fs;

%%
xcAll = cell2mat(XC);

% close all; 
% figure;


m = nanmean(xcAll);
e = nanstd(xcAll) * 1.96 / sqrt( nnz(isfinite(xcAll(:,1))) );

% figure; ax = axes();
[p, l] = error_area_plot(ts, m, e, 'Parent', ax);
set(p,'FaceColor', 'r');

set(ax,'XLim', minmax(ts));
%%

figure('Position', [360 440 580 260]);
ax = axes('FontSize', 14, 'NextPlot', 'add');
plot([0 0], minmax(mean(xcAll)), 'color', [.5 .5 .5]);
plot(ts, mean( xcAll ));
title('RSX - HPC MU XCorr');
ylabel('Correlation Coefficient');
xlabel('Time Lag (s)');
%%

plot2svg('/data/HPC_RSC/mu_rate_hpc_rsc_xcorr.svg',gcf);