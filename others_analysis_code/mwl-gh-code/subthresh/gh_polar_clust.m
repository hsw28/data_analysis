function [cluster_points_inds, ts, amps] = gh_polar_clust(ts,amps,varargin)

p = inputParser();
p.addParamValue('r_thresh',300);
p.addParamValue('timewin',[]);
p.addParamValue('immediate_drop_high_amp_thresh',5000);
p.addParamValue('dim1',1);
p.addParamValue('dim2',2);
p.addParamValue('dim3',3);
p.addParamValue('disp_max',1e4);
p.addParamValue('parms_file',[]);
p.addParamValue('n_select_ball_pts',500);
p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.parms_file))
    [ts,amps] = lfun_process_file(opt.parms_file,opt.timewin);
end

if(~isempty(opt.timewin))
    keep_log = and(ts >= min(opt.timewin), ts <= max(opt.timewin));
    ts = ts(keep_log);
    amps = amps(:,keep_log);
end
if(~isempty(opt.immediate_drop_high_amp_thresh))
    keep_log = max(amps,[],1) <= opt.immediate_drop_high_amp_thresh;
    ts = ts(keep_log);
    amps = amps(:,keep_log);
end

fig = lfun_init_figure(ts,amps,opt);
disp_fig = lfun_init_disp_fig(fig);

gdata = guidata(fig);
gdata.disp_fig = disp_fig;
base_ind = logical(gdata.base_ind);
select_ind = logical(gdata.select_ind);
angs = gdata.angs;
rs = gdata.rs;
ok_thresh = logical(gdata.ok_thresh);
guidata(fig,gdata);
refreshdata(fig,'caller');

lfun_update_plots(gdata.fig);
tmp = 1;
cluster_points_inds = gdata.select_ind;

function fig = lfun_init_figure(ts,amps,opt)
fig = figure('KeyPressFcn',@lfun_key_down);
gdata = guidata(fig);
gdata.ts = ts;
gdata.amps = amps;
gdata.opt = opt;
gdata.fig = fig;
if(~(size(amps,1) == 4))
    amps = amps';
end
[rs,angs] = lfun_amps_to_angs(amps);
gdata.all_visible = true;
gdata.rs = rs;
gdata.angs = angs;
%gdata.a = subplot(4,2,1); % ang 1 by ang 3
gdata.a = axes('position',[0.05 0.59 0.90 0.4]); % ang 1 by ang 3
%gdata.b = subplot(4,2,2); % 3d angles
%set(gdata.b,'NextPlot','add');
%gdata.c = subplot(4,2,3); % ang 1 by ang 2
gdata.c = axes('position',[0.05 0.19 0.90 0.4]); % ang 1 by ang 2
%gdata.d = subplot(4,2,4); % 3d amps
%set(gdata.d,'NextPlot','add');
%gdata.e = subplot(4,1,3); % amp histogram
gdata.e = axes('position',[0.05 0.05 0.90 0.1]); % amp histogram
%gdata.f = subplot(4,1,4); % time by r

if(numel(rs) > opt.disp_max)
    rand_samps = randsample(1:numel(rs),opt.disp_max);
    gdata.base_ind = zeros(size(rs));
    gdata.base_ind(rand_samps) = 1;
    gdata.base_ind = logical(rs >= 150);
else
    gdata.base_ind = ones(size(rs));
end

default_sphere_center = [0,0,0]';
default_sphere_radius_squared = (pi/4)^2;
dists_squared = (sum(angs - repmat(default_sphere_center,1,numel(rs)),1)).^2;
gdata.ok_sphere = dists_squared <= default_sphere_radius_squared;
ok_sphere = gdata.ok_sphere;
default_rs_range = [mean(rs)*2,max(rs)*0.9];
gdata.ok_thresh = and(rs >= min(default_rs_range), rs <= max(default_rs_range));
ok_thresh = gdata.ok_thresh;
gdata.select_ind = and(gdata.ok_sphere,gdata.ok_thresh);
gdata.rs_bin_edges = linspace(min(rs(ok_sphere)), max(rs(ok_sphere)),100);
gdata.rs_bin_counts = histc(rs(ok_sphere),gdata.rs_bin_edges);

guidata(fig,gdata);
gdata.ang1by3 = plot(gdata.a,0,0,'.','MarkerSize',1,'XDataSource','angs(1,ok_thresh)','YDataSource','angs(3,ok_thresh)');
gdata.ang1by2 = plot(gdata.c,1,2,'.','MarkerSize',1,'XDataSource','angs(1,ok_thresh)','YDataSource','angs(2,ok_thresh)');
%gdata.ang3d =   plot3(gdata.b,1,2,3,'.','MarkerSize',1,'XDataSource','angs(1,ok_thresh)','YDataSource','angs(2,ok_thresh)','ZDataSource','angs(3,ok_thresh)'); hold on;
%gdata.amp3d =   plot3(gdata.d,1,2,3,'.','MarkerSize',1,'XDataSource','amps(1,base_ind)','YDataSource','amps(2,base_ind)','ZDataSource','amps(3,base_ind)'); hold on; % fix to take opt dim1,dim2 etc
%axes(gdata.d);
%xlim([0, max(amps(1,:))]);
%ylim([0, max(amps(2,:))]);
%zlim([0, max(amps(3,:))]);
gdata.rs_hist = bar(gdata.e,1,1,'XDataSource','gdata.rs_bin_edges','YDataSource','log(gdata.rs_bin_counts)');
%gdata.timecourse = plot(gdata.f,1,1,'.','XDataSource','ts(select_ind)','YDataSource','rs(select_ind)');

