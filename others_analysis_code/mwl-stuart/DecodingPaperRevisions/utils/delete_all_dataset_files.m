function delete_all_dataset_files()
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

go = input('Delete ALL dataset files? [y/N]', 's');


if ~strcmp(go,'y');
    fprintf('Aborting!\n');
    return;
end


nExp = numel(edir);
for iExp = 1:nExp
   
    kDir = fullfile(edir{iExp}, 'kKlust');
    
    cmd = sprintf('rm -rf %s/*', kDir);
    unix(cmd);
    
end



end