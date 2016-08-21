function f = line_detection_viewer(data, varargin)
%LINE_DETECTION_VIEWER returns a handle to a figure used to view
%replay_line_detection.m generated data
%
% Most common uses for this function is to call it directly on the data
% created by replay_line_detection.m
%
% see also est_line_detect.m replay_line_detection.m

    args.shuffle_data = 0;
    args = parseArgs(varargin, args);
   
    f = figure( 'Position', [820  350 700 450], 'Name', 'Line Detection Viewer',...
        'NumberTitle', 'off');
   
    epochs = fieldnames(data);
    e = epochs{1};
    cur_ind = 0;
    
   
    line_list = uicontrol('Style', 'ListBox', 'units', 'normalized',...
        'Position', [.85 .02 .13 .88],'Callback', @list_sel_fn);
   
    ep_sel = uicontrol('Style', 'popupmenu',  'String', epochs, 'units', 'normalized',...
        'Position', [.85 .95 .13 .02], 'callback', @epoch_sel_fn);
    
    a(1) = axes('Units', 'Normalized', 'Box', 'on', ...
        'Position', [.05 .05 .60 .90], 'Parent', f);
    
    r_score_lbl = uicontrol('Style', 'Text', 'units', 'normalized', ...
        'Position', [.67 .80 .18 .03], 'BackgroundColor', [.8 .8 .8]);
    
    ev_dur_lbl = uicontrol('Style', 'Text', 'units', 'normalized', ...
        'Position', [.67 .75 .18 .03], 'BackgroundColor', [.8 .8 .8]);
    
 %   copy_btn = uicontrol('Style', 'Pushbutton', 'String', 'Copy', 'Units', 'Normalized', ...
 %       'Position', [.67 .2 .16 .075], 'Parent', f, 'callback', @copy_fn);
    
    if isstruct(args.shuffle_data)
        shuf = 1;
        set(f, 'Position', [800 300 700 900]);
         set(a(1), 'Position', [.05 .5 .60 .450])
        a(2) = axes('Parent', f, 'Units', 'normalized', 'Position', [.05 0.05 .6 .40]);
    else
        shuf = 0;
    end
    
    epoch_sel_fn();
    list_sel_fn();
    colormap('gray');

    
    %% Update Plots
    function update_plots()

        x = data.(e).inputs(cur_ind).tbins;
        y = data.(e).inputs(cur_ind).pbins;
        c = smoothn(data.(e).inputs(cur_ind).pdf, 3, 'kernel', 'box');
    
        imagesc(x,y,c, 'Parent', a(1));
        %set(a(1), 'YDir', 'normal', 'YTick', [], 'XLim', data.(e).trig(cur_ind,:));

        y = data.(e).slope(cur_ind) .* x + data.(e).intercept(cur_ind);

        %[x;y]
        line(x,y, 'Color', 'g', 'LineStyle', '--','Marker', '.', 'MarkerSize', 15, 'Parent', a(1))
        %line(x,y, 'Color', 'w', 'LineStyle', '--', 'Parent', a(1))

        if shuf
            update_shuffle_plot()
        end
        %disp(['Cur Ind:',  num2str(cur_ind)]);
    end
    function update_shuffle_plot()
        bins =  0:.005:1;
        s_pdf  = smoothn( histc(args.shuffle_data.(e).rand_identity(cur_ind).dist, bins), 5);
        s_tbin = smoothn( histc(args.shuffle_data.(e).rand_tbins(cur_ind).dist, bins), 5);
        s_rpos = smoothn( histc(args.shuffle_data.(e).rand_pos(cur_ind).dist, bins), 5);

        plot(bins, s_pdf, 'r',...
             bins, s_tbin, 'g',...
             bins, s_rpos, 'k',...
             'lineWidth', 2, 'Parent', a(2)); 
         legend(a(2),'Rand Cell ID', 'Rand Time Shift', 'Rand Pos Shift');
         %legend(a(2),'Rand Cell ID', 'Rand Pos Shift');
         
         y_max = max([max(s_pdf), max(s_rpos)]);%, max(s_tbin)]);
         line( repmat(data.(e).score(cur_ind),2,1), [0 y_max*1.1],...
             'LineWidth',3, 'LineStyle', '--', 'Parent', a(2));
         set(a(2), 'YLim', [0, y_max]);

    
    end
    
    %% Call back functions
    function list_sel_fn(varargin)
       cur_ind = get(line_list, 'Value');
       sc = floor(data.(e).score(cur_ind)*1000)/1000;
       set(r_score_lbl, 'String', ['R Score: ', num2str(sc)]);
       dt = data.(e).inputs(cur_ind).tbins(end) - data.(e).inputs(cur_ind).tbins(1);
%       set(ev_dur_lbl, 'String',  ['Event Dur: ', num2str(dt)]);
       set(ev_dur_lbl, 'String',  ['Event Ind: ', num2str(get(line_list,'Value'))]);
       update_plots();
    end
    
    function epoch_sel_fn(varargin)
        e = epochs{get(ep_sel, 'Value')};
        set(line_list, 'String', {data.(e).trig(:,1)}, 'Value', 1);
        list_sel_fn();
    end

    function copy_fn(varargin)
        fig_new = figure;
        a_new = axes('Parent', fig_new, 'Units', 'Normalized', ...
            'Position', [0 .5 1 .5]);
        copyobj(allchild(a(1)), a_new);
        
        a_new = axes('Parent', fig_new, 'Units', 'Normalized', ...
            'Position', [0 0 1 .5]);
        copyobj(allchild(a(2)), a_new);
    end
        
                
    
end

