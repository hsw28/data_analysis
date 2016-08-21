function  compare_epoch_clusters(exp, epoch1, epoch2)
%% Globals
my_fig = figure('Position', [100 100 900 600]); 
[ep1_tet_list ep1_tet_ind_list] = unique({exp.(epoch1).cl.tt});
[ep2_tet_list ep2_tet_ind_list]= unique({exp.(epoch2).cl.tt});
tet_list = intersect(ep1_tet_list, ep2_tet_list);
warning('Very buggy');

ep1_tet_sel_ind = [];
ep2_tet_sel_ind = [];
ep1_cl_list = [];
ep2_cl_list = [];
cl_size = [1 1];
draw_order = 1;
cl_order = [1 2;2 1];
cl_color = ['r' 'b'; 'b' 'r'];

XY = 1; XA = 2; XB = 3; YA = 4; YB = 5; AB = 6; WF = 7:10;
proj_list = [XY XA XB YA YB AB];
field_names = {'t_px', 't_py', 't_pa', 't_pb'};
proj_ind = [1 2; 1 3; 1 4; 2 3; 2 4; 3 4];
null_clust = [];
clust_rel = cell(0,3);
rel_del_ind = [];



%%  Cluster and Waveform plot Axes
ax(XY) = axes('Units', 'Normalized', 'Position', [0/4 2/3 1/4 1/3]);
ax(XA) = axes('Units', 'Normalized', 'Position', [1/4 2/3 1/4 1/3]);
ax(XB) = axes('Units', 'Normalized', 'Position', [0/4 1/3 1/4 1/3]);
ax(YA) = axes('Units', 'Normalized', 'Position', [1/4 1/3 1/4 1/3]);
ax(YB) = axes('Units', 'Normalized', 'Position', [0/4 0/3 1/4 1/3]);
ax(AB) = axes('Units', 'Normalized', 'Position', [1/4 0/3 1/4 1/3]);
ax(WF(1)) =  axes('Units', 'Normalized', 'Position', [4/8 0/3 1/8 1/3]);
ax(WF(2)) =  axes('Units', 'Normalized', 'Position', [5/8 0/3 1/8 1/3]);
ax(WF(3)) =  axes('Units', 'Normalized', 'Position', [6/8 0/3 1/8 1/3]);
ax(WF(4)) =  axes('Units', 'Normalized', 'Position', [7/8 0/3 1/8 1/3]);
set(ax, 'XTick', [], 'YTick', [], 'Box', 'on');

%% Tetrode Selectors

%{
ep_sel_lbl1 = uicontrol('Style', 'Text', 'units', 'normalized', ...
    'Position', [1/2+.01  .94  1/4-.05 .05], 'String', 'Epoch 1 ', 'BackgroundColor', [.8 .8 .8]);
ep_sel_ui1 = uicontrol('Style', 'popupmenu', 'units', 'normalized',...
    'Position', [1/2+.01 .94 1/4-.05 .025], 'String', ep);

ep_sel_lbl2 = uicontrol('Style', 'Text', 'units', 'normalized', ...
    'Position', [1/2+.01  .87  1/4-.05 .05], 'String', 'Epoch 2', 'BackgroundColor', [.8 .8 .8]);
ep_sel_ui2 = uicontrol('Style', 'popupmenu', 'units', 'normalized',...
    'Position', [1/2+.01 .87 1/4-.05 .025], 'String', ep);
%}
tet_sel_lbl = uicontrol('Style', 'Text', 'units', 'normalized', ...
    'Position', [.51  .94  .1 .023], 'String', 'Tetrode List', 'BackgroundColor', [.8 .8 .8]);
tet_sel_ui = uicontrol('Style', 'popupmenu', 'units', 'normalized',...
    'Position', [.615 .945 .05 .025], 'String', tet_list, 'callback', @tet_sel_fn);

%% Cluster Lists
                        

cl_list_lbl1 = uicontrol('Style', 'Text', 'Units', 'Normalized',...
    'Position', [.52 .89 .0833 .02], 'String', epoch1,  'BackgroundColor', [.8 .8 .8]);
