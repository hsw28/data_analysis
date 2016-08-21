

edir = {};
edir{end+1} = 'spl11/day13';
edir{end+1} = 'spl11/day14';
edir{end+1} = 'spl11/day15';
edir{end+1} = 'spl11/day16';
edir{end+1} = 'jun/rat1/day01';
edir{end+1} = 'jun/rat1/day02';
edir{end+1} = 'jun/rat2/day01';
edir{end+1} = 'jun/rat2/day02';
edir{end+1} = 'greg/esm/day01';
edir{end+1} = 'greg/esm/day02';
edir{end+1} = 'greg/saturn/day02';
edir{end+1} = 'fabian/fk11/day08';


cmd = 'tar cvzf featureDecodingAllDataSets.tar.gz ';

for i = 1 : numel(edir)
   cmd = sprintf('%s %s/kKlust/*.mat', cmd, edir{i}); 
   cmd = sprintf('%s %s/epochs.def', cmd, edir{i});
   cmd = sprintf('%s %s/amprun.lin_pos.p', cmd, edir{i});
end

curDir = pwd;
cd /data
unix(cmd);
cd(curDir);
