function f=define_epochs(rootdir, varargin)
    % A simple GUI used to create an epoch.def file
    % written by Stuart Layton 2009. Requires MWLIO
    
    args.epoch_file = 'none';
    args = parseArgs(varargin, args);
        
    if strcmp(args.epoch_file, 'none')
        args.epoch_file = fullfile(rootdir,'epochs.def');
    end
    
    tstart = 0;
    tend = 0;
    
    if exist(fullfile(rootdir, 'epochs.def'),'file') || exist(args.epoch_file, 'file')
        what_to_do = questdlg('Epoch File exists! Create a new one?', 'HUH?');
        if ~strcmp(what_to_do, 'Yes')
            disp('Epoch file not saved!');
            f = [];
            return;
        end
        cmd = ['mv ' fullfile(rootdir, 'epochs', 'epochs.def'),' ', fullfile(rootdir, 'epochs', 'epochs.def.old')];
        system(cmd);      
    end
    
    n_epochs = cell2mat(inputdlg('How many epochs to define?', 'Define Epochs', 1, {'0'}));
   
    n_epochs = str2double(n_epochs(1));
    
    epoch_data = {'Name', tstart, tend};
    class(n_epochs)
    epoch_data = repmat(epoch_data, n_epochs, 1);

    f = figure('Position', [300 300 380 325], 'Name', 'Define Epochs', 'NumberTitle', 'off', 'MenuBar', 'none');
    t1 = uitable(f, 'Position', [25, 50, 333, 250]);
    set(t1, 'Data', epoch_data);

    set(t1, 'ColumnEditable', logical([1 1 1]));
    set(t1, 'ColumnWidth', {100 100 100});

    c_names = {'Name', 'Start', 'End'};
    set(t1, 'ColumnName', c_names);
    
    
    uicontrol(f, 'Style', 'PushButton', 'String', 'Save','Position', ...
                [10 20 60 20], 'CallBack', {@save_epoch, handle(t1), rootdir});
    uicontrol(f, 'Style', 'PushButton', 'String', 'Load','Position', ...
                [80 20 60 20], 'CallBack', {@load_epoch, handle(t1), rootdir});
    uicontrol(f, 'Style', 'PushButton', 'String', '+Epoch','Position',...
                [230 20 60 20], 'CallBack', {@add_epoch, handle(t1), tstart, tend});
    uicontrol(f, 'Style', 'PushButton', 'String', '-Epoch','Position',...
                [300 20 60 20],'CallBack', {@del_epoch, handle(t1)});
    
    
    
    function save_epoch(varargin)
        disp('Saving Epochs');
        t1 = varargin{3};
        data = get(t1,'Data');
        names = data(:,1);
        times = cell2mat(data(:,[2 3]));
        rootdir = varargin{4};
       
        save_epochs(rootdir, names, times, 'epoch_file', args.epoch_file);
        
        %disp([args.epoch_file,  ' saved!']);
    end
    function add_epoch(varargin)
     %  disp('Adding an epoch');
        t1 = varargin{3};
        data = get(t1, 'Data');
        tstart = varargin{4};
        tend = varargin{5};
        d = {'Name', tstart, tend};
        data = [data;d];
        set(t1,'Data',  data);        

    end
    function del_epoch(varargin)
      % disp('Deleting epoch');
        t1 = varargin{3};
        data = get(t1, 'Data');
        data = data(1:end-1, :);
        set(t1,'Data', data);
    end
    function load_epoch(varargin)
        [f p] = uigetfile('*.def', 'Select an epoch file', fullfile(rootdir, 'epochs.def'));
 
        [a b ] = load_epochs('', 'epoch_file', fullfile(p,f));
        
        data = [a' mat2cell(b,repmat(1,size(b,1),1), repmat(1,size(b,2),1))];
        set(t1,'Data', data);
    end
 end