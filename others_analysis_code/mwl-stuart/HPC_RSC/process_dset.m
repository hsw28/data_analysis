function process_dset(animal, day, ep)

if nargin>32000
    animal = 'gh-rsc1'; 
    day = 22;
end

baseDir = sprintf('/data/%s/day%02d', animal, day);

if ~exist(baseDir, 'dir')
    fprintf('Directory %s does not exist\n', baseDir');
    return;
end

% [epList, epTime] = load_epochs(baseDir);

% for i = 1:numel(epList)
    
%     ep = epList{i};
    fName = fullfile(baseDir, sprintf('MU_HPC_RSC_%s.mat', upper(ep)));
    
    if exist(fName, 'file')
        fprintf('%s already exists, skipping it!\n', fName);
       
    else
        mu = dset_exp_load_mu_all(baseDir, ep);
    
        save( fName, 'mu');
        fprintf('%s SAVED!\n', fName);      
    end
    
% end

return;
%%

% debuf_eeg( animal, day)
% gh-rsc1
dayList =[18 22 23 24 28];
eegList = 'kkkkk';
chList = [7  7  7  7  7];

if ~any(day == dayList)
    error('Invalid day specified');
end

if numel(dayList) ~= numel(eegList) || numel(dayList) ~= numel(chList)
    error('Invalid day,eeg,ch specified');
end

% gh-rsc2
% dayList =[22 24 25 26];
% chList = [6  1  1  1];
ch = chList( dayList == day);
eegF = eegList( dayList == day);

data = [];
oldFile = fullfile( baseDir, sprintf('%s%d.eeg.debuf', eegF, day));


for i = 1:numel(epList)
    ep = epList{i};
    newFile = fullfile( baseDir, sprintf('EEG_HPC_1500_%s.mat', ep));
    
    if exist(newFile, 'file')
        fprintf('%s already exists, skipping it!\n', newFile);
        continue;
    end
    if isempty(data)
        fprintf('Loading eeg file: %s\n', oldFile);
        try
            data = load( mwlopen(oldFile) );
        catch
            fprintf('EEG files not found!\n');
            break;
        end
        
        epTime(epTime<min(data.timestamp)) = min(data.timestamp);
        epTime(epTime>max(data.timestamp)) = max(data.timestamp);
        
    end

    idx = [nan nan];
    
    idx = interp1(data.timestamp, 1:numel(data.timestamp), epTime(i,:), 'nearest');
    idx = idx(1):idx(2);
    
    hpc.ts = data.timestamp(idx);
    hpc.data = double( data.(sprintf('channel%d', ch))(idx) );
    
    fprintf('Saving %s -> %s\n', oldFile, newFile);
    save(newFile, 'hpc');
        
end
    

