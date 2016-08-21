epochList = {'run', 'sleep'};

filenameTemplate = '/data/franklab/bilateral/recon/replay_recon_%s_%s_%d_%d.mat\n';
for iEpoch = 1:2
    epoch = epochList{iEpoch};
    eList = dset_list_epochs(epoch);

    for idxEpoch = 1:size(eList,1);
        [anim, dayN, epochN] = deal(eList{idxEpoch,:});
        fprintf(filenameTemplate, epoch, anim, dayN, epochN);
    end
end
