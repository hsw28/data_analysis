function  f = reconstruction_browser(exp, epoch, varargin)
%% Globals
if numel(varargin)==1
    eeg_ch = varargin{1};
else
    eeg_ch = 1;
end

tau = .25;
r_tau = .02;
ts = exp.(epoch).position.timestamp(1);
te = exp.(epoch).position.timestamp(end);
clusters = exp.(epoch).clusters;
pos = exp.(epoch).position;
%mua = exp.(epoch).multiunit.spike_times;
muburst = exp.(epoch).multiunit.burst_times;
tc1 = []; tc2=[];
alt_tc1 = []; alt_tc2=[];
show_mub = 0;
cmap = repmat(linspace(0,1,10)',1,3);


%% Setup AXES
f = figure('toolbar', 'figure', 'Name', ['Reconstruction Browser: ', epoch, ' '  exp.session_dir],...
    'Position', [100 100 1200 800], 'NumberTitle', 'off' );
RECO1 = 1; RECO2= 2; RAST=3; MULTI=4; EEG=5; MUB=6; RIP=7;
a(RECO1) = axes('Units', 'Normalized',   'Position', [0 .75  1 .25]);
a(RECO2) = axes('Units', 'Normalized',   'Position', [0 .5   1 .25]);
a(RAST) = axes('Units', 'Normalized',    'Position', [0 .3   1 .2 ]);
a(MULTI) = axes('Units', 'Normalized',   'Position', [0 .2   1 .1]);
a(EEG) = axes('Units', 'Normalized',     'Position', [0 .13   1 .07]);
a(RIP) = axes('Units', 'Normalized',     'Position', [0 .06   1 .07]);
a(MUB) = axes('Units', 'Normalized',     'Position', [0 .06   1 .94]);


 %% Gui control (CHECK BOX, BUTTONS, ETC)
show_mub_chk = uicontrol('Style', 'Checkbox', 'String','MUB Times', 'Units', 'normalized',...
    'Position', [.55, .013, .09, .025], 'backgroundcolor', [.8 .8 .8], ...
   'CallBack', @toggle_mub_fn, 'Value', show_mub); %#ok

next_btn = uicontrol('Style', 'PushButton', 'String', '-->', 'units', 'normalized',...
    'position', [.9 .01 .05 .025], 'Callback', @next_fn);    %#ok
prev_btn = uicontrol('Style', 'PushButton', 'String', '<--', 'units', 'normalized',...
    'position', [.75  .01 .05 .025], 'Callback', @prev_fn);  %#ok
recon_btn = uicontrol('Style', 'Pushbutton', 'String', 'Reconstruct', 'Units' ,'Normalized',...
    'Position', [.8 .01 .1 .025], 'Callback', @calc_replay); %#ok

tc_epoch_chk=uicontrol('Style', 'CheckBox', 'units', 'normalized', 'String', 'Use Alternate TCs:', ...
    'Position', [.1  .01 .125 .025], 'BackgroundColor', [.8 .8 .8], 'Callback', @tc_epoch_fn);
tc_epoch_npt=uicontrol('Style', 'Edit', 'Units', 'normalized',...
    'Position', [.22 .01 .05 .025]);
    

%% Spike Raster Browser
srb = spike_raster_browser(clusters, a(RAST));  %#ok

%% Reconstruction Browser
disp('Calculating PDF for entire epoch');
[pos_pdf1 pos_pdf2] = do_reconstruction(ts, te, tau);

im(1) = imagesc(pos_pdf1, 'Parent', a(RECO1));
im(2) = imagesc(pos_pdf2, 'Parent', a(RECO2));
set(im, 'XData', [ts te]);
set(a(RECO1), 'YDir', 'normal');
set(a(RECO2), 'YDir', 'normal');
set(a(RECO1), 'Color', [0 0 0 ]);
set(a(RECO2), 'Color', [0 0 0 ]);
set(a(RECO1), 'XLim', [ts te]);
set(a(RECO2), 'XLim', [ts te]);

%% Multi-Unit Browser and other Multiunit related things
set(a(MUB), 'color', 'none');
set(a(MUB), 'XTick', []);
set(a(MUB), 'YTick', []);

mub = patch_browser(exp.(epoch).multiunit.rate, exp.(epoch).multiunit.timestamps, a(MULTI)); %#ok
set(mub, 'FaceColor', [.7 .7 .7], 'EdgeColor', [.7 .7 .7]);
x = exp.(epoch).epoch_times;
y1 = repmat(exp.(epoch).multiunit.low_threshold, 2,1);
y2 = repmat(exp.(epoch).multiunit.high_threshold, 2,1);
hold(a(MULTI), 'on');
line(x,y1,'color','y', 'linestyle', '--','Parent', a(MULTI));
line(x,y2,'color','y', 'linestyle', '--','Parent', a(MULTI));
hold(a(MULTI), 'off');

%% EEG Browser
disp('Filtering EEG for Ripples');

filt = getfilter(exp.(epoch).eeg(eeg_ch).fs, 'ripple', 'win');
%col = 'y';
wb(1) = line_browser(filtfilt(filt, 1, exp.(epoch).eeg(eeg_ch).data), exp.(epoch).eeg_ts, a(RIP));
wb(2) = line_browser(exp.(epoch).eeg(eeg_ch).data, exp.(epoch).eeg_ts, a(EEG));
set(a([RIP EEG]), 'Color','k');
set(wb, 'Color', 'y');

%% Plot Position Overlay
hold(a(RECO1), 'on');
hold(a(RECO2), 'on');
plot(pos.timestamp, pos.lin_pos*10, 'r', 'Parent', a(RECO1));
plot(pos.timestamp, pos.lin_pos*10, 'r', 'Parent', a(RECO2));
hold(a(RECO1), 'off');
hold(a(RECO1), 'off');

%% Last minute GUI Stuf
colormap(cmap);
set(a(MULTI), 'color', [0 0 0 ]);
%cmap2 = srb.color_map
%set(gcf, 'Position', [100 100 1200 800]);
linkaxes(a,'x');
%linkaxes(a([MULTI, MTRIG]), 'y');
set(a(1:6), 'XTick', [], 'YTick', []);
set(a(MUB),'YLim',[0 1]);
pan('xon');
zoom('xon');



%% Reconstruction Functions
    function [pdf1 pdf2] =  do_reconstruction(tstart, tend, tau)
       
        tc1 = nan(length(clusters(1).tc1), length(clusters));
        tc2 = nan(length(clusters(1).tc2), length(clusters));
        for i=1:length(clusters)
            
            tc1(:,i) = clusters(i).tc1(:);
            tc2(:,i) = clusters(i).tc2(:);
            
        end
        
        
        
        t_bins = tstart:tau:tend;
        spike_counts= zeros(length(clusters), length(t_bins));
        for i=1:length(clusters)
            spike_counts(i,:) = histc(clusters(i).time, t_bins);
        end
        %[size(tc1) 0 0 size(spike_count)] %debuging outpu
       
        
        max_size = 5000;
        size(spike_counts,2)
        if size(spike_counts,2)>max_size

            n_section = ceil(size(spike_counts,2)/max_size);
            disp(['Experiment too to compute PDF long cutting into ', num2str(n_section), ' sections']);
            
            for i=0:n_section-1
               
                istart = i*max_size+1;
                iend = min([(i+1)*max_size, size(spike_counts,2)]);
                pdf1_short = parameter_estimation_simple(tau, tc1, spike_counts(:,istart:iend));

                pdf2_short = parameter_estimation_simple(tau, tc2, spike_counts(:,istart:iend));                
               % [i istart iend]
                switch i
                    case 0
                        pdf1 = pdf1_short;
                        pdf2 = pdf1_short;
                    otherwise
                        pdf1 = [pdf1 pdf1_short];
                        pdf2 = [pdf2 pdf2_short];
                end
            end
        else
            pdf1 = parameter_estimation_simple(tau, tc1, spike_counts);
            pdf2 = parameter_estimation_simple(tau, tc2, spike_counts);
        end

    end

%% Replay Functinos
    function lims = get_lims()
        lims = get(a(1), 'XLim');
    end
    function set_lims(lims)
        set(a(1), 'Xlim', lims);
    end

    function calc_replay(varargin)
        lims = get_lims();
        
        t_bins = lims(1):r_tau:lims(2);
        spike_count= zeros(length(clusters), length(t_bins));
        for i=1:length(clusters)
            spike_count(i,:) = histc(clusters(i).time, t_bins);
        end
        %[size(tc) 0 0 size(spike_count)] %debuging output
        switch get(tc_epoch_chk, 'Value')
            case 0
                [size(tc1') size(spike_count)];
                replay_pdf1 = parameter_estimation_simple(r_tau, tc1, spike_count);
                replay_pdf2 = parameter_estimation_simple(r_tau, tc2, spike_count);
            case 1
                [size(alt_tc1') size(spike_count)];
                replay_pdf1 = parameter_estimation_simple(r_tau, alt_tc1', spike_count);
                replay_pdf2 = parameter_estimation_simple(r_tau, alt_tc2', spike_count);
        end
        plot_replay(replay_pdf1, replay_pdf2, lims(1), lims(2));
        
    end

    function plot_replay(pdf1, pdf2, tstart, tend)
       
        p = get(gcf, 'Position');
               
        f_replay = figure('Name',...
            ['Replay Reconstruction   ', num2str(tstart), ':', num2str(tend)], ...
            'NumberTitle', 'off', 'toolbar', 'none');
        set(f_replay, 'Position', [p(1) 400, p(3), 370]);
        
        ar(1) = axes('Parent' , f_replay, 'Units', 'normalized',...
            'Position', [0 .5 1 .5], 'Color', [0 0 0 ]);
        ar(2) = axes('Parent' , f_replay, 'Units', 'normalized',...
            'Position', [0 0 1 .5], 'Color', [0 0 0 ]);
        
        pdf1 = smoothn(pdf1, 1, 'kernel', 'box');
        pdf2 = smoothn(pdf2, 1, 'kernel', 'box'); 
        im(1) = imagesc(pdf1, 'Parent', ar(1));   
        im(2) = imagesc(pdf2, 'Parent', ar(2));   
        
        set(im, 'XData', [tstart tend]);
        colormap(cmap);
                
        zoom('xon', gca);
        
        
        ar(3) = axes('Parent', f_replay', 'units', 'normalized',...
            'Position', [0 0 1 1]);
        line([tstart/2 tend*2], [.5 .5], 'Color', 'w', 'Parent', ar(3));

        line([tstart/2 tend*2], [.5*(4.5/8.7) .5*(4.5/8.7)], ...
            'Color', 'y', 'LineStyle', '--', 'Parent', ar(3));
        
        line([tstart/2 tend*2], [.5+.5*(4.5/8.7) .5+.5*(4.5/8.7)], ...
            'Color', 'y', 'LineStyle', '--', 'Parent', ar(3));
 
        set(ar(3), 'Color', 'none', 'YLim', [0 1])
                
        if(show_mub)
           
            ind = find(muburst(:,1)>=tstart,1,'first'):find(muburst(:,2)<=tend, 1, 'last');
            
            for i=ind
                burst = muburst(i,:);
                dx = burst(2)-burst(1);
                dy = .995;
                my_rectangle(burst(1), 0, dx, dy, ':','y',  ar(3));
            end
        end
        set(ar, 'YTick', [], 'XLim', [tstart tend], 'YDir', 'normal');
        linkaxes(ar, 'x');

    end


%%  CallBack Functions        

    function next_fn(varargin)
        lims = get_lims();
        s = lims(2);
        e = lims(2)+(lims(2)-lims(1));
        set_lims([s e])
    end

    function prev_fn(varargin)
        lims = get(a(1), 'XLim');
        s = lims(1)-(lims(2)-lims(1));
        e = lims(1);
        set_lims([s e])
    end

    function toggle_mub_fn(varargin)
%       lims = get_lims;
%       tstart = lims(1);
%       tend = lims(2);
        show_mub = ~show_mub;
        if show_mub          
            for i=1:length(muburst)
                burst = muburst(i,:);
                dx = burst(2)-burst(1);
                dy = .995;
                my_rectangle(burst(1), 0, dx, dy, ':','g',  a(MUB));
            end
        else
            cla(a(MUB));
        end       
    end
    function tc_epoch_fn(varargin)
        if get(tc_epoch_chk,'Value');
            for i=1:length(clusters)
                field1 = [get(tc_epoch_npt, 'string'), '_tc1'];
                field2 = [get(tc_epoch_npt, 'string'), '_tc2'];
                alt_tc1(i,:) = clusters(i).(field1);
                alt_tc2(i,:) = clusters(i).(field2);
            end
        end
    end
end
