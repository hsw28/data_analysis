%%
clear;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           LOAD THE DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runEpochs = dset_list_epochs('run');

i = 1;
% for i = 1:numel(runReconFiles)

dset = dset_load_all(runEpochs{i,1}, runEpochs{i,2}, runEpochs{i,3});    
[~, recon] = dset_calc_replay_stats(dset, [],[], [],1,'simple');

ts = dset.epochTime(1):.0025:dset.epochTime(2);

nTs = numel(ts);

lIdx = find( strcmp({dset.clusters.hemisphere}, 'left'));
rIdx = find( strcmp({dset.clusters.hemisphere}, 'right'));

nLeft = numel(lIdx);
nRight = numel(rIdx);

lRate = nan(nLeft, nTs);
rRate = nan(nRight, nTs);
%%
for i = 1:nLeft
    lRate(i,:) = hist(dset.clusters(lIdx(i)).st, ts);
end
for i = 1:nRight
    rRate(i,:) = hist(dset.clusters(rIdx(i)).st, ts);
end
%%
lRate(:, ~recon.replayIdx) = 0;
rRate(:, ~recon.replayIdx) = 0;

%%
count = 0;
xcSpikeTimeLL = nan(nLeft, nLeft);
xcSpikeTimeLR = nan(nLeft, nRight);
xcSpikeTimeRR = nan(nRight, nRight);
for i = 1:nLeft
    for j = (i+1):nLeft
        xcSpikeTimeLL(i,j) = lRate(i,:) * lRate(j,:)';
    end
    for j = 1:nRight
        xcSpikeTimeLR(i,j) = lRate(i,:) * rRate(j,:)';
    end
end

for i = 1:nRight
    for j = (i+1):nRight
        xcSpikeTimeRR(i,j) = rRate(i,:) * rRate(j,:)';
    end
end

%%
pfCorrLL = nan(nLeft, nLeft);
pfCorrLR = nan(nLeft, nRight);
pfCorrRR = nan(nRight, nRight);

for i = 1:nLeft
    for j = (i+1):nLeft
        pfCorrLL(i,j) = corr(dset.clusters(lIdx(i)).pf, dset.clusters(lIdx(j)).pf);
    end
    for j = 1:nRight
        pfCorrLR(i,j) = corr(dset.clusters(lIdx(i)).pf, dset.clusters(rIdx(j)).pf);
    end
end

for i = 1:nRight
    for j = (i+1):nRight
        pfCorrRR(i,j) = corr(dset.clusters(rIdx(i)).pf, dset.clusters(rIdx(j)).pf);
    end
end
