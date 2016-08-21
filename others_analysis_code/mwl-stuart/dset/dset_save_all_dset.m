function dset_save_all_dset()

epochList = {'run', 'sleep'};
    
    filenameTemplate = '/data/franklab/bilateral/dset/%s_%d_%d.mat';
    for iEpoch = 1:2

        epoch = epochList{iEpoch};
        eList = dset_list_epochs(epoch);
        
        for idxEpoch = 1:size(eList,1);
            [anim, dayN, epochN] = deal( eList{idxEpoch,:} );

            d = dset_load_all(anim, dayN, epochN);

            filename = sprintf( filenameTemplate, anim, dayN, epochN );

            save(filename, 'd');
            fprintf('%s saved!\n', filename);
        end

    end
end