function dset_view_placefields(dsetClusters, dsetPosition, varargin)
% DSET_VIEW_PACEFIELDS - opens a special figure that displays placefields
%   oringal_data 1 or 0, 1 signals that the experiment is freshly loaded an
%   unfiltered by an evaluated
%   force_hold 1 or 0, if set to 1 then the matlab environment is held
%   until this figure closes.
%
%% Globals
switch numel(varargin)
    case 0
        orig_data = 0;
        hold_force = 0;
    case 1
        orig_data = varargin{1};
        hold_force = 0;
    otherwise
        orig_data = varargin{1};
        hold_force = varargin{2};
end

clusters = dsetClusters;
position = dsetPosition;
%  cell_num = 0;
pf = [];


% Load the placefield for each neuron, if the field hasn't been computed
% compute it now!
for i=1:numel(clusters)
    if ~isfield(clusters(i), 'pf')
        pf(i,:) = dset_calc_tc(clusters(i).st, position, 1/30);
    else
        pf(i,:) = clusters(i).pf;
    end
end

m1 = [];
m2 = [];

if numel(varargin)>0
    hold_cli = varargin{1};
else
    hold_cli = 0;
end


%% Setup Ploting

f =figure();
%% Setup GUI
set(f, 'Position', [350 250 560 750]);
list_box = uicontrol('Style', 'listbox', 'Units', 'Normalized',...
    'Position', [.88 .06 .1 .86], 'CallBack', @list_selection);

next_btn = uicontrol('Style', 'PushButton', 'Units', 'normalized', ...
    'Position', [ .43 .93 .18 .03], 'String', 'Next Cell', 'CallBack', @next_cell_fn);

prev_btn = uicontrol('Style', 'PushButton', 'Units', 'normalized', ...
	'Position', [ .24 .93 .18 .03], 'String', 'Prev Cell', 'CallBack', @prev_cell_fn);


a(1) = axes('Position', [0.06 0.49 0.76 0.35], 'XTick', [], 'YTick', [], 'Box', 'on');

a(2) = axes('Position', [0.06 0.24 0.76 0.215], 'XTick', [], 'YTick', [], 'Box' ,'on');

a(3) = axes('Position', [0.06 0.06 0.76 0.15], 'XTick', [], 'YTick', [], 'Box', 'on');

set(f, 'ToolBar', 'figure')


update_list();


while (hold_force && ishandle(f))
    pause(.25);
end


%% Call Backs
 
    function update_list(varargin)

        cl_list = num2cell(1:numel(clusters));
%         for i=1:length(clusters) %#ok
%             cl_list{i} = i; %#ok
%       %      warning off;    %#ok
%             cv1(i,:) = exp.(epoch).cl(i).tc1;
%             cv2(i,:) = exp.(epoch).cl(i).tc2;
%       %      warning on;     %#ok
%         end
        set(list_box, 'String', cl_list, 'Value',1);
        list_selection();
    end
    function list_selection(varargin)
        cell_num = get(list_box, 'Value');
        update_plots(cell_num);
    end
    function update_plots(cell_num)
                    

        c = clusters(cell_num);
        warning off;    %#ok
        spike_pos.x = interp1(position.ts, position.rawx, c.st, 'nearest');
        spike_pos.y = interp1(position.ts, position.rawy, c.st, 'nearest');
        spike_pos.l = interp1(position.ts, position.linpos, c.st, 'nearest');
        spike_pos.v = interp1(position.ts, position.smooth_vel, c.st, 'nearest');
        warning on;     %#ok
        
        
        % Top plot - Environment
        velThold = 10;
        plot(position.rawx, position.rawy, '.b', 'markersize', 3, 'Parent', a(1)); hold(a(1), 'on');
        plot(spike_pos.x(spike_pos.v>velThold), spike_pos.y(spike_pos.v>velThold), 'r.', 'Parent', a(1)); 
        hold(a(1), 'off'); set(a(1), 'XTick', [], 'YTick', []); 

        % Middle Plot - Linear Track vs Time
        plot(position.linpos, position.ts, 'Parent', a(2));
        hold(a(2), 'on'); 
        plot(spike_pos.l, c.st, 'r.', 'Parent', a(2));
        
        hold(a(2), 'off');
        set(a(2), 'XTick', [], 'YTick', []);
        
        % Bottom Plot - Fields
        %cl = c;
        n_bins = size(pf,2);
        
        %cv1 = smoothn(cv1,1);
        %cv2 = smoothn(cv2,1);
        posBins = linspace(min(position.linpos), max(position.linpos), n_bins);

        
        %ax =min(position.linpos):.01:max(position.linpos);
        
        bar(posBins, pf(cell_num,:), 'FaceColor', 'r', 'EdgeColor', 'r', 'Parent', a(3));
        
             
        hold(a(3), 'off');
        set(a(3), 'XTick', [], 'XLim', [posBins(1), posBins(end)]);
        set(a(2),'XLim', [posBins(1), posBins(end)]);
        if max(pf(cell_num,:)) < 3
            set(a(3), 'YLim', [0 3]);
        end
        
        linkaxes(a(2:3), 'x');
        
    end
    function delete_cell_fn(varargin)
        ind = get(list_box, 'Value');

        update_plots();
    end
    function save_cells_fn(varargin)
        answer = 'Yes';
        if ~min(epochs_sel_flag)
            answer = questdlg('Not all epochs evaluated, save anyway?');
        end
        if strcmp('Yes', answer)
           
        end    
    end
    function my_close(varargin)
        
    end
    function next_cell_fn(varargin)
        cur_selection = get(list_box, 'Value');
        if cur_selection<length(clusters)
            set(list_box, 'Value', cur_selection+1);
            list_selection();
        end
    end

    function prev_cell_fn(varargin)
        cur_selection = get(list_box, 'Value');
        if cur_selection>1
            set(list_box, 'Value', cur_selection-1);
            list_selection();
        end
    end

    function truncate_fields(varargin)

        cv1 = m1;
        cv2 = m2;
        if get(trunc_chk, 'Value')
           n = str2num(get(trunc_npt, 'String'));
           cv1(:,1:n)=0;
           cv1(:,end+1-(1:n))=0;
           cv2(:,1:n)=0;
           cv2(:,end+1-(1:n))=0; 
        end
        list_selection();
    end

    function filter_clusters()
       
        fs = 10; %minimum field size of 10
        si = 4.5;%maximum spatial information
        mr = 50; %maximum rate of 
        mp =  2; %minimum peak rate
        
        for i=1:length(clusters)
            sis1 = spatialinfo(m1(i,:));
            sis2 = spatialinfo(m2(i,:));
            if ~((sum(m1(i,:))>fs || sum(m2(i,:))>fs)...  
                    && (sis1<si || sis2<si) ... 
                    && max(m1(i,:))<mr && max(m2(i,:))<mr ... %max rate can't be highter then 50
                    && (max(m1(i,:))>mp || max(m2(1,:))>mp))   % cell must have a minimum of peak rate of 3hz
                    %disp(i)

            end
        end
        
    end
    
    
end
 