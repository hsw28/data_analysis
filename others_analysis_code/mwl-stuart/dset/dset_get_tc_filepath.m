function filepath = dset_get_tc_filepath(animal, day, epoch)

if (day<10)
    filepath = [animal, '_tc_d', '0', num2str(day),'_e', num2str(epoch), '_SL.mat'];
else
    filepath = [animal, '_tc_d', num2str(day), '_e', num2str(epoch), '_SL.mat'];
end

p = fullfile(dset_get_base_dir(animal), filepath);

% if the file doesn't exist try using lower case
if ~exist(p, 'file')

    p = fullfile(dset_get_base_dir(animal), lower(filepath));
    
    if ~exist(p, 'file')
        warning(['File does not exist:', p]);
    end

end