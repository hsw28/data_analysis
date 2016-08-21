function f = gen_rip_trig_examples(MU, HPC, fld)
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
spikeTimes = {};
CST = {};
HST = {};
eventTS = {};
for i = 1:N
    
    ripIdx = detectRipples(HPC(i).ripple, HPC(i).rippleEnv, eegFs);
    ripTs = HPC(i).ts(ripIdx);
    
    
    [startIdx, setLen, setId] = group_events(ripTs, [.5 .125]);
    
    evIdx = startIdx(setLen >=3);
    evTs = ripTs(evIdx);
    
    fprintf('%d - %d\n', i, numel(evIdx));

    if numel(evIdx)<1
        continue;
    end
    
    evIdx = interp1(HPC(i).ts, 1:numel(HPC(i).ts), evTs, 'nearest');

    eegSamps{i} = HPC(i).lfp( bsxfun(@plus, evIdx', eegWin) );
    
    evIdx = interp1(MU(i).ts, 1:numel(MU(i).ts), evTs, 'nearest');
     
    hpcSamps{i} = MU(i).hpc( bsxfun(@plus, evIdx', muWin) );
    ctxSamps{i} = MU(i).ctx( bsxfun(@plus, evIdx', muWin) );

    st = MU(i).st_RSC;
    st = st(~cellfun(@isempty, st));
    CST{i} = {};
    for iEv = 1:numel(evTs)
       CST{i}{iEv} = {};
       for iTT = 1 : numel(st)
           idx = st{iTT} > evTs(iEv)+win(1) & st{iTT} < evTs(iEv)+win(2);
           CST{i}{iEv}{iTT} = st{iTT}(idx);
       end
    end
    
    st = MU(i).st_rCA1;
    st = st(~cellfun(@isempty, st));
    HST{i} = {};
    for iEv = 1:numel(evTs)
       HST{i}{iEv} = {};
       for iTT = 1 : numel(st)
           idx = st{iTT} > evTs(iEv)+win(1) & st{iTT} < evTs(iEv)+win(2);
           HST{i}{iEv}{iTT} = st{iTT}(idx);
       end
    end
    
    eventTS{i} = evTs;
%         if isempty(st{j})
%             continue;
%         end
%         for k = 1:numel(evTs)
%             idx = st{j} >= evTs(k)+win(1) & st{j} < evTs(k) + win(2);
%             ST{i,k,j} =  st{j}(idx);
%         end
%     end
   
end

end