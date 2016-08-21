function copy_remote_clusters_pca(host, user)
%%

if nargin < 2
    user = 'slayton';
end

if nargin <1
    host = '10.121.43.56';
end

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

nExp = numel(edir);
for iExp = 1:nExp
   
    kDir = fullfile(edir{iExp}, 'kKlustPCA');
    
    if ~exist(kDir,'dir')
        cmd = sprintf('mkdir -p %s', kDir);
        fprintf('Creating directory: %s\n', kDir);
        system( cmd );
    end
    
    cmd = sprintf('scp %s@%s:%s/* %s', user, host, kDir, kDir);
    fprintf('Executing cmd:%s\n', cmd);
    [s, w] = unix(cmd);
end



end