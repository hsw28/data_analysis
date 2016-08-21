function valid_chan = plot_exp_eeg(exp, varargin)
%  valid_channels = evaluate_eeg(exp, original_data, force_hold)
%   exp = experiment struct
%   oringal_data 1 or 0, 1 signals that the experiment is freshly loaded an
%   unfiltered by an evaluated
%   force_hold 1 or 0, if set to 1 then the matlab environment is held
%   until this figure closes.
%

%%% GLOBALS


f = figure('position', [500 300 1000 800]);
set(f, 'Toolbar', 'figure');
%u = uiwrapper(f);
%u.DeleteFcn = @delete_all;
MAX_X = 1;
MAX_Y = .965;

n_chan = 0;
valid_chan = [];

a = [];
p = [];

%sources = load_signals(exp.session_dir);

%%%% Epoch Button Groups
epoch_sel_ui = uicontrol('Style','popupmenu', 'Units', 'Normalized', ...
    'Position', [.8 .9 .2 .1],'callback', @epoch_changed, 'String', exp.epochs);
 

%%% Channel Checkboxes
set(epoch_sel_ui(1), 'value', 1);
epoch = exp.epochs{1};

epoch_changed();


pan('xon');
zoom('xon');
%%% Setup AXES objects
%update_plots();

    function create_plots()
        %disp('Create Plots');
        for i=1:n_chan
            if exp.(epoch).eeg.loc{i}(1) == 'l'
                col = 'r';
            elseif exp.(epoch).eeg.loc{i}(1) == 'r'
                col = 'g';
            else
                col = 'b';
            end
                
            dy = MAX_Y/n_chan;
            a(i) = axes('Units', 'Normalized', 'Position', [0, MAX_Y-(i*dy), MAX_X, dy]);
            %p(i) =  plot(exp.(epoch).eeg_ts(ind), exp.(epoch).eeg(i).data(ind), 'Parent', a(i));
            p(i) =  line_browser(  exp.(epoch).eeg.data(:,i) ,exp.(epoch).eeg.ts(:), 'axes',a(i), 'color', col);            
        end
      
        set(a, 'XLim', [exp.(epoch).eeg.ts(1) exp.(epoch).eeg.ts(end)]);
        set(a, 'XTick', [], 'YTick', [], 'Box', 'off');
        linkaxes(a);
    end


    function epoch_changed(varargin)
       epoch = exp.epochs{get(epoch_sel_ui, 'Value')};
       delete(a);
       a = [];
       n_chan = 0;
       n_chan = size(exp.(epoch).eeg.data,2);
       create_plots();
    end
end

