function spectral_browser(exp)

f = figure('Toolbar', 'figure');
set(f, 'Position', [320 280 1000 750]);
a(1) = axes(); % eeg axes;
a(2) = axes(); % spectrum axes;

method_list_str = {'Multi-Taper', 'Welch', 'Periodogram'};
kernel_list_str = {'Bartlett', 'Bartlett-Hanning', 'Blackman', 'Blackman-Harris',...
    'Bohman', 'Chebyshev', 'Flat Top', 'Gaussian', 'Hamming', 'Hann', 'Kaiser',...
    'Nuttall', 'Parzen', 'Rectangular', 'Triangular', 'Tukey'};
freq_band = {'All Freqs', '0-40 Hz', '75-250 Hz'};

set(a(1), 'Position', [.025 .6, .81 .38], 'Box', 'on');  
set(a(2), 'Position', [.025 .05 .81 .48], 'Box', 'on', 'XTick', [], 'YTick', []);

epoch_sel_str = uicontrol('Style', 'Text', 'String', 'Epoch',...
    'Units', 'normalized', 'Position', [.86 .9 .13 .08],...
    'BackgroundColor', [.8 .8 .8]); %#ok

%%%%%%%%%%% Spectrogram Controls Elements
bin_width_st = uicontrol('Style', 'Text', 'String', 'BW(ms)', 'Units', 'Normalized',...
    'Position', [.01 .54 .0725 .025], 'BackgroundColor', [.8 .8 .8]);

bin_width_ui = uicontrol('Style', 'Edit', 'BackgroundColor', [1 1 1], 'Units', 'Normalized',...
    'Position', [.0725 .54 .04 .03], 'String', '100');

overlap_st = uicontrol('Style', 'Text', 'String', '%Over', 'Units', 'Normalized', ...
    'Position', [.115 .54 .045 .025 ], 'BackgroundColor', [.8 .8 .8]);

overlap_ui = uicontrol('Style', 'Edit', 'BackgroundColor', [1 1 1], 'Units', 'Normalized',...
    'Position', [.16 .54 .04 .03] , 'String', '25');

freq_band_ui = uicontrol('Style', 'popupmenu', 'Units', 'Normalized', ...
    'Position', [.21 .54 .08 .03], 'String', freq_band);

%%%%%%%%%% Spectrogram Button
spectro_ui = uicontrol('Style', 'Pushbutton', 'Units', 'Normalized',...
    'Position', [.295 .54 .1, .03], 'String', 'Spectrogram',...
    'Callback', @spectro_fcn);

%%%%%%%%%% Real Time elements
real_time_chk = uicontrol('Style', 'Checkbox', 'backgroundcolor', [.8 .8 .8], 'Units', 'Normalized',...
    'Position', [.40, .54, .08, .03], 'String', 'RealTime');

%%%%%%%%%%% Spectrum Button
spectrum_ui = uicontrol('Style', 'Pushbutton', 'Units', 'Normalized',...
    'Position', [.48 .54 .1, .03], 'String', 'Spectrum', ...
    'CallBack', @spectrum_fcn);

%%%%%%%%%% Method Drop Down Boxes
method_list_ui = uicontrol('Style', 'popupmenu', 'Units', 'Normalized', ...
    'Position', [.60 .539 .115 .03], 'String', method_list_str, ...
    'Callback', @method_list_ui_fcn);

kernel_list_ui = uicontrol('Style', 'popupmenu', 'Units', 'Normalized', ...
    'Position', [.72 .539 .115 .03], 'String', kernel_list_str, ...
    'Callback', @method_list_ui_fcn);

%%%%%%%%%% Epoch and Ripple List elements
epoch_sel_ui = uicontrol('Style', 'popupmenu', 'String', exp.epochs,...
    'Units', 'normalized', 'Position', [.86 .85 .13 .1], ...
    'Callback', @epoch_sel_ui_fcn);

ripple_list_ui = uicontrol('Style', 'ListBox', 'Units', 'Normalized', ...
    'Position', [.86, .05, .13, .85], 'Callback', @ripple_list_fcn);

%%%%%%%%%% Listener
l = addlistener(a(1), 'XLim', 'PostSet', @axes_panned);

% SETUP Globals
epoch = exp.epochs{1};
wb = [];
ripple_list = [];
method = [];
kernel = [];
eeg_chan = 4;
pc = 0; % pan count;
% End Globals

