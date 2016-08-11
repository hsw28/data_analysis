function [fig plot_pos_info] = gh_plot_pos(pos_info,varargin)

p = inputParser();
p.addParamValue('plot_pos',true,@islogical);
p.addParamValue('plot_vel',false,@islogical);
p.parse(varargin{:});

set(gcf,'NextPlot','add');

plot_pos_info = [];

plot_pos = p.Results.plot_pos;
plot_vel = p.Results.plot_vel;
n_plots = plot_pos + plot_vel;

if(n_plots == 2) 
    subplot(2,1,1);
end

if(plot_pos)
    min_pos = min(pos_info.lin_filt.data(:,1));
    range_pos = max(pos_info.lin_filt.data(:,1)) - min_pos;
    n_outbound = size(pos_info.out_run_bouts,1);
    n_inbound = size(pos_info.in_run_bouts,1);
    for m = 1:n_outbound
        m
        timerange = [pos_info.out_run_bouts(m,1),pos_info.out_run_bouts(m,2)];
        position = [timerange(1),min_pos,diff(timerange),range_pos];
        rectangle('Position',position,'LineStyle','none','FaceColor',[0.5 0.5 1]);
    end
    for m = 1:n_inbound
        m
        timerange = [pos_info.in_run_bouts(m,1),pos_info.in_run_bouts(m,2)];
        position = [timerange(1), min_pos, diff(timerange), range_pos];
        rectangle('Position',position,'LineStyle','none','FaceColor',[0.5 1 0.5]);
    end
    hold on;
    plot(conttimestamp(pos_info.lin_filt),pos_info.lin_filt.data(:,1),'k');
end

if(n_plots == 2)
   subplot(2,1,2);
end

if(plot_vel)
    plot(conttimestamp(pos_info.lin_vel_cdat),pos_info.lin_vel_cdat.data(:,1),'k');
end