function p = dset_get_linfields_file_path(animal)

filename = [animal, 'linfields', '.mat'];

p = fullfile(dset_get_base_dir(animal), filename);

% if the file doesn't exist try lower case
if ~exist(p, 'file')
    p = fullfile(dset_get_base_dir(animal), lower(filename));
    
    if ~exist(p, 'file')
        %warning(['File does not exist:', p]);
        p = [];
    end
end