% Setup Initial Conditions
epoch_sel_ui_fcn();
method_list_ui_fcn();
pan('xon');
zoom('xon');

    function set_epoch()
        wb = line_browser(exp.(epoch).eeg(1).data, exp.(epoch).eeg_ts, a(1));
       % hold on;
       % eb = line_browser(repmat(0, size(exp.(epoch).multiunit.burst_times(1,:))), exp.(epoch).multiunit.burst_times(:,1), a(1));
        
       % hold off;
        
        ripple_list = exp.(epoch).multiunit.burst_times(:,1);
        update_ripple_list_ui;
    end
        
    function update_ripple_list_ui()
        list = {};

        for i=1:numel(ripple_list)
            list{i} = ripple_list(i);
        end;
        %list = cellstr(num2str(ripple_list','%g'));
        set(ripple_list_ui,'String', list);     
        list(1)
    end

    function epoch_sel_ui_fcn(varargin)
        epoch = exp.epochs{get(epoch_sel_ui, 'Value')};
        set_epoch();
    end

    function method_list_ui_fcn(varargin)
        method = method_list_str{get(method_list_ui, 'Value')};
        switch method
            case 'Multi-Taper'
                set(kernel_list_ui, 'Enable', 'off');
            otherwise
                set(kernel_list_ui, 'Enable', 'on');
                kernel = kernel_list_str{get(kernel_list_ui, 'Value')};
        end
        if get(real_time_chk, 'Value')
            spectrum_fcn();
        end
    end

    function axes_panned(varargin)
        if get(real_time_chk,'Value')
            switch pc
                case 0
                    spectrum_fcn();
                    pc = pc+1;
                case 10
                    pc = 0;
                otherwise
                    pc = pc+1;
            end
        end
    end
    function ripple_list_fcn(varargin)
        set(real_time_chk, 'Value',1);
        lims = get(a(1), 'XLim');
        dt = (lims(2)-lims(1))/2;
        rt = ripple_list(get(ripple_list_ui, 'Value'));
        pc = 0;
        set(a(1), 'XLim', [rt-dt, rt+dt]);        
    end

    function spectrum_fcn(varargin)
        [d t f] = get_data();
        if length(d)>15000
            answer = questdlg('More than 15000 pts are you sure?');
            if ~strcmp(answer,'Yes')
                return
            end
        end
       
        p = compute_spectrum(d, f, method);
        data = getdata(p, isdensity(p),plotindb(p));
        linkaxes(a,'off');
        plot(p.frequencies,data,'Parent', a(2));
        set(a(1), 'YLim', [-250 250]);
        set(a(2), 'XLim', [0 300]);
        set(a(2), 'XGrid','on', 'YGrid','on');
        set(a(2), 'XMinorGrid', 'on');
        ylabel(a(2),'dB');
        xlabel(a(2),'Frequency');
    end

    function spectro_fcn(varargin)
        set(real_time_chk,'Value', 0);
        [d t fs] = get_data();
        bw = str2double(get(bin_width_ui, 'String'))/1000; %ms to seconds
        per_over = str2double(get(overlap_ui, 'String'))/100; %percent to unit
        
        win_len = fs*bw;
        
        increment = floor(win_len*(1-per_over));
        if increment==0
            increment = 1;
        end
        %disp(['Increment:' num2str(increment)]);
        cur_ind = 1;
        n_points = length(d);
        spec = [];
        i=0;
        h = waitbar(0, 'Computing spectrogram');
        
        while cur_ind + win_len < n_points
            ind = (cur_ind:cur_ind+win_len-1)';
            %[size(ind) max(ind) size(d) d(4000)]
            p = compute_spectrum(d(ind), fs, method);
            spec(:,end+1) = getdata(p, isdensity(p), plotindb(p));
            cur_ind = cur_ind + increment;
            i = i+1;
            waitbar(i/(n_points/increment), h);
        end
        waitbar(1,h);
        delete(h);
        
        f = p.Frequencies;
        t_spec = (1:size(spec,2))*((t(end)-t(1))/size(spec,2)) + t(1);
        imagesc(t_spec,f,spec, 'Parent', a(2));
        set(a(2), 'YDir', 'Normal')
        set(a(1), 'YLim', [-250 250]);
        linkaxes(a,'x')
        
        
    end

    function [data ts fs] = get_data()
        lims = get(a(1), 'XLim');
        [data ts] = exp.(epoch).eeg(eeg_chan).load_window(lims);
        %ts = exp.(epoch).eeg_ts(exp.(epoch).eeg_ts>=lims(1) & exp.(epoch).eeg_ts<=lims(2));
        fs = 1/mean(gradient(ts));
    end
    
    function p = compute_spectrum(data, fs, method)
        switch method
            case 'Multi-Taper'
                h = spectrum.mtm;
            case 'Welch'
                h = spectrum.welch;
                h.WindowName = kernel;
            case 'Periodogram'
                h = spectrum.periodogram;
                h.WindowName = kernel;
        end
        p = psd(h, data, 'Fs', fs);
    end
end










