function p = dset_get_linpos_file_path(animal, day, epoch)


dayStr = sprintf('linpos%02d.mat', day);
filename = [animal, dayStr];
% if (day<10)
%     filename = [animal, 'linpos', '0', num2str(day), '-', num2str(epoch),  '.mat'];
% else
%     filename = [animal, 'linpos', num2str(day), '-', num2str(epoch), '.mat'];
% end

p = fullfile(dset_get_base_dir(animal), filename);

% if the file doesn't exist try using lower case
if ~exist(p, 'file')

    p = fullfile(dset_get_base_dir(animal), lower(filename));
    
    if ~exist(p, 'file')
        %warning(['File does not exist:', p]);
    end

end