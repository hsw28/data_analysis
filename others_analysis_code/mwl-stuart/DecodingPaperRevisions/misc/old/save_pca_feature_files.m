function save_pca_feature_files(baseDir, nChan)

if ~exist(baseDir, 'dir')
    error('Dir %s does not exist', baseDir)
end

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir')
    mkdir(klustDir);
end

if nargin==1
    nChan = 4;
end

dsetFile = sprintf('%s/dataset_%dch.mat', klustDir, nChan);
in = load(dsetFile, 'amp');

pComp = in.( sprintf('pc%d', nChan) );

nFeature = 3 * nChan;
sprintf('pComp size[%d %d], nFeat %d\n', size( pComp{1},1), size( pComp{1},2), nFeature);

if size(pComp{1},1) ~= nFeature
    error('Invalid data matrix size:%d', size(pComp{1}, 1));
end

%% Save a complete file

% ttList = in.amp_names;

formatString = repmat( '%3.4f\t', 1, nFeature);
formatString(end) = 'n';

fprintf('Saving feature files:\n');
for iTetrode = 1:numel(pComp)
       
    featFile = sprintf('%s/pca.%dch.fet.%d',klustDir, nChan, iTetrode);
    fprintf('\t%s\n', featFile);

    d = pComp{iTetrode};
    
    if isempty(d) || numel(d) == 0
        
        [s,w] = unix( sprintf('touch %s', featFile) );
        continue;
    
    else
        
        d = d(:,1:nFeature)';
        
        fid = fopen(featFile, 'w+');    
        fprintf(fid, '%d\n', nFeature); 
        fprintf(fid, formatString, d);
        fclose(fid);
        
    end
    
end
fprintf('\n');


