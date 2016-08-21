function [id] = load_dataset_clusters(baseDir, prefix, nChan)

if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must be a string and valid directory');
end

if ~ischar(prefix) || ~any( strcmp( prefix, {'amp', 'pca'} ) )
    error('Prefix must be string containing either: amp or pca');
end

if ~isnumeric(nChan) || ~isscalar(nChan) || ~inrange(nChan, [1 4]);
    error('nChan must be a numeric scalar between 1 and 4');
end

prefix = sprintf('%s.%dch', prefix, nChan);

klustDir = fullfile(baseDir, 'kKlust');


dsetFile = sprintf('%s/dataset_%dch.mat', klustDir, nChan);
if ~exist(dsetFile, 'file')
    error('dataset file does not exist, has create_dataset_file been called?');
end

in = load( dsetFile, 'ttList' );
nTT = numel(in.ttList);

id = cell(nTT, 1);
fprintf('Loading clusters: %s\n', klustDir);
for i = 1:nTT
    clFile = fullfile( klustDir, sprintf('%s.clu.%d', prefix, i ));
    clId = load_cluster_file(clFile);
    id{i} = clId;
end

if all( cellfun(@isempty, id) )
    warning('No clusters loaded');
end

end