function [f,reg] = plot_spike_phase_by_trode_pos(sdat,rat_conv_table,varargin)
% PLOT_SPIKE_PHASE_BY_TRODE_POS - Create a circ histograms and circ mean
% plots at anatomical coordinates
% 
% Creates a 2-d anatomical plane (y-axis is A/P, x-axis is M/L), and draws
% circular histograms and means for the phases of spikes fired by cells on
% tetrodes.  These plots are translated to the position of the source
% tetrode
%
% Additionally - computes a 2-d linear regression, phase vs. [x,y]
%
% Inputs: 
% -Mandatory:
% --sdat is a sdat-style cluster struct
% --rat_conv_table
% -Params (=> default)
% --n_phase_bin (=> 20) number of phase bins for circ hists
% --rose_plot_edge_size (=> 0.25) size of the roseplot, in anatomical units (mm)
% --draw_hists (=> true) toggle plot of circ hists (multi cells per trode? use false)
% --normalize_hists (=> true) toggle set the max phase-bin val to 1
% --make_hists_rates (=> true) toggle hist bin vals are rates
% --draw_means (=> true) toggle plot of phase prefs.
% --use_model (=> false) 
% ---- false: phase pref is most populated phase bin. modulation depth is
%             (max_height - min_height) / max_height
% ---- true:  fit a rate offsetted sin wave to the circ bins.  phase pref
%             is mu parameter of Rayleigh test.  
%             Modulation depth is cos fit (peak-trough)/peak

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('timewins',[]);
p.addParamValue('n_phase_bin',24); % every 5 minutes
p.addParamValue('little_plot_edge_size',0.25);
p.addParamValue('draw_hists',true,@islogical);
p.addParamValue('normalize_hists',true,@islogical);
p.addParamValue('draw_means',true,@islogical);
p.addParamValue('use_model',false,@islogical);
p.addParamValue('calc_phase',false,@islogical);
p.addParamValue('full_mod_color',[0 0 1]);
p.addParamValue('no_mod_color',[0.9 0.9 0.9]);
p.addParamValue('lfp_r',[]);
p.addParamValue('lfp_chan',[]);
p.addParamValue('LineWidth',1);
p.addParamValue('border_circle_r',1);
p.parse(varargin{:});
opt = p.Results;

n_trode = size(rat_conv_table.data,2);
ap = zeros(1,n_trode);
ml = zeros(1,n_trode);

reg = 1;

% figure out the trode positions and bounds for the figure
comp_row = find(strcmp(rat_conv_table.label,'comp'));
brain_ap_row = find(strcmp(rat_conv_table.label,'brain_ap'));
brain_ml_row = find(strcmp(rat_conv_table.label,'brain_ml'));
for n = 1:n_trode
    ap(n) = rat_conv_table.data{brain_ap_row,n};
    ml(n) = rat_conv_table.data{brain_ml_row,n};
end
ml_range = [min(ml), max(ml)] + [-0.5 0.5];  % add a .5mm border
ap_range = [min(ap), max(ap)] + [-0.5 0.5];
%ax = axes('Xlim',ml_range,'YLim',ap_range);

% set up the axes, if we will indeed be drawing
draw_something = any([opt.draw_means, opt.draw_hists]);
if(draw_something)
    ax = gca();
    f = gcf;
    set(ax,'XLim',ml_range);
    set(ax,'YLim',ap_range);
    axis equal; hold on;
end

if(~isempty(opt.border_circle_r))
    n_theta = 100;
    r = opt.border_circle_r.*ones(size(n_theta));
    r_half = opt.border_circle_r .* ones(size(n_theta)) ./ 2;
    theta = linspace(0,2*pi,n_theta);
    %theta = [theta, theta(1)];
    %r = [r,r(1)];
    %r_half = [r_half,r_half(1)];
    for n = 1:n_trode
        h(1) = plot(r.*cos(theta), r.*sin(theta),'-','Color',[0.5 0.5 0.5]);
        h(2) = plot(r_half .* cos(theta), r_half .* sin(theta),'.','MarkerEdgeColor',[0.75 0.75 0.75],'MarkerSize',1);
        h(3) = plot([-1 1].*r(1),[0 0].*r(1),'-','Color',[0.75 0.75 0.75]);
        h(4) = plot([0 0].*r(1),[-1 1].*r(1),'-','Color',[0.75 0.75 0.75]);
        h(5) = plot([-1 1].*r(1)./sqrt(2), [1 -1].*r(1)./sqrt(2),'-','Color',[0.75 0.75 0.75]);
        h(6) = plot([1 -1].*r(1)./sqrt(2), [1 -1].*r(1)./sqrt(2),'-','Color',[0.75 0.75 0.75]);
        t = hgtransform('Parent',ax);
        set(h,'Parent',t);
        set(gcf,'Renderer','painters');
        Txy = makehgtform('translate',[ml(n),ap(n),0]);
        Sxy = makehgtform('scale',[opt.little_plot_edge_size,opt.little_plot_edge_size,1]);
        set(t,'Matrix',Txy*Sxy);
    end
end

% iterate over all clusts in input drawing the phase info
n_clust = numel(sdat.clust);
%h_count = 0;

for n = 1:n_clust
    % get the phases
    ts_col = find(strcmp(sdat.clust{n}.featurenames, 'time'));
    phase_col = find(strcmp(sdat.clust{n}.featurenames,'theta_phase'));
    phases = sdat.clust{n}.data(:,phase_col);
    times = sdat.clust{n}.data(:,ts_col);
    
    if(~isempty(opt.timewin))
        [~,keep_bool] = gh_times_in_timewins(times,opt.timewin);
         phases = phases(keep_bool);
         times = times(keep_bool);
    end
    
    if(~isempty(opt.timewins))
        [~,keep_bool] = gh_times_in_timewins(times, opt.timewins);
        phases = phases(keep_bool);
        times = times(keep_bool);
    end
    
    phases(isnan(phases)) = [];
    % get thin clust's trode position
    trode_col = find(strcmp(rat_conv_table.data(comp_row,:), sdat.clust{n}.comp));
    clust_ap = ap(trode_col);
    clust_ml = ml(trode_col);
    
    if(opt.draw_hists)
        h = lfun_draw_hist(phases,[clust_ml,clust_ap],ax,opt);
    end
    
    if(opt.draw_means)
        h = lfun_draw_mean(phases,[clust_ml,clust_ap],ax,opt);
    end
    
end

xlim(ml_range);
ylim(ap_range);
%xlim([-10 200]);
%ylim([-20 200]);
%drawnow;

function h = lfun_draw_mean(phases,pos,ax,opt)
if(~isempty(phases))
    [phase_pref,mod_depth] = gh_cos_phase_model(phases);
else
    phase_pref = 0;
    mod_depth = 0;
end
this_color = mod_depth .* opt.full_mod_color + (1-mod_depth) .* opt.no_mod_color;
dot_spot = mod_depth .* [cos(phase_pref), sin(phase_pref)];
h = plot([0,dot_spot(1)],[0,dot_spot(2)],'-','Color',this_color,'LineWidth',opt.LineWidth);
hold on;
t = hgtransform('Parent',ax);
get(gcf,'Renderer')
set(h,'Parent',t);
set(gcf,'Renderer','painters');
Sxy = makehgtform('scale',[opt.little_plot_edge_size,opt.little_plot_edge_size,1]);
Txy = makehgtform('translate',([pos,0])./opt.little_plot_edge_size);
set(t,'Matrix',Sxy*Txy);
%drawnow;

function h = lfun_draw_hist(phase,pos,ax,opt)
h = 1;
