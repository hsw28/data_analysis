function [tc] = dset_load_tuningcurves(animal, day, epoch)
% DSET_LOAD_TUNINGCURVES - loads tuning curves from disk, if they don't exist then they are calculated

filepath = dset_get_tc_filepath(animal, day, epoch);
    
    if ~exist(filepath,'file')
        calc_and_save_tc(animal, day, epoch);
    end
    
    tc = load(filepath);

end

function calc_and_save_tc(animal, day, epoch)

    clusters = dset_load_clusters(animal, day, epoch);
    position = dset_load_position(animal, day, epoch);
    
    disp('loaded')

end