function f = recon_complex_browser(exp, varargin)

args.epoch = 'none_specified';
args.dividers = 0;
args.eeg = 'off';
args.eeg_ch = 1;
args.per_overlap = 0;
args = parseArgs(varargin, args);
ep  = args.epoch;
if ~isfield(exp, ep)
    error(['Invalid epoch chosen: ' ,  ep]);
end
if strcmp(args.eeg, 'on') && isfield(exp.(ep), 'eeg')
    eeg = true;
else
    eeg = false;
end
if args.per_overlap < 0 || args.per_overlap >=1
    error('Invalid moving window, percent overlap must be >=0 and <1');
end

%% Globals
show_mub = 0;
tau_big = .25;
tau_small = .02;
tc = [];

main_pdf = [];
replay_pdf = [];
dividers = args.dividers;

position_ts = exp.(ep).position.timestamp;
position = exp.(ep).position.lin_pos;
multiunit = exp.(ep).multiunit.rate;
multiunit_ts =  exp.(ep).multiunit.timestamps;
clusters = exp.(ep).clusters;
if eeg
    eeg_dat = exp.(ep).eeg(args.eeg_ch).data;
    disp('Filtering eeg....');
    filt = getfilter(exp.(ep).eeg(args.eeg_ch).fs, 'ripple', 'win');
    rip_dat = filtfilt(filt, 1, eeg_dat);
    eeg_ts = exp.(ep).eeg_ts;
end

%% Do run recon
do_run_recon();
%imagesc(main_pdf);
%% setup gui
f = figure('toolbar', 'figure', 'Name', ['Complex Replay Browser: ',  exp.session_dir, ':', ep],...
    'Position', [200 32 1200 600], 'NumberTitle', 'off' );
f_replay = nan;
a_replay = [];

RECO = 1; RAST = 2; MU = 3; EEG = 4; OVER=5; 
a(RECO) = axes('Units', 'Normalized', 'Position', [0 .5  1 .5]);
a(RAST) = axes('Units', 'Normalized', 'Position', [0 .25 1 .25]);
if ~eeg
    a(EEG)  = axes('units', 'normalized', 'Position', [0 .075 1 .175], 'Color', 'none');
    a(MU)   = axes('units', 'normalized', 'Position', [0 .075 1 .175], 'Color', 'k');
else
    a(EEG)  = axes('units', 'normalized', 'Position', [0 .1625 1 .0875], 'Color', 'k');
    a(MU)   = axes('units', 'normalized', 'Position', [0 .075  1 .0875], 'Color', 'k');
end
a(OVER) = axes('units', 'normalized', 'Position', [0 .075 1 .925], 'color', 'none');
linkaxes(a, 'x');


%destroy_list = nan; % addlistener(f, 'beingdeleted') %#ok

reco_img = imagesc(1, 1, 1, 'Parent', a(RECO));
pos_line = line(nan, nan, 'Parent', a(RECO));
rast_img = imagesc(1, 1, 1, 'Parent', a(RAST));
mu_patch = patch(nan, nan, 'r', 'Parent', a(MU), 'EdgeColor', 'r');
eeg_line = line(nan, nan, 'Parent', a(EEG), 'Color', 'y');
rip_line = line(nan, nan, 'Parent', a(EEG), 'Color', 'w');
%replay_img = [];

xlims = [nan nan];
ylims = [nan nan]; %#ok
xpix = nan;
ypix = nan;

pan('xon');
zoom('xon');
addlistener(a(OVER), 'XLim', 'PostSet', @lims_changed);

