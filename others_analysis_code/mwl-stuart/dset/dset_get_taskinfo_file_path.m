function filepath = dset_get_taskinfo_file_path(animal, day)

%animal = lower(animal);

if day < 10
    filename = [animal, 'task0', num2str(day), '.mat'];
else
    filename = [animal, 'task', num2str(day), '.mat'];
end

filepath = fullfile(dset_get_base_dir(animal), filename);


% if the file doesn't exist try lowercase
if ~exist(filepath, 'file')
   filepath = fullfile(dset_get_base_dir(animal), lower(filename));

   if ~exist(filepath, 'file')
       warning(strcat('Requested file does not exist:', filepath));
       filepath = [];
   end
end
