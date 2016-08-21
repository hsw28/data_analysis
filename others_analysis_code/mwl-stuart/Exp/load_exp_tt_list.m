function tetrodes = load_exp_tt_list(edir)

files= dir(fullfile(edir, 't*'));

files = files(cell2mat({files.isdir}));

tetrodes = {};
for i=1:numel(files);
    if exist(fullfile(edir,files(i).name, [files(i).name,'.tt']));
        tetrodes{i} = files(i).name;
    end
end
tetrodes = tetrodes';