cl_list_ui1 = uicontrol('Style', 'ListBox', 'Units', 'Normalized',...
    'Position', [.52 .44  .0833 .44], 'Callback', @cluster_sel_fn);
cl_size_chk1 = uicontrol('Style', 'Checkbox', 'Units', 'Normalized',...
    'Position', [.52 .4   .0833 .03], 'String', 'Draw Big',...
    'BackgroundColor', [.8 .8 .8], 'Callback', @cl_size_fn);

cl_list_lbl2 = uicontrol('Style', 'Text', 'Units', 'Normalized',...
    'Position', [.62 .89 .0833 .02], 'String', epoch2,  'BackgroundColor', [.8 .8 .8]);
cl_list_ui2 = uicontrol('Style', 'ListBox', 'Units', 'Normalized',...
    'Position', [.62 .44  .0833 .44], 'callback', @cluster_sel_fn);
cl_size_chk2 = uicontrol('Style', 'Checkbox', 'Units', 'Normalized',...
    'Position', [.62 .4   .0833 .03], 'String', 'Draw Big',... 
    'BackgroundColor', [.8 .8 .8], 'Callback', @cl_size_fn);

%% Check boxes
plot_all_chk = uicontrol('Style', 'CheckBox', 'Units', 'Normalized', ...
    'Position', [.52 .36 .0833 .04], 'String', 'Null Cl', 'BackgroundColor', [.8 .8 .8], ...
    'Callback', @cluster_sel_fn); 

swap_order_chk = uicontrol('Style', 'pushbutton', 'Units', 'Normalized', ...
    'Position', [.62 .36 .0833 .04], 'String', 'Swap Order', 'BackgroundColor', [.8 .8 .8], ...
    'Callback', @swap_order_fn); 

%% Linkers
link_cl_btn = uicontrol('Style', 'PushButton', 'Units', 'Normalized', ...
    'Position', [.73 .94 .11 .04], 'String', 'Link Clusters', 'callback', @link_cl_fn);

rm_link_btn = uicontrol('Style', 'PushButton', 'Units', 'Normalized', ...
    'Position', [.85 .94 .11 .04], 'String', 'Remove Link', 'callback', @rm_link_fn);

link_tbl = uitable('Units', 'Normalized', 'Data', clust_rel,...
    'ColumnName', {'TetID', epoch1, epoch2},'ColumnWidth', {35 70 70}, ...
    'Position', [.73 .395 .24 .53]);

set(link_tbl, 'CellSelectionCallback', @tbl_highlight_fn);

%% Save and Close

save_link_btn = uicontrol('Style', 'PushButton', 'Units', 'Normalized', ...
    'Position', [.73 .345, .11, .04], 'String', 'Save Links', 'Callback', @save_link_fn);

close_btn = uicontrol('Style', 'Pushbutton', 'Units', 'Normalized', ...
    'Position', [.85 .345 .11 .04], 'String', 'Close', 'callback', {@(hObj, eventdata) delete(my_fig)});


    
%% GO!
tet_sel_fn(tet_sel_ui, []);
cluster_sel_fn([],[]);

