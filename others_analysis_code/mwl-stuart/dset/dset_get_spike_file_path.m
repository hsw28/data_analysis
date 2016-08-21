function filepath = dset_get_spike_file_path(animal, day)

daystr = sprintf('%02d', day);

% if (day<10)
%     daystr = strcat('0', num2str(day));
% else
%     daystr = num2str(day);
% end

filename = strcat(animal, 'spikes', daystr, '.mat');

filepath = fullfile(dset_get_base_dir(animal), filename);

% if file doesn't exist try lower case
if ~exist(filepath, 'file')
    filepath = fullfile(dset_get_base_dir(animal), lower(filename));
    if ~exist(filepath, 'file')
        warning(['Requested file does not exist:', filepath]);
        filepath = [];
    end
end