tmp_r = sqrt(default_sphere_radius_squared);
default_pos = [0 - tmp_r/2, 0-tmp_r/2, tmp_r, tmp_r];
gdata.rect1 = imrect(gdata.c,default_pos);
gdata.point2 = impoint(gdata.a,0,0);
gdata.thresh_line = imline(gdata.e,[mean(rs)*2,0.9*max(rs)],[10 10]);

gdata.select_ball = [0,0,0]';

%gdata.ang_ball = plot3(gdata.b,1,1,1,'.','Color',[1 0 0],'MarkerSize',1,'XDataSource','gdata.select_ball(1,:)','YDataSource','gdata.select_ball(2,:)','ZDataSource','gdata.select_ball(3,:)');
%data.ang_select = plot3(gdata.b,1,1,1,'.','Color',[0 1 0],'MarkerSize',4,'XDataSource','angs(1,select_ind)','YDataSource','angs(2,select_ind)','ZDataSource','angs(3,select_ind)');
%gdata.amp_select = plot3(gdata.d,1,1,1,'.','Color',[0 1 0],'MarkerSize',4,'XDataSource','amps(1,select_ind)','YDataSource','amps(2,select_ind)','ZDataSource','amps(3,select_ind)');
guidata(gdata.fig,gdata);

function disp_fig = lfun_init_disp_fig(fig)
gdata = guidata(fig);
disp_fig = figure;
gdata.b = subplot(2,2,2); % ang3d will be top-right
set(gdata.b,'NextPlot','add');
gdata.d = subplot(2,2,1); % amp3d will be top-left
set(gdata.d,'NextPlot','add');
gdata.f = subplot(2,1,2); % rs by time will be bottom
gdata.ang3d = plot3(gdata.b,1,2,3,'.','MarkerSize',1,'XDataSource','angs(1,ok_thresh)','YDataSource','angs(2,ok_thresh)','ZDataSource','angs(3,ok_thresh)'); hold on;
gdata.amp3d = plot3(gdata.d,1,2,3,'.','MarkerSize',1,'XDataSource','amps(1,base_ind)','YDataSource','amps(2,base_ind)','ZDataSource','amps(3,base_ind)'); hold on; % fix to take opt dim1,dim2 etc
gdata.timecourse = plot(gdata.f,1,1,'.','XDataSource','ts(select_ind)','YDataSource','rs(select_ind)');

gdata.ang_ball = plot3(gdata.b,1,1,1,'.','Color',[1 0 0],'MarkerSize',1,'XDataSource','gdata.select_ball(1,:)','YDataSource','gdata.select_ball(2,:)','ZDataSource','gdata.select_ball(3,:)');
gdata.ang_select = plot3(gdata.b,1,1,1,'.','Color',[0 1 0],'MarkerSize',4,'XDataSource','angs(1,select_ind)','YDataSource','angs(2,select_ind)','ZDataSource','angs(3,select_ind)');
gdata.amp_select = plot3(gdata.d,1,1,1,'.','Color',[0 1 0],'MarkerSize',4,'XDataSource','amps(1,select_ind)','YDataSource','amps(2,select_ind)','ZDataSource','amps(3,select_ind)');
guidata(fig,gdata);

function [rs,angs] = lfun_amps_to_angs(amps)
rs = sqrt(amps(1,:).^2 + amps(2,:).^2 + amps(3,:).^2 + amps(4,:).^2);
ang1 = atan( sqrt( amps(4,:).^2 + amps(3,:).^2 + amps(2,:).^2) ./ amps(1,:) );
ang2 = atan( sqrt( amps(4,:).^2 + amps(3,:).^2) ./ amps(2,:) ) - 3*pi/8;
ang3 = atan(amps(4,:) ./ amps(3,:)) - pi/4;
angs = [ang1;ang2;ang3];
angs = angs - repmat( mean(angs,2), 1, numel(rs));
function amps = lfun_angs_to_amps(rs,angs)
amps = ones(size(angs,1)+1, size(angs,2));
angs = angs + pi/4;
amps(1,:) = rs .* cos(angs(1,:));
amps(2,:) = rs .* sin(angs(1,:)) .* cos(angs(2,:));
amps(3,:) = rs .* sin(angs(1,:)) .* sin(angs(2,:)) .* cos(angs(3,:));
amps(4,:) = rs .* sin(angs(1,:)) .* sin(angs(2,:)) .* sin(angs(3,:)) + cos(angs(4,:));