%% Functions
   

    function load_cluster_lists(ind_ep1, ind_ep2)
        disp('Loading Cluster Lists for each Epoch');
        cl1 = exp.(epoch1).cl(ep1_tet_ind_list(ind_ep1));
        cl2 = exp.(epoch2).cl(ep2_tet_ind_list(ind_ep2));
        ep1_cl_list = get_dir_names(fullfile(fileparts(cl1.file),  'cl*'));
        ep2_cl_list = get_dir_names(fullfile(fileparts(cl2.file), 'cl*'));
        set(cl_list_ui1, 'Value', 1, 'String', ep1_cl_list);
        set(cl_list_ui2, 'Value', 1, 'String', ep2_cl_list);
    end

    function data = load_cluster(epoch, ep_n, tet_ind, cl_file)
        %disp('Loading Cluster Data');
        %ep1_tet_list{tet_ind}
        %ep1_tet_ind_list(tet_ind)
        %ep1_tet_sel_ind
        disp(cl_file)
        switch ep_n
            case 1
                ep1_tet_list
                ep1_tet_ind_list
                cl_file = exp.(epoch).cl(ep1_tet_ind_list(tet_ind));
                %disp(['Loading:', fullfile(exp.(epoch).cl(ep1_tet_ind_list(tet_ind)).path, cl_file)]);
                disp(cl_file.file)
                f = mwlopen(cl_file.file);
            case 2
                %disp(['Loading:', fullfile(exp.(epoch).cl(ep2_tet_ind_list(tet_ind)).path, cl_file)]);
                cl_file = exp.(epoch).cl(ep2_tet_ind_list(tet_ind));
                disp(cl_file.file)
                f = mwlopen(cl_file.file);
        end
        data = load(f, field_names);
    end

    function wave = load_waveform(epoch, ep_n, tet_ind, cl_file)
        %disp(epoch);
        switch ep_n
            case 1
                tt_f = fullfile(exp.(epoch).cl(ep1_tet_ind_list(tet_ind)).path, exp.(epoch).cl(ep1_tet_ind_list(tet_ind)).ttfile);
                cl_f = fullfile(exp.(epoch).cl(ep1_tet_ind_list(tet_ind)).path, cl_file);
            case 2
                tt_f = fullfile(exp.(epoch).cl(ep2_tet_ind_list(tet_ind)).path, exp.(epoch).cl(ep2_tet_ind_list(tet_ind)).ttfile);
                cl_f = fullfile(exp.(epoch).cl(ep2_tet_ind_list(tet_ind)).path, cl_file);
        end      
        wave = load_waveforms(tt_f, cl_f);
    end

    function clust = load_null_cluster(ind1)
        cl_file = exp.(epoch1).cl(ep1_tet_ind_list(ind1));
        
        f = mwlopen(fullfile(fileparts(cl_file.file), cl_file.tt,[ cl_file.tt, '.pxyabw']));
        clust = load(f, field_names);
        n_spike = size(clust.(field_names{1}),2);
        if n_spike>20000
            new_ind = randsample(n_spike, 45000);
        else
            new_ind = 1:n_spike;
        end
        for fn=field_names
            fn = fn{:};
            clust.(fn) = clust.(fn)(new_ind);
            clust.(fn)(clust.(fn)>10*std(single(clust.(fn))))=0;
        end            
    end
    

%% Update Plots!!!
    function update_plots(cl, wf)
        for i=proj_list
            if get(plot_all_chk, 'Value')
                if isempty(null_clust)
                    null_clust = load_null_cluster(ep1_tet_sel_ind);
                end

                %null_clust.(field_names{proj_ind(i,1)})
                plot(null_clust.(field_names{proj_ind(i,1)}), null_clust.(field_names{proj_ind(i,2)}), ...
                    'k.','Parent', ax(i), 'Color', [.5 .5 .5],'MarkerSize',1 );
                hold(ax(i), 'on');
            end
            order = cl_order(draw_order,:);
            col= cl_color(draw_order,:);
            plot(cl(order(1)).(field_names{proj_ind(i,1)}), cl(order(1)).(field_names{proj_ind(i,2)}),...
                [col(1),'.'], 'Parent', ax(i), 'MarkerSize',cl_size(order(1)));
            hold(ax(i), 'on');
            plot(cl(order(2)).(field_names{proj_ind(i,1)}), cl(order(2)).(field_names{proj_ind(i,2)}),...
                [col(2),'.'], 'Parent', ax(i), 'MarkerSize',cl_size(order(2)));
            hold(ax(i), 'off');
            xl = get(ax(i), 'XLim');
            yl = get(ax(i), 'YLim');
            set(ax(i), 'XLim', [0, xl(2)], 'YLim', [0 yl(2)]);
        end
        size(wf(1).ave);
        for i=WF
