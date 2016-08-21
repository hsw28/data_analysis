function filepath = dset_get_cellinfo_file_path(animal)

%animal = lower(animal);

filename = strcat(animal, 'cellinfo.mat');

filepath = fullfile(dset_get_base_dir(animal), filename);


% if the file doesn't exist try lowercase
if ~exist(filepath, 'file')
   
    animal = lower(animal);
   filename = strcat(animal, 'cellinfo.mat');
   filepath = fullfile(dset_get_base_dir(animal), filename);

   if ~exist(filepath, 'file')
       %warning(strcat('Requested file does not exist:', filepath));
       filepath = [];
   end
end
