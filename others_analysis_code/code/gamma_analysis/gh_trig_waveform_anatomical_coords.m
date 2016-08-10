function [ax opt] = gh_trig_waveform_anatomical_coords(eeg_r,rat_conv_table,varargin)

p = inputParser;
p.addParamValue('trig_times',[]);
p.addParamValue('data_field','raw');
p.addParamValue('find_peak_opts',[]);
p.addParamValue('trig_win_x',[-0.1 0.1]);
p.addParamValue('trig_win_y',[-0.4 0.4]);
p.addParamValue('win_size',[0.25 0.25]);
p.addParamValue('chan_ind',1:size(eeg_r.raw.data,2));
p.addParamValue('draw_traces',true);
p.addParamValue('draw_mean',false);
p.addParamValue('draw_std',false);
p.addParamValue('axes_color',[0.2 0.2 0.2]);
p.addParamValue('trig_waveform_opts',[]);
p.addParamValue('draw_label',true);
p.addParamValue('trace_lightness',1/4);
p.parse(varargin{:});
opt = p.Results;
if(~isempty(opt.trig_waveform_opts))
    opt = opt.trig_waveform_opts;
end

if(~isempty(opt.find_peak_opts))
    opt.trig_times = [trig_times, gh_find_peaks(eeg,opt.find_peak_opts{:})];
end

ts = conttimestamp(eeg_r.raw);
dt = mean(diff(ts));

ax = axes('XLim',[0 6],'YLim',[-6 0]);
view(2); 
%axis equal; 
hold on;



h_group = cell(1,length(opt.chan_ind));

for n = opt.chan_ind
    
    if(iscell(opt.trig_times))
        this_trig_times = opt.trig_times{n};
    else
        this_trig_times = opt.trig_times;
    end
    
    trig_relative_ind = round(opt.trig_win_x(1)/dt):round(opt.trig_win_x(2)/dt);
    n_rel_ind = length(trig_relative_ind);
    trig_zero_inds = lfun_time_to_ind(this_trig_times,ts);
    trig_ind = repmat(trig_zero_inds',1,n_rel_ind) + repmat(trig_relative_ind,length(this_trig_times),1);
    trig_ts = linspace(opt.trig_win_x(1),opt.trig_win_x(2),n_rel_ind);
    
    chan_data = eeg_r.(opt.data_field).data(:,n);
    chan_data = chan_data';
    trig_data = chan_data(trig_ind);
    %gamma_data = eeg_r.gammaenv.data(:,n);
    %gamma_data = gamma_data';
    %trig_gamma = gamma_data(trig_ind);
    
    t(n) = hgtransform('Parent',ax);
    
    this_h = [];
    this_h(end+1) = plot(opt.trig_win_x,[0 0],'k-','Color',opt.axes_color,'Parent',t(n)); % the x axis
    this_h(end+1) = plot([0 0], opt.trig_win_y,'k-','Color',opt.axes_color,'Parent',t(n)); % the y axis
    if(opt.draw_traces)
        n_trace = length(this_trig_times);
        for m = 1:n_trace
            this_h(end+1) = plot(trig_ts,trig_data(m,:),'-','Color',...
                [mod(3*m/n_trace,1).^opt.trace_lightness,mod(2*m/n_trace,1).^opt.trace_lightness,(m/n_trace).^opt.trace_lightness],...
                'Parent',t(n)); % individual traces
        end
    end
    if(opt.draw_mean)
        this_h(end+1) = plot(trig_ts,mean(trig_data,1),'LineWidth',4,'Parent',t(n),'Color',[0 0 0]);
    end
    this_h(end+1) = plot(trig_ts,mean(trig_data,1),'Linewidth',4,'Color',[0 0 0], 'Parent', t(n));
        %set(this_h,'Parent',t(n));
    
    %set(gcf,'Renderer','opengl');
    xscale = opt.win_size(1) / diff(opt.trig_win_x);
    yscale = opt.win_size(2) / diff(opt.trig_win_y);
    xtranslate = trode_conv(eeg_r.raw.chanlabels{n},'comp','brain_ml',rat_conv_table);
    ytranslate = trode_conv(eeg_r.raw.chanlabels{n},'comp','brain_ap',rat_conv_table);
    STxy = makehgtform('scale',[xscale,yscale,1],'translate',[xtranslate/xscale,ytranslate/yscale,1]);
    set(t(n),'Matrix',STxy);
    drawnow;
    
    if(opt.draw_label)
        this_h(end+1) = text(xtranslate+0.05,ytranslate-opt.win_size(2)/2,eeg_r.raw.chanlabels{n});
    end
   %pause(0.25); 
end

function inds = lfun_time_to_ind(times, ts)
all_ind = 1:length(ts);
inds = round(interp1(ts,all_ind,times,'linear','extrap'));