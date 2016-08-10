function [epochNames, epochTimes]=jp_load_epoch(edir, epoch, varargin)


epochFile = fullfile(edir, 'epoch.epoch');

%% Load the epoch file from text and parse it
fid = fopen( epochFile );   
txt = textscan(fid, '%[^\n]');
txt = txt{1};

lineCount = 1;
line = txt{lineCount};
while line(1)=='%'
    lineCount = lineCount+1;
    line = txt{lineCount};
end

epochNames = {};
epochTimes = [];

while true
    res = textscan(line, '%s%f%f');
    epochNames{end+1} = res{1}{1};
    epochTimes(end+1,:) = [res{2}, res{3}];
    
    lineCount = lineCount+1;
    if lineCount > numel(txt)
        break;
    end
    line = txt{lineCount};
end

epochNames = epochNames';

%% check if epoch was specified
if nargin>1 && ischar(epoch)
    epochIdx = strcmp(epochNames, epoch);
    epochNames = epochTimes(epochIdx,:);
end
