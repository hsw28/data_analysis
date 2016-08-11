function topo_map_demo(varargin) 
% TOPO_MAP_DEMO ()
%
% Makes a few avi animations demonstrating the phase coding of place cells
% and extends this to the traveling-wave case
% params: mov_name, fps, time_dilation, t_len; xlim,ylim,zlim; 
%         wavelength, wave_freq, wave_amplitude, wave_direction
%         phase_range, phase_color_range, out_of_phase_color
%         sibiculum_line, ca3_line, ca1_label, ca3_label, subiculum_label,
%         track_pos_height

m = morpheus_rat_conv_table;
ap_ind = find(strcmp(m.label,'brain_ap'),1);
ml_ind = find(strcmp(m.label,'brain_ml'),1);
default_trodexy = [cell2mat(m.data(ml_ind,:));cell2mat(m.data(ap_ind,:))]';
p = inputParser();

p.addParamValue('position',[500,0,700,700]);
p.addParamValue('bkgnd_color',[0.2 0.2 0.2]);
p.addParamValue('mov_name',[]);
p.addParamValue('fps',24);
p.addParamValue('time_dilation',30);

p.addParamValue('xlim',[0 7]);
p.addParamValue('ylim',[-6.5 -1.25]);
p.addParamValue('zlim',[0, 4]);
p.addParamValue('title',false);

p.addParamValue('trode_xy', default_trodexy);

p.addParamValue('subiculum_line',[1.2 4.5; -3.4 -5.9]);
p.addParamValue('ca3_line',[2.35, 5.6; -2 -4.45]);
p.addParamValue('ca1_label',[1, -2, 0]);
p.addParamValue('ca3_label',[5, -2.5, 0]);
p.addParamValue('subiculum_label',[1.5, -5, 0]);

p.addParamValue('t_len',0.93 + 1);

p.addParamValue('wavelength',10);
p.addParamValue('wave_freq',8);
p.addParamValue('wave_amplitude',1);
p.addParamValue('wave_direction',0);
p.addParamValue('wave_z_offset',3);

p.addParamValue('phase_range',[0,pi/2]);
p.addParamValue('phase_color_range', [0, 0, 1 ; 1, 0, 0]);
p.addParamValue('out_of_phase_color',[0.1 0.1 0.1]);
p.addParamValue('track_pos_height',0);

p.addParamValue('extra_lines',false);
p.addParamValue('dot_size', 30);

p.addParamValue('pan_down_t',[1,5]);
p.addParamValue('pan_down_extent',45);
p.addParamValue('initial_pan_down',0);
p.addParamValue('spin_speed',0);

p.addParamValue('color_on_t',[20,30]);

p.parse(varargin{:});
opt = p.Results;

f = figure;
set(gcf,'Position',opt.position);

mov_b = ~isempty(opt.mov_name);
if(mov_b)
    writerObj = VideoWriter(opt.mov_name);
    writerObj.FrameRate = opt.fps;
    open(writerObj);
end

[xs,ys] = lfun_dashed_line(opt.ca3_line);
a = plot(xs,ys,'k');
set(gcf,'Renderer','zbuffer');
set(gca,'nextplot','replacechildren');
if(~opt.extra_lines)
set(gca,'Box','off');
set(gca,'XTickLabel',{});
set(gca,'YTickLabel',{});
set(gca,'ZTickLabel',{});
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);
set(gca,'XColor',opt.bkgnd_color);
set(gca,'YColor',opt.bkgnd_color);
set(gca,'ZColor',opt.bkgnd_color);
set(gcf,'Color', opt.bkgnd_color);
set(gca,'Color', opt.bkgnd_color);
end
axis equal;
xlim(opt.xlim);
ylim(opt.ylim);
zlim(opt.zlim);
caxis([1 101]);
camorbit( 0, -1 * opt.initial_pan_down );
hold on;
[xs,ys] = lfun_dashed_line(opt.subiculum_line);
plot(gca,xs,ys,'k');
text(opt.ca1_label(1), opt.ca1_label(2), opt.ca1_label(3),'CA1','FontSize',24,'HorizontalAlignment','center','FontName','Times','Color',[0.8,0.8,0.8]);
text(opt.ca3_label(1), opt.ca3_label(2), opt.ca3_label(3),'CA3','FontSize',18,'HorizontalAlignment','center','FontName','Times','Color',[0.8,0.8,0.8]);
text(opt.subiculum_label(1),opt.subiculum_label(2), opt.subiculum_label(3), 'Subiculum','FontSize',18,'HorizontalAlignment','center','FontName','Times','Color',[0.8,0.8,0.8]);

