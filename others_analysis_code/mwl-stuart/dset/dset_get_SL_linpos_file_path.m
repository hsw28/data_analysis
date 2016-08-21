function p = dset_get_SL_linpos_file_path(animal, day, epoch)


if (day<10)
    filename = [animal, 'linpos', '0', num2str(day), '-', num2str(epoch),  '_SL.mat'];
else
    filename = [animal, 'linpos', num2str(day), '-', num2str(epoch), '_SL.mat'];
end

p = fullfile(dset_get_base_dir(animal), filename);

% if the file doesn't exist try using lower case
if ~exist(p, 'file')

    p = fullfile(dset_get_base_dir(animal), lower(filename));
    
    if ~exist(p, 'file')
        warning(['File does not exist:', p]);
    end

end