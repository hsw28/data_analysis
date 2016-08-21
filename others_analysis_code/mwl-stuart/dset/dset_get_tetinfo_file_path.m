function filepath = dset_get_tetinfo_file_path(animal)

filename = strcat(animal, 'tetinfo.mat');

filepath = fullfile(dset_get_base_dir(animal), filename);

if ~exist(filepath, 'file')
    filepath = fullfile(dset_get_base_dir(animal), lower(filename));
    if ~exist(filepath, 'file')
        warning(strcat('Requested file does not exist:', filepath));
    end
end