function cluster_feature_files(baseDir, prefix, nChan)
if ~ischar(baseDir) || ~exist(baseDir, 'dir')
    error('baseDir must be a string and valid directory');
end

if ~ischar(prefix) || ~any( strcmp( prefix, {'amp', 'pca'} ) )
    error('Prefix must be string containing either: amp or pca');
end

if ~isnumeric(nChan) || ~isscalar(nChan) || ~ismember(nChan, [1 4]);
    error('nChan must be a numeric scalar equal to 1 or 4');
end

KLUSTA_KWIK_BIN = '~/src/clustering/kk2.0/KlustaKwik';

klustDir = fullfile(baseDir, 'kKlust');
if ~exist(klustDir, 'dir');
    write_feature_files(baseDir);
end

curDir = pwd;
cd(klustDir);

in = load( sprintf('%s/dataset_%dch.mat', klustDir, nChan), 'ttList');
ttList = in.ttList;

nTT = numel(ttList);

fprintf('Clustering...\n');

for iTetrode = 1:nTT
 
    featFile = sprintf('%s/%s.%dch.fet.%d', klustDir, prefix, nChan, iTetrode);
    
    if ~exist( featFile, 'file');
        fprintf('%s does not exist, skipping it\n', featFile);
        continue;
    end
    
    fprintf('\t%s ', featFile);
    
    cmd = sprintf('%s %s.%dch %d -Screen 0 -Log 0',KLUSTA_KWIK_BIN, prefix, nChan, iTetrode );
    [s, w] =  unix(cmd);
    
    fprintf('\n');
    
    clFile = sprintf('%s/%s.%dch.clu.%d', klustDir, prefix, nChan, iTetrode);
    
    % if the file doesn't exist for clustering, create empty place holder file
    if ~exist(clFile, 'file');
         [s, w] = unix( sprintf( 'touch %s', clFile) );
    end
    
end  

cd(curDir)

fprintf('Done!\n');
