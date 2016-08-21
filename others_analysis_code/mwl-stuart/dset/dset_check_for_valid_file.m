function [valid data] = check_for_valid_file(filepath, generatingFile)
if ~isstr(filepath)
    error('Filepath must be a string');
end
if ~isstr(generatingFile)
    error('Generating File must be a string');
end

% if the data file doesn't exist, quit now
if ~exist(filepath)
    valid = false;
    data = [];
    return;
end

% get the date of the data file, to compare against the dependencies
fileInfo = dir(filepath);
fileDate = fileInfo.datenum;

funcDepends = depfun(generatingFile);

mr = matlabroot;

for iDep = 1 : numel(funcDepends)
    dep = funcDepends{iDep};
    if ~isempty( strfind( dep, mr) )
        continue
    end
    
    info = dir(dep);
    date = info.datenum;
    
    % if the source code file is newer than the generated data file
    % regerenate the data file
    if date > fileDate
        valid = false;
        data = [];
    end    
end

% if all the depen
