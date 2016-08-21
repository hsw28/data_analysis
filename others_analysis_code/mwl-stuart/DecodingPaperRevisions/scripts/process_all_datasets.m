function process_all_datasets

edir{1} = '/data/spl11/day13';
edir{2} = '/data/spl11/day14';
edir{3} = '/data/spl11/day15';
edir{4} = '/data/spl11/day16';
edir{5} = '/data/jun/rat1/day01';
edir{6} = '/data/jun/rat1/day02';
edir{7} = '/data/jun/rat2/day01';
edir{8} = '/data/jun/rat2/day02';
edir{9} = '/data/greg/esm/day01';
edir{10}= '/data/greg/esm/day02';
edir{11}= '/data/greg/saturn/day02';
edir{12}= '/data/fabian/fk11/day08';

MIN_VEL = .15;
MIN_AMP = 100;
MIN_WIDTH = 12;

% Load the raw data from the .tt files and create dataset files
for i = 1:numel(edir)
    baseDir = edir{i}; 
    fprintf('\n---------------------- %s ----------------------\n', baseDir);
    process_dataset(edir{i}, MIN_VEL, MIN_AMP, MIN_WIDTH);
end

save_all_feature_files;
%Cluster the feature files
cluster_all_datasets;

end