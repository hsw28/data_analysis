function  reconstruction_browser(exp, epoch)
 
%DO NOT EDIT
clusters = exp.(epoch).clusters;
pos = exp.(epoch).position;
mua = exp.(epoch).multiunit.times;
%%%%%%% Setup GUI Components
f = figure();
a_recon = axes();
a_rast = axes();
a_multi = axes();
a_frame = axes();

set(a_recon, 'units', 'normalized');
set(a_rast , 'units', 'normalized');
set(a_multi, 'units', 'normalized');
set(a_frame, 'units', 'normalized');

aw = 1;  % axes width
bs = .03*aw;  %button size
tau = .25;
r_tau = .01;

set(a_recon, 'position', [0, .51, aw, .49]);
set(a_rast , 'position', [0, .26, aw, .25]);
set(a_multi, 'position', [0, .065, aw, .22]); 
set(a_frame, 'position', [0. .065, aw, 1-.065]);
%set(a_frame, 'position', [0, . aw .25]);

%%%%% Frame GUI
do_frames = uicontrol('Style', 'Checkbox', 'String','MUB Times', 'Units', 'normalized');
set(do_frames, 'Position', [.55, .013, .09, .025], 'backgroundcolor', [.8 .8 .8]);
show_frames = 0;
frame_times = exp.(epoch).mub_times;
set(do_frames, 'CallBack', @plot_frames);

%%%%% Navigation Buttons

next_btn = uicontrol('Style', 'PushButton', 'Parent', f);
set(next_btn, 'units', 'normalized', 'position', [.6+bs+.05 .01 bs bs]);
prev_btn = uicontrol('Style', 'PushButton', 'Parent', f);
set(prev_btn, 'units', 'normalized', 'position', [.6+.05 .01 bs bs]);
set(next_btn, 'callback', @next_fn)
set(prev_btn, 'callback', @prev_fn)

set(a_frame,'YLim',[0 1]);
%t_list = uicontrol('Style', 'listbox', 'units', 'normalized');
%set(t_list, 'position',[aw 0, 1-aw 1]);

%%%%%%% Reconstruction Field Direction  - Radio buttons
bg = uibuttongroup('Visible', 'on', 'Position', [.09 0.001 .07 .045]);
recon_dir1 = uicontrol('Style', 'radio', 'String',' TC dir-1', 'Units', 'normalized', 'Parent', bg);
set(recon_dir1, 'Position', [0 .5 1 .5], 'callback', @rad_dir1);
recon_dir2 = uicontrol('Style', 'radio', 'String',' TC dir-2', 'Units', 'normalized', 'Parent', bg);
set(recon_dir2, 'Position', [0  0 1 .5], 'callback', @rad_dir2);



%%%%%%% Replay Reconstruction Button
replay_btn = uicontrol('Style', 'PushButton', 'String', 'Do Replay Reconst', 'units', 'normalized');
set(replay_btn, 'position', [.71 .01 .15 bs]);
set(replay_btn, 'callback', @do_replay);

tau_lbl = uicontrol('Style', 'Text', 'String', 't', 'FontName', 'Symbol','FontSize',14 );
set(tau_lbl, 'Units', 'normalized', 'position', [.86 .010 bs bs], 'BackgroundColor', [.8 .8 .8]);
tau_inp = uicontrol('Style', 'edit', 'String', num2str(r_tau), 'Units', 'normalized');
set(tau_inp, 'position', [.88 .011, .05 .025]);

%%%%%%% Global Variables and Values
direct = 1; %direction is 1 or 0ts = pos.timestamp(1);
ts = pos.timestamp(1);
te = pos.timestamp(end);
srb = spike_raster_browser(clusters, a_rast);
mub = multi_unit_browser(mua, a_multi);
tc = [];
tc1 = [];
tc2 = [];

cell_n = uicontrol('Style', 'Text', 'String', ['# of Cells:', num2str(length(clusters))]);
set(cell_n, 'units', 'normalized', 'position', [.01 .015 .08 .015], 'backgroundcolor', [.8 .8 .8]);

%%%%%%% Generate Reconstruction
[pdf1 pdf2] = do_reconstruction(ts, te, tau);
tc = tc1;
cur_field_dir=1;

im = imagesc(pdf1, 'Parent', a_recon);
set(im, 'XData', [ts te]);
set(a_recon, 'YDir', 'normal');
set(a_recon, 'Color', [0 0 0 ]);
set(a_recon, 'XLim', [ts te]);

%%%%%% Make overlay
set(a_frame, 'color', 'none');
set(a_frame, 'XTick', []);
set(a_frame, 'YTick', []);

%%%%%%% Zoom and Pan Buttons


zi = uicontrol('Style', 'PushButton', 'units', 'normalized', 'position', [.455*aw .01 bs bs]);
zo = uicontrol('Style', 'PushButton','units',  'normalized', 'position', [.515*aw .01 bs bs]);
p = uicontrol('Style', 'PushButton', 'units',  'normalized', 'position', [.485*aw .01 bs bs]);
j1 = java(findjobj(zi));
j2 = java(findjobj(zo));
j3 = java(findjobj(p));
j4 = java(findjobj(prev_btn));
j5 = java(findjobj(next_btn));


