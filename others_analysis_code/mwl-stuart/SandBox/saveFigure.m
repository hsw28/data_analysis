function saveFigure(figHandle, path, name, varargin)

types = {'fig', 'eps', 'png', 'pdf', 'svg'};

% check the validity of the inputs
if ~isscalar(figHandle)
    error('Invalid Figure Handle specified');
end

if isempty(figHandle) || ~ishandle(figHandle) || ~ isa(handle(figHandle), 'figure');
    error('Invalid argument, must provide a valid figure handle');

elseif ~exist(path, 'dir')
    error('Invalid argument, must provide a valid directory');

elseif nargin < 3
    error('Invalid number of arguments! A figure , path, and basename are required!');

% if no formats are specified
elseif nargin == 3
    typesIdx = true(size(types));

% if formats are specified then loop through them and make sure they are
% valid formats
else
    typesIdx = false(size(types));
    
    if numel(varargin)==1 && iscell(varargin{1})
        varargin = varargin{1};
    end
    
    for i = 1:numel(varargin)  
        format = varargin{i};
        
        % if the user has provided leading .s remove them
        if format(1) == '.'
            format = format(2:end);
        end
        
        idx = strcmp(types, format);

        if ~any(idx)
            warning('Unknown format specified:%s it will be skipped',  format);
        end
        
        typesIdx = typesIdx | idx; 
    end
end

% remove the formats that weren't specified via the inputs
types = types(typesIdx);

% some matlab-fu to ensure the figure saves nicely, we need to change some
% default plotting values - they get reset later
set(figHandle, 'PaperPositionMode', 'auto');
shohid = get(0,'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'on');

for i = 1:numel(types)
    
    filename = fullfile(path, [name, '.', types{i}]);
    fprintf('Saving figure to file:%s\n', filename);
    
    if strcmp( types{i}, 'svg')
        plot2svg(filename, figHandle, 'png');
    else
        saveas(figHandle, filename);
    end
end;

% reset ShowHiddenHandles to what is was before
set(0, 'ShowHiddenHandles', shohid);



