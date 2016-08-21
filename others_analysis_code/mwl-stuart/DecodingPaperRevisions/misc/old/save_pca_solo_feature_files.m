function save_pca_solo_feature_files(baseDir)

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end

spikesFile = fullfile(klustDir, 'spike_params_pca_solo.mat');
if ~exist(spikesFile)
    fprintf('Spikes file does not exist, creating it\n');
    convert_tt_files(baseDir);
end

in = load(spikesFile)
pc = in.pcSolo;

ttListFile = fullfile(klustDir, 'dataset_ttList.mat');
in = load(ttListFile);
ttList = in.ttList;

%% Save a complete file

% ttList = in.amp_names;

nFeature = 4;
formatString = repmat( '%3.4f\t', 1, nFeature);
formatString(end) = 'n';

fprintf('Saving feature files:\n');
for iTetrode = 1:numel(pc)
       
    featFile = fullfile( klustDir, sprintf('pca.solo.fet.%d', iTetrode) );
    fprintf('\t%s\n', featFile);

    d = pc{iTetrode};
    
    if isempty(d) || numel(d) == 0
        
        [s,w] = unix( sprintf('touch %s', featFile) );
        continue;
    
    else
        
        d = d(:,1:nFeature)';
        % Open the file
        fid = fopen(featFile, 'w+');    
        % Write the number of features
        fprintf(fid, '%d\n', nFeature); 
        % Write the feature matrix
        fprintf(fid, formatString, d);
        fclose(fid);
        
    end
    
end
fprintf('\n');


