function pos = dset_load_distance_matrix(animal, day, epoch, varargin)
% DSET_LOAD_POSITION - loads the positions records (raw and linaear) from disk, if a linear position record doesn't exist the user is prompted to create it
stdArgs = dset_get_standard_args;
args = stdArgs.position;

pos_filepath = dset_get_pos_file_path(animal, day);
distmat_filepath = dset_get_distance_matrix_file_path(animal, day, epoch);

if ~exist(distmat_filepath, 'file')
    calculate_distance_matrix(pos_filepath, distmat_filepath, day, epoch);   
end

pos = load(distmat_filepath);

end

function calculate_distance_matrix(pos_filepath, distmat_filepath, day, epoch)    
    
    %load the raw data
    pos = load(pos_filepath);
    pos = pos.pos{day}{epoch};
    ts = pos.data(:,1); 
    xpos = pos.data(:,2);
    ypos = pos.data(:,3);    
    
    %calcluate the position idx and distance matrix
    [positionIdx, distMat] = fit_behavior_to_w_maze(xpos, ypos);
    
    %convert distances to cm
    distMat = distMat * pos.cmperpixel;
    units = 'cm';
    
    save(distmat_filepath, 'ts', 'positionIdx', 'distMat', 'units');  

end
