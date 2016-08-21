function [recon] =  dset_save_all_replay_recon()

    epochList = {'run', 'sleep'};
    
    filenameTemplate = '/data/franklab/bilateral/recon/replay_recon_%s_%s_%d_%d.mat';
    for iEpoch = 1:2

        epoch = epochList{iEpoch};
        eList = dset_list_epochs(epoch);
        
        for idxEpoch = 1:size(eList,1);
            clear recon;
            [anim, dayN, epochN] = deal(eList{idxEpoch,:});
            
            d = dset_load_all(anim, dayN, epochN);

            [recon.stats, recon.replay, recon.labels] = ...
                dset_calc_replay_with_stats(d);

            recon.description = dset_get_description_string(d);
            
            filename = sprintf( filenameTemplate, epoch, anim, dayN, epochN );
            save(filename, 'recon');
            fprintf('%s saved!\n', filename);
        end

    end
end

