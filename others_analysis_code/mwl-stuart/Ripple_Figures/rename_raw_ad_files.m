
baseDir = '/data/gh-rsc2/day30';

oldExt = 'sgh';
newExt = 'stu';

files = dir( fullfile(baseDir, ['*.', oldExt]));

for i = 1:numel(files)
    oldFn = files(i).name;
    day = oldFn(3:4);

    newFn = ['t', oldFn(1:2), 't', oldFn(5:6), day, '.', newExt];
    
    fprintf('Renaming: %s -> %s\n', oldFn, newFn);
    
    cmd = ['mv ', fullfile(baseDir, oldFn), ' ', fullfile(baseDir, newFn)];
    system(cmd);
end

oldExt = 'pgh';
files = dir( fullfile(baseDir, ['*.', oldExt]));
for i = 1:numel(files)
    
    oldFn = files(i).name;
    day = oldFn(2:3);

    newFn = ['master', day, '.stu'];
    fprintf('Renaming: %s -> %s\n', oldFn, newFn);
    
    cmd = ['mv ', fullfile(baseDir, oldFn),' ', fullfile(baseDir, newFn)];
    system(cmd);
end

oldExt = 'egh';
files = dir( fullfile(baseDir, ['*.', oldExt]));
for i = 1:numel(files)
    
    oldFn = files(i).name;
    day = oldFn(2:3);

    newFn = ['eeg', num2str(i), '.stu'];
    fprintf('Renaming: %s -> %s\n', oldFn, newFn);
    
    cmd = ['mv ', fullfile(baseDir, oldFn),' ', fullfile(baseDir, newFn)];
    system(cmd);
end


