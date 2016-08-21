function d = dset_get_base_dir(animal)

d = '/data/franklab/FrankLabData';

animal = lower(animal);
animal(1) = upper(animal(1));

d = fullfile(d, animal);

if ~exist(d, 'dir')
    warning(strcat('Requested dir does not exist', d));
end
    

end