%            plot(wf(1).ave(i-6,:), 'r', 'Parent', ax(i)); hold(ax(i), 'on');
%            plot(wf(2).ave(i-6,:), 'b', 'Parent', ax(i)); hold(ax(i), 'off');
        end
        set(ax, 'Xtick', [], 'YTick', []);
       
    end

%% Callbacks
    function swap_order_fn(varargin)
        switch draw_order
            case 1
                draw_order = 2;
            case 2 
                draw_order = 1;
        end
        cluster_sel_fn();
    end
        
    function cl_size_fn(varargin)
        cl_size(1) = get(cl_size_chk1, 'Value')+4;
        cl_size(2) = get(cl_size_chk2, 'Value')+4;
        cluster_sel_fn();
    end
    function tbl_highlight_fn(hObj, eventdata)
        %disp(hObj)
        rel_del_ind = eventdata;
        rel_del_ind = rel_del_ind.Indices;
    end
    function link_cl_fn(hObj, eventdata)
        tet = tet_list{get(tet_sel_ui,'Value')};
        cl1 = ep1_cl_list{get(cl_list_ui1, 'Value')};
        cl2 = ep2_cl_list{get(cl_list_ui2, 'Value')};
        data = get(link_tbl, 'Data');
        data = [data; {tet cl1 cl2}];
        set(link_tbl, 'Data', data);
        
    end
    function rm_link_fn(hObj, eventdata)
        data = get(link_tbl, 'Data');
        if ~isempty(rel_del_ind)
            row_rm = unique(rel_del_ind(:,1));
            data_new = cell(size(data,1)-length(row_rm),3);
            c = 0;
            for i=1:size(data,1)

                if ~ismember(i, row_rm)
                    c = c+1;
                    data_new(c,:) = data(i,:);
                end
            end

            set(link_tbl, 'Data', data_new);
            rel_del_ind = [];
        end
        
        %ata(row_rm) = 
        
    end

    function tet_sel_fn(hObj, eventdata)
        %disp('Tetrode Selected!');
        sel_tet = tet_list{get(tet_sel_ui, 'value')};
        ep1_tet_sel_ind = find(ismember(ep1_tet_list, sel_tet));
        %disp(['Ep1 Ind:', num2str(ep1_tet_sel_ind), ' Tet:', ep1_tet_list{ep1_tet_sel_ind}]);
        ep2_tet_sel_ind = find(ismember(ep2_tet_list, sel_tet));
       %  data = load(f, field_names);disp(['Ep2 Ind:', num2str(ep2_tet_sel_ind), ' Tet:', ep2_tet_list{ep2_tet_sel_ind}]);        
        switch get(plot_all_chk, 'Value')
            case 0
                null_clust = [];
            case 1
                null_clust = load_null_cluster(ep1_tet_sel_ind);
        end
        load_cluster_lists(ep1_tet_sel_ind, ep2_tet_sel_ind);
        cluster_sel_fn()
    end
    function cluster_sel_fn(hObj, eventdata)
        %disp('Cluster Sel Fn');
       
        get(cl_list_ui1, 'value')
        cl(1)= load_cluster(epoch1,1, ep1_tet_sel_ind, ep1_cl_list{get(cl_list_ui1, 'value')});
        cl(2)= load_cluster(epoch2,2, ep2_tet_sel_ind, ep2_cl_list{get(cl_list_ui2, 'value')});
        wf(1).ave= nan;%load_waveform(epoch1,1, ep1_tet_sel_ind, ep1_cl_list{get(cl_list_ui1, 'value')});
        wf(2).ave= nan;%load_waveform(epoch2,2, ep2_tet_sel_ind, ep2_cl_list{get(cl_list_ui2, 'value')});
        update_plots(cl, wf);
    end

    function save_link_fn(varargin)
        link_data = get(link_tbl, 'Data');%#ok
        column_names = {'Tetrode', epoch1, epoch2}; %#ok
        file_name = fullfile(exp.session_dir, ['cl_link_',epoch1,'_',epoch2,'.mat']);
        save(file_name, 'link_data', 'column_names')
   
        
        
    end



    

end