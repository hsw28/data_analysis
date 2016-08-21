function filepath = dset_get_spike_param_file_path(animal, day, epoch, electrode)
filepath = [];

if numel(electrode)>1
    warning('Multiple electrodes specified, ignoring all but the first');
end

animalList = {'bon', 'dud', 'fra'};
dirList = {'bond', 'dudley', 'frank'};

animal = lower(animal);
idx = find( strcmp(animalList, animal) );
animal = dirList{idx};

baseDir = '/data/franklab/MattiasRawData/';

dayStr = sprintf('%02d', day);
electrodeStr = sprintf('%02d', electrode(1));


baseDir = [baseDir, dirList{idx},'/', animal, dayStr,'/'];

d = dir(baseDir);

for i = 1:numel(d)
    % if is file or is . or .. dir skip it
    if ~d(i).isdir || d(i).name(1) == '.'
        continue;
    end
    
    if strcmp(d(i).name(1:2), electrodeStr)
        baseDir = [baseDir, d(i).name];
        break;
    end
end

filepath = fullfile(baseDir, [animal, dayStr, '-', electrodeStr, '_params.mat']);
if ~exist(filepath, 'file')
    %disp(strcat('Requested file does not exist:', filepath));
end


