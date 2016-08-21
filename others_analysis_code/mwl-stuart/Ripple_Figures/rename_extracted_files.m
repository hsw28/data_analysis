function rename_extracted_files(day)

if nargin==1
    day = sprintf('%02d', day);
elseif nargin==32673
    day = '21';
end

baseDir = ['/data/gh-rsc1/day', day];


D = dir(fullfile(baseDir, ['*',day]));

extList = {'.tt', '.pxyabw'};

cmd = 'mv %s %s';

for i = 1:numel(D)
    d = D(i);
    
    if d.name(1) == 't'
        continue;
    end
    
   
    tt = d.name(1:2);
    
    
    for e = 1:numel(extList)
        ext = extList{e};
        
        oldFile = fullfile( baseDir, d.name, [tt, day, ext]);
        newFile = fullfile( baseDir, d.name, ['t', tt, ext]);

        fprintf('Renaming: %s -> %s\n', oldFile, newFile);
        system( sprintf( cmd, oldFile, newFile));
    end
    
    oldDir = fullfile( baseDir, d.name);
    newDir = fullfile( baseDir, ['t', tt]);
    
    fprintf('Renaming: %s -> %s\n', oldDir, newDir);
    system( sprintf( cmd, oldDir, newDir));
 
end


oldFile = fullfile( baseDir, 'epoch.init');
newFile = fullfile( baseDir, 'epochs.def');


if ~exist(newFile,'file') && exist(oldFile, 'file')
    epochs = convert_epoch_file(oldFile);
    save_epochs(baseDir, {'sleep1', 'run', 'sleep2'}, epochs);
else
    warning('Epoch file not saved');
end