%colormap(repmat(linspace(1,0, 10)',1,3))
colormap(get_colormap);

initialize();

%draw_dividers(a(RECO));

%% Initialize the figure
    function initialize(varargin)
        %set_colormap();
        set(a(OVER), 'XLim', [exp.(ep).epoch_times(1) exp.(ep).epoch_times(2)]);  
        set(a(RECO), 'YLim', [min(position) max(position)]);
        set_reconstruction();
    end
%% Destroy the figure
    function destroy_figure(varargin) %#ok
   
    
    end
%% Lims Changed
    function lims_changed(varargin)
        %disp('Limits Changed');
        get_lims();
        %disp('lims changed');
        [t_pos pos] = get_position();
        [mu_t mu_r] = get_multiunit_rate();

        [rast_data rast_x rast_y] = get_spike_raster();       

        set_position(t_pos, pos);
        set_multiunit_rate(mu_t, mu_r);
        %set_reconstruction();
        set_spike_raster(rast_x, rast_y, rast_data);
        set_replay();
        if eeg
            [e_dat, r_dat, t_dat] = get_eeg();
            set_eeg(e_dat, r_dat, t_dat);
        end      
        for i=1:length(args.dividers)
            line(xlims, [args.dividers(i) args.dividers(i)], 'Color', 'y', 'LineStyle', '--', 'Parent', a(RECO));
        end
        
            
    end   
    function get_lims()
        xlims = get(a(OVER), 'XLim');
        set(a(OVER), 'Units', 'Pixels');
        pix = get(a(OVER), 'Position');
        xpix = pix(3);
        ypix = pix(4);
        set(a(OVER), 'Units', 'Normalized');
    end    

%% Generators and setters

    %% Replay
    function set_replay()
        if ishandle(f_replay)  
            resp = 'Yes';
            if(xlims(2)-xlims(1))>100
                resp = questdlg('Reconstruct replay for large time segment?');
            end
            if strcmp(resp, 'Yes')
                %disp('Updating Replay') 
                [pdf tbins] = reconstruct(xlims(1), xlims(2), tc, clusters, 'tau', .02, 'percent_overlap', args.per_overlap);
                replay_pdf = combine_pdfs(pdf);
                %replay_pdf = pdf;
                
                x = linspace(xlims(1), xlims(2), size(replay_pdf, 2));
                y = linspace(min(position), max(position), size(replay_pdf,1));
                imagesc(x,y,replay_pdf, 'Parent', a_replay);
                set(a_replay, 'Xlim', xlims);
                %linkaxes([a a_replay], 'x');
                for i=1:length(args.dividers)
                    line(xlims, [args.dividers(i) args.dividers(i)], 'Color', 'y', 'LineStyle', '--', 'Parent', a_replay);
                end
            end    
        end
    end
    
    %% EEG
    function [e r t] = get_eeg()
       ind = find(xlims(1)<=eeg_ts & xlims(2)>=eeg_ts);
       if  numel(ind)>10000
           ind = ind(sort(randsample(numel(ind), 10000)));
       end
       e = eeg_dat(ind);
       r = rip_dat(ind);
       t = eeg_ts(ind);
    end
    function set_eeg(e, r, t)
        %ylims = get(a(MU), 'YLim');
        
        e = (e+(min(e)))/max(e);
        r = (r+(min(e)))/max(r);
        r = r+1;
        set(eeg_line, 'XData', t, 'YData', e);
        set(rip_line, 'XData', t, 'YData', r);  
        set(a(MU), 'YLim', [0 2]);
    end
    
    %% POSITION
    function [ts, pos] =  get_position()
        ind = xlims(1)<=position_ts & xlims(2)>=position_ts;
        ts = position_ts(ind);
        pos = position(ind);
    end
    function set_position(ts, pos)
        set(pos_line, 'XData', ts, 'YData', pos, 'Color', 'r');
    end

    %% MULTIUNIT
    function [ts rate] = get_multiunit_rate()
        ind = xlims(1)<=multiunit_ts & xlims(2)>=multiunit_ts;
        ts = multiunit_ts(ind);
        rate = multiunit(ind);
        ts = [ts(1), ts, ts(end)];
        rate = [0 rate 0];        
    end
    function set_multiunit_rate(ts, rate)
        set(mu_patch, 'XData', ts, 'YData', rate);
        set(a(MU), 'ylim', [min(rate) max(rate)]);
        
    end      
        
    %% RASTER
    function [c_dat, x_dat, y_dat] = get_spike_raster()
        x_dat = xlims(1):(xlims(2)-xlims(1))/xpix:xlims(2);
        x_dat = x_dat(1:end-1);
        tick_height = ceil(ypix/numel(clusters));
        y_dat = 1:numel(clusters); %1:tick_height:length(obj.clusters);

        c_dat = zeros(floor(ypix), floor(xpix));
        for i=1:numel(clusters)
            ind = clusters(i).time>= xlims(1) & clusters(i).time<=xlims(2);
            spikes = histc(clusters(i).time(ind), x_dat);
            if size(spikes,2)==size(c_dat,2)+1
                spikes = spikes(1:end-1);
            end

            spikes = (spikes>0);
            range = (i-1)*tick_height+1:i*tick_height;
            %new_dat = repmat(spikes, length(range),1);
           % disp(['c_dat size:', num2str(size(c_dat)), '  range:',
           % num2str(range), '  new_dat size: ',num2str(size(new_dat))]);
            c_dat(range,:) = repmat(spikes, length(range),1);
        end  
        
    end
    function set_spike_raster(x,y, img)
        set(rast_img, 'XData', x, 'YData', y, 'CData', img);
        set(a(RAST), 'YLim', [min(y), max(y)]);
    end

    %%RECONSTRUCTION
    function set_reconstruction()
        disp('setting pdf');
        s = size(main_pdf);
        x = linspace(xlims(1), xlims(2), s(1));
        y = linspace(min(position), max(position), s(2));
        set(reco_img, 'XData', x, 'YData', y, 'CData', main_pdf);
    end
    function do_run_recon()
        tc = get_tuning_curves(exp, ep);
        pdf = reconstruct(exp.(ep).epoch_times(1), exp.(ep).epoch_times(2), tc, clusters, 'percent_overlap', args.per_overlap);
        main_pdf = combine_pdfs(pdf);
        %main_pdf = pdf;
    end
   
    function pdf_out = combine_pdfs(pdf)
        split = size(pdf,1)/2;
        pdf_out(:,:,1) = pdf(1:split,:); 
        pdf_out(:,:,2) = zeros(size(pdf_out(:,:,1))); 
        pdf_out(:,:,3) = pdf(split+1:end,:);
    end
    
    %%  Dividers
    function draw_dividers(ax) %#ok
        for i=1:numel(dividers)
            line(xlims, [dividers(i) dividers(i)], 'Color', 'y', 'LineStyle', '--', 'Parent', ax);
        end
    end




%% UI Elements
%show_mub_chk = uicontrol('Style', 'Checkbox', 'String','MUB Times', 'Units', 'normalized',...
%    'Position', [.55, .013, .09, .025], 'backgroundcolor', [.8 .8 .8], ...
%   'CallBack', @toggle_mub_fn); %#ok

next_btn = uicontrol('Style', 'PushButton', 'String', '-->', 'units', 'normalized',...
    'position', [.9 .01 .05 .025], 'Callback', @next_fn);    %#ok
prev_btn = uicontrol('Style', 'PushButton', 'String', '<--', 'units', 'normalized',...
    'position', [.75  .01 .05 .025], 'Callback', @prev_fn);  %#ok
recon_btn = uicontrol('Style', 'Pushbutton', 'String', 'Reconstruct', 'Units' ,'Normalized',...
    'Position', [.8 .01 .1 .025], 'Callback', @plot_replay_recon); %#ok


%% UI Callbacks
    function next_fn(varargin)
        w = xlims(2) - xlims(1);
        s = xlims(1) + w;
        e = xlims(2) + w;
        dt = max(exp.(ep).epoch_times) - e;
        if dt<0
            e = e+dt;
            s = s+dt;
            disp('At end of Experiment, cant scroll anymore');
        end
        set(a(OVER), 'XLIm', [s e]);
    end
    function prev_fn(varargin)
        w = xlims(2) - xlims(1);
        s = xlims(1) - w;
        e = xlims(2) - w;
        
        dt = s - min(exp.(ep).epoch_times) ;
        if dt<0
            e = e-dt;
            s = s-dt;
            disp('At start of Experiment, cant scroll anymore');
        end
        set(a(OVER), 'XLim', [s e]);
    end
    function toggle_mub_fn(varargin) %#ok
%       lims = get_lims;
%       tstart = lims(1);
%       tend = lims(2);
        show_mub = ~show_mub;
        if show_mub          
            for i=1:length(muburst) %#ok
                burst = muburst(i,:);
                dx = burst(2)-burst(1);
                dy = .995;
                my_rectangle(burst(1), 0, dx, dy, ':','g',  a(MUB));
            end
        else
            cla(a(MUB));
           
        end       
    end
    function plot_replay_recon(varargin)
        if ~ishandle(f_replay)
            f_replay = figure('toolbar', 'none', 'Name', 'Replay', 'Position', [200 712 1200 388], 'NumberTitle', 'off' );
            a_replay = axes('Units', 'Normalized', 'Position', [0 0 1 1]);
            imagesc(1, 1, 1, 'Parent', a_replay);
            set(a_replay, 'DeleteFcn', @un_link_axes);
            colormap(get_colormap());
            set_replay()            
        end
    end
    function un_link_axes(varargin)
        disp('Unlinking axes');
        linkaxes([a a_replay], 'off');
        linkaxes(a, 'x');
    end
 end