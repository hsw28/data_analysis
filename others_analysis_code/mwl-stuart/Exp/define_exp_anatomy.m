function f = define_exp_anatomy(session_dir)
% A simple GUI to define sources (electrodes) and signals (data collected
% from those electrodes). 
% Written 2009 by Stuart Layton
f = figure('Position', [200 0 300 800], 'Name', 'Define Sources');

extracted_dir = fullfile(session_dir, 'raw/');
files = dir(extracted_dir);
files = files(3:end); % cut off . and ..

eeg_files =get_dir_names(fullfile(extracted_dir, '*.eeg'));
tt_files = get_dir_names(fullfile(extracted_dir, '*.tt'));

sources = {};
for ef=1:length(eeg_files)
    e = eeg_files{ef};
    for i=1:8
        sources(end+1,1) = {[e(1:8),'ch',num2str(i)]};
    end
end
sources = [tt_files; sources];

tetrodes = repmat({''}, size(sources));
for tf=1:length(tt_files)
    t = tt_files{tf};
    tetrodes(tf,1) = {t(5:7)};
end

locations = repmat({'CA1'}, size(sources));

data = [sources, tetrodes, locations];
col_names = {'Signals', 'Sources', 'Location'};

u = uitable(f, 'Data', data, 'ColumnName', col_names, 'Units', 'Normalized',...
    'Position', [.05 .05 .9 .925], 'ColumnEditable', logical([0,1,1]));
set(u, 'Units', 'Pixels', 'ColumnWidth', {91, 73, 73});
set(u, 'Units', 'Normalized');

load_btn = uicontrol('style', 'pushbutton', 'string', 'Load', 'Units', 'Normalized',...
    'Position', [.2  .015 .18 .025], 'CallBack', @load_fn);

save_btn = uicontrol('style', 'pushbutton', 'String', 'Save', 'Units', 'Normalized',...
    'Position', [.4 .015 .18 .025], 'CallBack', @save_fn);

quit_btn = uicontrol('style', 'pushbutton', 'String', 'Quit', 'Units', 'Normalized',...
    'Position', [.6 .015 .18 .025], 'CallBack', @quit_fn);

saved = 0;

    function load_fn(varargin)
       if exist(fullfile(session_dir, 'sources.mat'))
           dataIn = load(fullfile(session_dir, 'sources.mat'));
           set(u, 'Data', dataIn.sources_and_signals);
       else
           errordlg('File does not exist');
       end    
    end

    function save_fn(varargin)
        answer = 'Yes';
        if exist(fullfile(session_dir, 'sources.mat'))
            answer = questdlg('File exist, overwrite?');
        end

        if strcmp('Yes', answer)
            disp(['Saving: ',fullfile(session_dir, 'sources.mat')]);
            sources = get(u, 'Data');
            save(fullfile(session_dir,'sources.mat'), 'sources');
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
