function def_epochs(edir)
    % A simple GUI used to create an epoch.def file
    % written by Stuart Layton 2009. Requires MWLIO

    tstart = 0;
    tend = 0;
    create_new = 1;
    epoch_data = {};
    if exist(fullfile(edir,  'epochs.def'))
        create_new = 0;
        what_to_do = questdlg('epochs.def already exist what do you want to do?', 'HUH?', 'Create New', 'Modify Old', 'Cancel', 'Cancel');
        if strcmp(what_to_do, 'Cancel')
            disp('Epoch Definitions Aborted!');
            return;
        elseif strcmp('Modify Old', what_to_do);
      
        disp('Backingup old version');
            
        [e_names e_times] = load_epochs(edir);
        
        
        e_times = mat2cell(e_times, ones(size(e_times,1),1), ones(size(e_times,2),1) ) ;
       
        epoch_data = [e_names', e_times];
        else
            create_new = 1;
        end
        
    end
    
    if create_new ==1
        ans = inputdlg('How many epochs to define?', 'Define Epochs');
        if isempty(ans)
            disp('Canceling');
            return;
        end
        n_epochs = cell2mat(ans);
        n_epochs = str2double(n_epochs(1));
        epoch_data = {'Name', tstart, tend};
        class(n_epochs)
        epoch_data = repmat(epoch_data, n_epochs, 1);         
        
    end
    
    f = figure('Position', [300 300 380 325], 'Name', 'Define Epochs', 'NumberTitle', 'off', 'MenuBar', 'none');
    t1 = uitable(f, 'Position', [25, 50, 333, 250]);
    set(t1, 'Data', epoch_data);

    set(t1, 'ColumnEditable', logical([1 1 1]));
    set(t1, 'ColumnWidth', {100 100 100});

    c_names = {'Name', 'Start', 'End'};
    set(t1, 'ColumnName', c_names);
    
    
    uicontrol(f, 'Style', 'PushButton', 'String', 'Save','Position', ...
                [10 20 60 20], 'CallBack', {@save_epoch, handle(t1), edir});
    uicontrol(f, 'Style', 'PushButton', 'String', 'Create TT Dirs','Position', ...
                [80 20 100 20], 'CallBack', {@create_tt_dirs});
    uicontrol(f, 'Style', 'PushButton', 'String', '+Epoch','Position',...
                [230 20 60 20], 'CallBack', {@add_epoch, handle(t1), 0, 0});
    uicontrol(f, 'Style', 'PushButton', 'String', '-Epoch','Position',...
                [300 20 60 20],'CallBack', {@del_epoch, handle(t1)});
       
    function save_epoch(varargin)
        disp('Saving Epochs');
        t1 = varargin{3};
        data = get(t1,'Data');
        names = data(:,1);
        times = cell2mat(data(:,[2 3]));
        rootdir = varargin{4};
        save_epochs(edir, names, times);
        
        disp([fullfile(edir, 'epochs.def'), ' saved!']);
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
    function create_tt_dirs(varargin)
        disp('Creating tetrode epoch dirs');
        epoch_names = get(t1,'Data');

        dat = dir(fullfile(edir, 't*'));
        for i = 1:numel(dat)
            record = dat(i);
            if record.isdir
                for j = 1:size(epoch_names,1)
                    ep = epoch_names{j,1};
                    dir_n = fullfile(edir, record.name, ep);
                    if ~ exist(dir_n, 'dir')
                        mkdir(dir_n);
                    end
                end
               
            end
        end
        
    end
 end