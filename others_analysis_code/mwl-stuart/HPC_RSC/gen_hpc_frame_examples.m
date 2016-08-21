function f = gen_hpc_frame_examples(MU, HPC)
%%
N = numel(MU);
eegFs = timestamp2fs( HPC(1).ts );
muFs = timestamp2fs( MU(1).ts);

win  = [-.15 .35];
muWin = round( win(1)*muFs : win(2)*muFs );
eegWin = round( win(1)*eegFs : win(2)*eegFs );

hpcSamps = {};
ctxSamps = {};
eegSamps = {};

durFilt = [.3 inf];
for i = 1:N
    ripIdx = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, eegFs);
    ripTs = HPC(i).ts(ripIdx);
  
    [startIdx, setLen, setId] = group_events(ripTs, [.5 .125]);
    
    evIdx = startIdx(setLen >=2);
    evTs = ripTs(evIdx);
    
    events = durationFilter( find_mua_bursts( MU(i) ), durFilt);
    
    [~, n] = inseg(events, evTs);
    events = events( logical(n), :);
    
    nEvents = size(events,1);
    fprintf('%d - %d\n', i,edi nEvents);
    
    [~, pks] = findpeaks( MU(i).hpc ); % find all peaks
    [~, ~, k] = inseg( events, MU(i).ts(pks) ); % find peaks during events
    pks = pks( k == 1); % select the first peak in each event
    trigTs = MU(i).ts(pks);
   
    [hpcSamps{i}, ts] = meanTriggeredSignal(trigTs, MU(i).ts, MU(i).hpc, win);
    [ctxSamps{i}, ts] = meanTriggeredSignal(trigTs, MU(i).ts, MU(i).ctx, win);
    [eegSamps{i}, ts2] = meanTriggeredSignal(trigTs, HPC(i).ts, HPC(i).lfp, win);
end



%%
close all;

subplot(311);
plot(ts2, mean( cell2mat( eegSamps')));

subplot(312);
plot(ts, mean( cell2mat( hpcSamps' )));

subplot(313);
plot(ts, mean( cell2mat( ctxSamps' )));







