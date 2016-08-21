function [pc] = load_dataset_pca_features(baseDir)

if nargin==1
    plot = 0;
end
klustDir = fullfile(baseDir, 'kKlust');

if ~exist(klustDir, 'dir')
    error('%s does not exist', klustDir);
end

in = load( fullfile(klustDir, 'ttMap.mat') );
nTT = numel(in.ttList);

in = load (fullfile(klustDir, 'spikes.mat') );
spikes = in.data;


pc = repmat({}, nTT, 1);
for i = 1:nTT

    fFile = sprintf('%s/pca.fet.%d', klustDir, i);
    feat = load_pca_feature_file(fFile);
    
    if numel(feat)==1 || size(feat,1) < 5
        pc{i} = [];
        continue;
    end

    pc{i} = [feat, spikes{i}(:, 5:8)];
    
end

end