my_colormap = (linspace(1,0,100)') * opt.phase_color_range(1,:) ...
       +      (linspace(0,1,100)') * opt.phase_color_range(2,:);
   
my_colormap = [opt.out_of_phase_color; my_colormap];
opt.my_colormap = my_colormap;

colormap(my_colormap);
   
n_trodes = size(opt.trode_xy,1);

g = scatter3(opt.trode_xy(:,1), opt.trode_xy(:,2), opt.track_pos_height.*ones(n_trodes,1), ...
    opt.dot_size, ones(n_trodes,1), 'filled');

colormap(my_colormap);

p = scatter3(opt.trode_xy(:,1), opt.trode_xy(:,2), opt.wave_z_offset * ones(n_trodes,1), ...
    opt.dot_size + 10, [0.5 0.5 0.5], 'filled');

colormap(my_colormap);


ts = linspace(0, opt.t_len, (opt.fps * opt.time_dilation * opt.t_len));

viewer_ts = ts .* opt.time_dilation;
viewer_dt = viewer_ts(2) - viewer_ts(1);

model_params = [opt.wave_freq, opt.wavelength, opt.wave_direction, 0, opt.wave_amplitude];

for n = 1:numel(ts)
    
x = [ ts(n)*ones(n_trodes,1), opt.trode_xy ];
phases = plane_wave_model(model_params,x,'yhat_form','phase');
phases = mod(phases,(2*pi));
set(p,'ZData',cos(phases).*opt.wave_amplitude  + opt.wave_z_offset);
c = lfun_phase_to_color(phases,opt) .* my_sigmoid(viewer_ts(n), opt.color_on_t(1),opt.color_on_t(2));
set(g,'CData',c);

dtheta = lfun_d_sig( viewer_ts(n), opt.pan_down_t(1), opt.pan_down_t(2), viewer_dt) .* opt.pan_down_extent;
dphi = my_sigmoid(viewer_ts(n), opt.pan_down_t(2), opt.pan_down_t(2)+0.5)./3 .* opt.spin_speed;
camorbit( -1*dphi, -1*dtheta );
if(opt.title)
title(['Brain:', num2str(ts(n)), '  View: ', num2str(viewer_ts(n))]);
end
set(gcf,'Position',opt.position);
if(mov_b)
    frame = getframe(gcf);
    writeVideo(writerObj,frame);
else
    pause(1 / opt.fps);
end

end

if(mov_b)
    close(writerObj);
end

function cl = lfun_phase_to_color(phase,opt)
c = ones(size(phase));
color_ind = phase >= opt.phase_range(1) & phase <= opt.phase_range(2);
c(color_ind) = ...
    (phase(color_ind) - opt.phase_range(1)) / diff(opt.phase_range) * 100 + 1;
cl = opt.my_colormap(floor(c),:);

function [xs,ys] = lfun_dashed_line(coords)
n_dashes = 10;
n_points = n_dashes * 2;
p_x = linspace(coords(1,1), coords(1,2), n_points);
p_y = linspace(coords(2,1), coords(2,2), n_points);
start_xs = p_x((0:(n_dashes-1)) * 2 + 1);
end_xs   = p_x((0:(n_dashes-1)) * 2 + 2);
start_ys = p_y((0:(n_dashes-1)) * 2 + 1);
end_ys   = p_y((0:(n_dashes-1)) * 2 + 2);

xs = NaN .* ones(1,n_dashes*3);
ys = NaN .* ones(1,n_dashes*3);

inds1 = (0:(n_dashes-1)) * 3 + 1;
inds2 = (0:(n_dashes-1)) * 3 + 2;
xs(inds1) = start_xs;
xs(inds2) = end_xs;
ys(inds1) = start_ys;
ys(inds2) = end_ys;


function d = lfun_d_sig(x,start,stop,step)
x0 = my_sigmoid(x,start,stop);
x1 = my_sigmoid(x+step,start,stop);
d = x1-x0;