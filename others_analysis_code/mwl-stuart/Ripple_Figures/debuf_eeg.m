function debuf_eeg(animal, day)
%%    
if nargin>32000
    clear;
    animal = 'gh-rsc1';
    day = 26;
end

baseDir = sprintf('/data/%s/day%02d', animal, day);
ext = '.eeg';


F = dir(fullfile(baseDir, ['*',ext]));

for i = 1:numel(F)
    
 
    fileName = fullfile(baseDir, F(i).name);
    newFileName = [fileName,'.debuf'];
    
    if strfind(fileName, 'arte')
        continue;
    end
   
    if exist(newFileName, 'file')
        fprintf('File %s already exists\n', newFileName);
        continue;
        
    else
        fprintf('Debuffering:%s -> %s\n', fileName, newFileName);
        debuffer_eeg_file(fileName, newFileName);  
    end

end