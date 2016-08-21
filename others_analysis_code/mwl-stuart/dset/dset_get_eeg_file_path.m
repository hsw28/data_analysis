function filepath = dset_get_eeg_file_path(animal, day, epoch, electrode)
filepath = {};
for i = 1:numel(electrode)

    eegdir = fullfile(dset_get_base_dir(animal), 'EEG');

    if(day<10)
        daystr = strcat('0', num2str(day));
    else
        daystr = num2str(day);
    end

    if (electrode(i)<10)
        electrodestr = strcat('0', num2str(electrode(i)));
    else
        electrodestr = num2str(electrode(i));
    end

    filename = strcat(animal, 'eeg', daystr, '-', num2str(epoch), '-', electrodestr, '.mat');

    filepath{i} = fullfile(eegdir, filename);

    % if file doesn't exist try lowercase
    if ~exist(filepath{i}, 'file')
        filepath{i} = fullfile(eegdir, lower(filename));
        if ~exist(filepath{i}, 'file')

            warning(strcat('Requested file does not exist:', filepath{i}));
            
        end


    end
end



end