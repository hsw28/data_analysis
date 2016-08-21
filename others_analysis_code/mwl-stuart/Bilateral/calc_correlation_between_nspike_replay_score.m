function [results all animal] = calc_correlation_between_nspike_replay_score(epoch)


if ~any( strcmp({'run', 'sleep'}, epoch) )
    error('invalid epoch');
end


reconFileList = dset_get_recon_file_list(epoch);
dsetFileList = dset_get_dset_file_list(epoch);

nFile = numel(dsetFileList);
[all.nSpike, all.perSpike, all.score] = deal( {[],[]} );

fprintf('Of %d: Loading: ', nFile);
for iFile = 1:nFile
    fprintf(' %d', iFile);
    dataIn1 = load(dsetFileList{iFile});
    dataIn2 = load(reconFileList{iFile});
    d = dataIn1.d;
    recon = dataIn2.recon;
    clear dataIn1 dataIn2;
    
    [lIdx, rIdx, ~] = dset_calc_cl_idx(d);
    
    nCellLeft = sum(lIdx);
    nCellRight = sum(rIdx);
    
    [maxL, mIdxL] = max(recon.stats{1}.score2, [], 2);
    [maxR, mIdxR] = max(recon.stats{2}.score2, [], 2);

    idx = mIdxL;
    idx(maxR > maxL) = mIdxR(maxR > maxL);
    
    nBurst = size(d.mu.bursts,1);
    
    [nSpkL, nSpkR, perCellL, perCellR, scrL, scrR] = deal( zeros(nBurst,1) );
       
    for iBurst = 1:nBurst
        
        timeIdx = recon.replay{1}.tbins >= d.mu.bursts(iBurst,1) & recon.replay{1}.tbins <= d.mu.bursts(iBurst,2);

        leftSpikes = sum( recon.replay{1}.spike_counts(:, timeIdx), 2 );
        rightSpikes = sum( recon.replay{2}.spike_counts(:, timeIdx), 2 );
        
       
        nSpkL(iBurst) = sum( leftSpikes );
        nSpkR(iBurst) = sum( rightSpikes );
     
        perCellL(iBurst) = sum( leftSpikes > 0) / nCellLeft;
        perCellR(iBurst) = sum( rightSpikes > 0) / nCellRight;
        
        scrL(iBurst) = recon.stats{1}.score2(iBurst, idx(iBurst));
        scrR(iBurst) = recon.stats{2}.score2(iBurst, idx(iBurst));
        
%        
       
       
        
    end
    
    chk = @(x) (x==0);
    badIdx = chk(nSpkL) | chk(nSpkR) | chk(perCellL) | chk(perCellR) | chk(scrL) | chk(scrR);
 
    nSpkL(badIdx) = nan;
    nSpkR(badIdx) = nan;
    perCellL(badIdx) = nan;
    perCellR(badIdx) = nan;
    scrL(badIdx) = nan;
    scrR(badIdx) = nan;
    
    all.nSpike{1} = [all.nSpike{1}; nSpkL];
    all.nSpike{2} = [all.nSpike{2}; nSpkR];

    all.perSpike{1} = [all.perSpike{1}; perCellL];
    all.perSpike{2} = [all.perSpike{2}; perCellR];

    all.score{1} = [all.score{1}; scrL];
    all.score{2} = [all.score{2}; scrR];
    
    animal(iFile).perSpkL = perCellL;
    animal(iFile).perSpkR = perCellR;
    animal(iFile).scoresL = scrL;
    animal(iFile).scoresR = scrR;
    
end
fprintf('\n');

%res = structfun(@(x) (x{1}==0 | x{2}==0) , all, 'UniformOutput', 0);
%validIdx = find( ~( res.nSpike | res.perSpike | res.score ) );

results = [];

%% Complete this SHUFFLE!  

validIdx = ~isnan(all.score{1}) & ~isnan(all.score{2}) & ~isnan(all.perSpike{1}) & ~isnan(all.perSpike{2});

results.scoreCorr = corr2( all.score{1}(validIdx), all.score{2}(validIdx) );
results.perCorr = corr2( all.perSpike{1}(validIdx), all.perSpike{2}(validIdx) );

nShuffle = 500;
for iShuf = 1:nShuffle
    
    scoreShuff = [];
    perShuff = [];
    for iAnimal = 1:numel(animal)
        idx = find( ~isnan( animal(iAnimal).perSpkL ) );
        idx = randsample(idx,numel(idx),1);
 
        scoreShuff = [scoreShuff; animal(iAnimal).scoresR(idx)];
        perShuff = [perShuff; animal(iAnimal).perSpkR(idx)];
        
    end
    
    results.scoreCorrShuf(iShuf) = corr2( all.score{1}( (validIdx) ), scoreShuff);
    results.perCorrShuf(iShuf) = corr2( all.perSpike{1}( (validIdx) ), perShuff);    
    
end
 

%% 
    
    
    
    
    
end