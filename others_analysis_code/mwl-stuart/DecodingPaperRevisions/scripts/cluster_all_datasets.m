function cluster_all_datasets

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

%Cluster the feature files
parfor i = 1:numel(edir)
    baseDir = edir{i}; 
    
    cluster_feature_files(baseDir, 'pca', 4);
    cluster_feature_files(baseDir, 'pca', 1);
    % cluster_feature_files(baseDir, 'amp', 4); %<--- Can cluster on AMPlitude TOO!
end

end