icon = fullfile(matlabroot, 'toolbox/matlab/icons/tool_zoom_in.png');
j1.setIcon(javax.swing.ImageIcon(icon));
icon = fullfile(matlabroot, 'toolbox/matlab/icons/tool_zoom_out.png');
j2.setIcon(javax.swing.ImageIcon(icon));
icon = fullfile(matlabroot, 'toolbox/matlab/icons/tool_hand.png');
j3.setIcon(javax.swing.ImageIcon(icon));
icon = '/usr/share/icons/Crux/24x24/actions/stock_left.png';
j4.setIcon(javax.swing.ImageIcon(icon));
icon = '/usr/share/icons/Crux/24x24/actions/stock_right.png';
j5.setIcon(javax.swing.ImageIcon(icon));

set(zi, 'CallBack', @my_zoom_in);
set(zo, 'CallBack', @my_zoom_out);
set(p,  'CallBack', @my_pan);

%length(stop_times(1))

%%%%%% Plot Position Overlay
hold(a_recon, 'on');
plot(pos.timestamp, pos.linear_position*10, '--b', 'Parent', a_recon);
hold(a_recon, 'off');

%%%%%% Last minute GUI Stuf
colormap('hot');
set(a_multi, 'color', [0 0 0 ]);
%cmap2 = srb.color_map
set(gcf, 'Position', [100 100 1200 800]);
linkaxes([a_recon,  a_rast, a_multi, a_frame],'x');

%%%% CallBack Functions    
    function my_zoom_in(varargin)
     %  disp('zoom in');
        h = zoom(gcf); set(h,'Motion', 'horizontal', 'Direction', 'in', 'Enable', 'on');
    end
    function my_zoom_out(varargin)
    %   disp('zoom out');
        h = zoom(gcf); set(h,'Motion', 'horizontal', 'Direction', 'out', 'Enable', 'on');
    end
    function my_pan(varargin)
    %    disp('pan');
        h = pan(gcf); set(h,'Motion', 'horizontal', 'Enable', 'on');
    end

    function rad_dir1(varargin)
        if cur_field_dir ~=1
            cur_field_dir =1;
            set(im, 'CData', pdf1);
            tc = tc1;
        end
    end

    function rad_dir2(varargin)
        if cur_field_dir ~=2
            cur_field_dir =2;
            set(im, 'CData', pdf2);
            tc = tc2;
        end
    end

%%%%%  Reconstruction Functions
    function [pdf1 pdf2] =  do_reconstruction(tstart, tend, tau)
        
        if isempty(tc)
            tc1 = get_tuning_curves(1);
            tc2 = get_tuning_curves(0);
        end
        t_bins = tstart:tau:tend;
        spike_counts= zeros(length(clusters), length(t_bins));
        for i=1:length(clusters)
            spike_count(i,:) = histc(clusters(i).time, t_bins);
        end
        %[size(tc) 0 0 size(spike_count)] %debuging output
        pdf1 = parameter_estimation_simple(tau, tc1', spike_count);
        pdf2 = parameter_estimation_simple(tau, tc2', spike_count);

    end

    function tc = get_tuning_curves(direct)
        if direct
            f = 'field1';
        else
            f = 'field2';
        end
        
        for i=1:length(clusters)
            tc(i,:) = clusters(i).(f);
        end;        
    end
%%%%%% Replay Functinos

    function do_replay(varargin)
        lims = get(a_recon, 'XLim');
        r_tau = str2double(get(tau_inp, 'String'));
        replay_reconstruction(lims(1), lims(2));
    end
    function replay_reconstruction(tstart, tend)
        
        t_bins = tstart:r_tau:tend;
        spike_count= zeros(length(clusters), length(t_bins));
        for i=1:length(clusters)
            spike_count(i,:) = histc(clusters(i).time, t_bins);
        end
        %[size(tc) 0 0 size(spike_count)] %debuging output
        pdf = parameter_estimation_simple(tau, tc', spike_count);
        plot_replay(pdf, tstart, tend);
    end
    function plot_replay(pdf, tstart, tend)
       
        p = get(gcf, 'Position');
               
        figure; set(gcf, 'Position', [p(1) 400, p(3), 400]);
        i = imagesc(pdf);    
        set(i, 'XData', [tstart tend]);
        set(gca, 'Units', 'normalized', 'position', [0 .1 1 1]); colormap('hot');
        set(gca, 'YTick', [], 'XLim', [tstart tend]);
        zoom('xon', gca);
    end

%%%%%%%% Nav Functions
    function next_fn(varargin)
        lims = get(a_multi, 'XLim');
        s = lims(2);
        e = lims(2)+(lims(2)-lims(1));
        set(a_multi,'XLim', [s e])
    end
    function prev_fn(varargin)
        lims = get(a_multi, 'XLim');
        s = lims(1)-(lims(2)-lims(1));
        e = lims(1);
        set(a_multi,'XLim', [s e])
    end

%%%%%%%% Frames Functions        
    function plot_frames(varargin)
        show_frames = ~show_frames;
        
        if show_frames
            
            for i=1:length(frame_times)
                frame = frame_times(i,:);
                dx = frame(2)-frame(1);
                dy = 1;
                [frame, 0 0 0 ];
                my_rectangle(frame(1), 0, dx, dy, '--','g',  a_frame);
            end
        else
            cla(a_frame);
        end
            
    end
end
