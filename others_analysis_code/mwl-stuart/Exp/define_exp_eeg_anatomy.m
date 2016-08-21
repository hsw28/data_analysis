function f = define_exp_eeg_anatomy(edir)
% A simple GUI to define sources (electrodes) and signals (data collected
% from those electrodes). 
% Written 2009 by Stuart Layton
f = figure('Position', [800 480 281 500], 'Name', 'Define Eeg Anatomy', 'NumberTitle', 'off');

eeg_files = dir(fullfile(edir, '*.eeg'));
if isempty(eeg_files)
    eeg_files = dir( fullfile( edir, '*.buf') );
end
ch = {};
for i=1:numel(eeg_files)
    for j=1:8
        ch{(i-1)*8 + j} = ['eeg',num2str(i),'.ch',num2str(j)];
    end
end
ch = ch';
           
locations = repmat({'na'}, size(ch));

data = [ch, locations];
col_names = {'EEG Channel', 'Location'};

u = uitable(f, 'Data', data, 'ColumnName', col_names, 'Units', 'Normalized',...
    'Position', [.05 .1 .9 .9], 'ColumnEditable', logical([0,1]));
set(u, 'Units', 'Pixels', 'ColumnWidth', {110, 110});
set(u, 'Units', 'Normalized');


load_def_btn = uicontrol('style', 'pushbutton', 'String', 'Load Default', 'Units', 'Normalized',...
    'Position', [.01 .015 .37 .05], 'CallBack', @load_defaults);

load_btn = uicontrol('style', 'pushbutton', 'string', 'Load', 'Units', 'Normalized',...
    'Position', [.4  .015 .18 .05], 'CallBack', @load_fn);

save_btn = uicontrol('style', 'pushbutton', 'String', 'Save', 'Units', 'Normalized',...
    'Position', [.6 .015 .18 .05], 'CallBack', @save_fn);

quit_btn = uicontrol('style', 'pushbutton', 'String', 'Quit', 'Units', 'Normalized',...
    'Position', [.8 .015 .18 .05], 'CallBack', @quit_fn);

if exist(fullfile(edir, 'eeg_anatomy.mat'))
    load_fn();
end

saved = 0;

    function load_fn(varargin)
       if exist(fullfile(edir, 'eeg_anatomy.mat'))
           dataIn = load(fullfile(edir, 'eeg_anatomy.mat'));
           set(u, 'Data', dataIn.eeg_anatomy);
       else
           errordlg('File does not exist');
       end    
    end

    function save_fn(varargin)
        answer = 'Yes';
        if exist(fullfile(edir, 'eeg_anatomy.mat'))
            answer = questdlg('File exist, overwrite?');
        end

        if strcmp('Yes', answer)
            disp(['Saving: ',fullfile(edir, 'eeg_anatomy.mat')]);
            eeg_anatomy = get(u, 'Data');
            save(fullfile(edir,'eeg_anatomy.mat'), 'eeg_anatomy');
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
    function load_defaults(varargin)
        prompt = 'Select Experiment Type';
        va = {  'CA1 - Right', ...
                'CA1 - Left', ...
                'CA1 - Bilateral', ...
                'CA3 - Right', ...
                'CA1 - Left', ...
                'CA3 - Bilateral', ...
                'other'
                };
        sel = listdlg('PromptString', prompt, 'liststring', va, 'SelectionMode', 'single');
        if isempty(sel)
            return
        end
        sel = va{sel};
        d = get(u, 'data');
        
        switch sel
            case 'CA1 - Right'
                d(:,2) = {'rCA1'};
            case 'CA1 - Left'
                d(:,2) = {'lCA1'};
            case 'CA3 - Right'
                d(:,2) = {'rCA3'};
            case 'CA3 - Left'
                d(:,2) = {'lCA3'};
            case 'CA1 - Bilateral'
                d(:,2) = bi_ca1_def(:,2);
            case 'CA3 - Bilateral'
                d(:,2) = bi_ca3_def(:,2);
        end
        set(u,'Data', d);
    end

    bi_ca1_def={'eeg1.ch1', 'rCA1'; ...
                'eeg1.ch2', 'rCA1'; ...
                'eeg1.ch3', 'rCA1'; ...
                'eeg1.ch4', 'rCA1'; ...
                'eeg1.ch5', 'rCA1'; ...
                'eeg1.ch6', 'rCA1'; ...
                'eeg1.ch7', 'rCA1'; ...
                'eeg1.ch8', 'rCA1'; ...
                'eeg2.ch1', 'lCA1'; ...
                'eeg2.ch2', 'lCA1'; ...
                'eeg2.ch3', 'lCA1'; ...
                'eeg2.ch4', 'lCA1'; ...
                'eeg2.ch5', 'lCA1'; ...
                'eeg2.ch6', 'lCA1'; ...
                'eeg2.ch7', 'lCA1'; ...
                'eeg2.ch8', 'lCA1'; ...
                };

            
    bi_ca3_def={'eeg1.ch1', 'rCA3'; ...
                'eeg1.ch2', 'rCA3'; ...
                'eeg1.ch3', 'rCA3'; ...
                'eeg1.ch4', 'rCA3'; ...
                'eeg1.ch5', 'rCA3'; ...
                'eeg1.ch6', 'rCA3'; ...
                'eeg1.ch7', 'rCA3'; ...
                'eeg1.ch8', 'rCA3'; ...
                'eeg2.ch1', 'lCA3'; ...
                'eeg2.ch2', 'lCA3'; ...
                'eeg2.ch3', 'lCA3'; ...
                'eeg2.ch4', 'lCA3'; ...
                'eeg2.ch5', 'lCA3'; ...
                'eeg2.ch6', 'lCA3'; ...
                'eeg2.ch7', 'lCA3'; ...
                'eeg2.ch8', 'lCA3'; ...
                };
end










