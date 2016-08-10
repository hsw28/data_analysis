function f = jp_define_tt_anatomy(edir)

f = figure('Position', [800 480 200 500], 'Name', 'Define Tetrode Anatomy', 'NumberTitle', 'off');


tetrodes = { 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, ...
            11, 12, 13, 14, 15, 16, 17, 18, 19, 20, ...
            21, 22, 23, 24, 25, 26, 27, 28, 29, 30}';

locations = repmat({'N/A'}, size(tetrodes));

data = [tetrodes, locations];
col_names = {'TT', 'ANAT'};

uiTable = uitable(f, 'Data', data, 'ColumnName', col_names, 'Units', 'Normalized',...
    'Position', [.05 .1 .9 .9], 'ColumnEditable', logical([0,1]));
set(uiTable, 'Units', 'Pixels', 'ColumnWidth', {60, 60});
set(uiTable, 'Units', 'Normalized');


load_btn = uicontrol('style', 'pushbutton', 'string', 'Load', 'Units', 'Normalized',...
    'Position', [.4  .015 .18 .05], 'CallBack', @load_fn); %#ok

save_btn = uicontrol('style', 'pushbutton', 'String', 'Save', 'Units', 'Normalized',...
    'Position', [.6 .015 .18 .05], 'CallBack', @save_fn); %#ok

quit_btn = uicontrol('style', 'pushbutton', 'String', 'Quit', 'Units', 'Normalized',...
    'Position', [.8 .015 .18 .05], 'CallBack', @quit_fn); %#ok


saved = 0;

    function load_fn(varargin)
       if exist(fullfile(edir, 'tt_anatomy.mat'), 'file')
           dataIn = load(fullfile(edir, 'tt_anatomy.mat'));
           set(uiTable, 'Data', dataIn.tt_anatomy);
       else
           errordlg('File does not exist');
       end    
    end

    function save_fn(varargin)
        answer = 'Yes';
        if exist( fullfile(edir, 'tt_anatomy.mat') , 'file')
            answer = questdlg('File exist, overwrite?');
        end

        if strcmp('Yes', answer)
            disp( ['Saving: ',fullfile(edir, 'tt_anatomy.mat') ] );
            tt_anatomy = get(uiTable, 'Data'); %#ok
            save( fullfile(edir,'tt_anatomy.mat'), 'tt_anatomy');
            saved = 1;    
        end
    end

    function quit_fn(varargin)
        if ~saved
            answer = questdlg('Would you like to save first?');
            if strcmp('Yes', answer)
                save_fn();
            elseif strcmp('Cancel', answer)
                    return
            end
        end
        close(f);
    end
    
end