function lfun_update_plots(fig)
gdata = guidata(fig);
rs_thresh = gdata.thresh_line.getPosition;
rs_thresh = rs_thresh(:,1);
ok_thresh = logical(and(gdata.rs >= min(rs_thresh), gdata.rs <= max(rs_thresh)));

angs = gdata.angs;


rect_pos = gdata.rect1.getPosition;
center_pt = [rect_pos(1) + rect_pos(3)/2, rect_pos(2) + rect_pos(4)/2]';
point_pos = gdata.point2.getPosition;
center_pt = [center_pt; point_pos(2)]; % format: [ang1;ang2;ang3]
thresh_squared = (max([rect_pos(2),rect_pos(4)])/2)^2;
rad_squared =   sum(((gdata.angs - repmat(center_pt,1,numel(gdata.rs))).^2),1);
ok_sphere = logical(rad_squared <= thresh_squared);
gdata.ok_sphere = ok_sphere;
gdata.ok_thresh = ok_thresh;

if(sum(ok_sphere) > 0)
    gdata.rs_bin_edges = linspace(min(gdata.rs(ok_sphere)), max(gdata.rs(ok_sphere)),100);
    gdata.rs_bin_counts = histc(gdata.rs(ok_sphere),gdata.rs_bin_edges);
else
    gdata.rs_bin_edges = linspace(0,100,100);
    gdata.rs_bin_counts = zeros(size(gdata.rs_bin_edges));
end

gdata.select_ball = lfun_select_ball_coords(center_pt,sqrt(thresh_squared),gdata.opt.n_select_ball_pts);

ts = gdata.ts;
amps = gdata.amps;
base_ind = logical(gdata.base_ind);
select_ind = logical(and(ok_thresh, ok_sphere));
gdata.select_ind = select_ind;
angs = gdata.angs;
rs = gdata.rs;
ok_thresh = logical(gdata.ok_thresh);

refreshdata(gdata.fig,'caller');
refreshdata(gdata.disp_fig,'caller');

axes(gdata.b); xlim([-pi/5,pi/5]);ylim([-pi/5, pi/5]); zlim([-pi/5,pi/5]);
guidata(gdata.fig,gdata);

function select_ball = lfun_select_ball_coords(center_pt,rad,n_pts)
theta_range = [0,pi];
phi_range = [-pi,pi];
n_step = ceil(sqrt(n_pts));
thetas = linspace(theta_range(1),theta_range(2),n_step);
phis = linspace(phi_range(1),phi_range(2),n_step);
[THETAS,PHIS] = meshgrid(thetas,phis);
rs = rad .* ones(size(THETAS));
xs = rs .* sin(THETAS) .* cos(PHIS) + center_pt(1);
ys = rs .* sin(THETAS) .* sin(PHIS) + center_pt(2);
zs = rs .* cos(THETAS) + center_pt(3);
select_ball = [reshape(xs,1,[]); reshape(ys,1,[]); reshape(zs,1,[])];

function [ts,amps] = lfun_process_file(filename,timewin)
f = mwlopen(filename);
ts = f.time;
a1 = f.t_px;
a2 = f.t_py;
a3 = f.t_pa;
a4 = f.t_pb;
amps = [a1;a2;a3;a4];
clear a1;
clear a2;
clear a3;
clear a4;
if(~isempty(timewin))
    keep_ind = and(ts >= min(timewin), ts <= max(timewin));
    ts = ts(keep_ind);
    amps = amps(:,keep_ind);
end
amps = double(amps);

function lfun_delete_selection(fig)
gdata = guidata(fig);
keep_log = logical(ones(size(gdata.rs)) - gdata.select_ind);
gdata.ts = gdata.ts(keep_log);
gdata.amps = gdata.amps(:,keep_log);
gdata.rs = gdata.rs(keep_log);
gdata.angs = gdata.angs(:,keep_log);
gdata.base_ind = gdata.base_ind(keep_log);
guidata(fig,gdata);
lfun_update_plots(fig);

function lfun_set_amp_dims(fig,dims)
gdata = guidata(fig);
set(gdata.amp3d,'XDataSource',['amps(',num2str(dims(1)),',base_ind)']);
set(gdata.amp3d,'YDataSource',['amps(',num2str(dims(2)),',base_ind)']);
set(gdata.amp3d,'ZDataSource',['amps(',num2str(dims(3)),',base_ind)']);
guidata(fig,gdata);
lfun_update_plots(fig);

function lfun_key_down(src,evnt)
if evnt.Character == 'u'
    lfun_update_plots(src);
end
if evnt.Character == 'a'
    gdata = guidata(src);
    gdata.all_visible = ~gdata.all_visible;
    guidata(src,gdata);
    if(gdata.all_visible)
        tmp = 'on';
    else
        tmp = 'off';
    end
    set(gdata.amp3d,'Visible',tmp);
    set(gdata.ang3d,'Visible',tmp);
end