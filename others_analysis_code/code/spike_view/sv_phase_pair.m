function f = sv_phase_pair(sdat,varargin)
% f = SV_PHASE_PAIR (sdat, ['rat_conv_table',conv_table], ['m',blue_cell_index],
%                          ['n',green_cell_index],['draw_extras',bool],
%                          ['trode_groups', trode_groups], ['overlay', bool],
%                          ['draw_phase_extents',true])
% Draws spikes of two units at their track positions (x) and theta phase (y)
% Units input must be in an sdat struct that has gone through assign_field
% and assign_theta_phase
%
% Flip blue cell id with LEFT and RIGHT arrow keys.  Green cell with UP and DOWN

p = inputParser();
p.addParamValue('m',1,@isreal);
p.addParamValue('n',2,@isreal);
p.addParamValue('rat_conv_table',[]);
p.addParamValue('pos_info',[]);
p.addParamValue('trode_groups',[]);
p.addParamValue('draw_lines',true);
p.addParamValue('draw_extras',true);
p.addParamValue('draw_phase_extents',true);
p.addParamValue('overlay',false);
p.parse(varargin{:});
opt = p.Results;

data.m = p.Results.m;
data.n = p.Results.n;
data.sdat = sdat;

data.f = figure('Position',[50 50 400 300],'KeyPressFcn',@localfn_figure_keypress);

opt.de = opt.draw_extras;

localfn_plot_phase(sdat.clust{data.m},sdat.clust{data.n},p.Results.rat_conv_table,opt);
if(opt.draw_phase_extents)
localfn_plot_field_phase_extents(sdat.clust{data.m}, sdat.clust{data.n}, opt);
end
%data.axes = bar(sdat.clust{1}.field.bin_centers,sdat.clust{1}.field.out_rate,'b');
%hold on
%bar(sdat.clust{1}.field.bin_centers,-1.*sdat.clust{1}.field.in_rate,'r');
%data.i = 1;
%title([sdat.clust{1}.name,'  index: ' num2str(data.i)]);
data.sdat = sdat;
data.opt = opt;
data.rat_conv_table = p.Results.rat_conv_table;
guidata(data.f,data);
f = data.f;

function localfn_figure_keypress(src,eventdata)
data = guidata(src);

if strcmp(eventdata.Key,'rightarrow')
    data.m = data.m + 1;
elseif strcmp(eventdata.Key, 'leftarrow')
    data.m = data.m - 1;
elseif strcmp(eventdata.Key, 'uparrow')
    data.n = data.n - 1;
elseif strcmp(eventdata.Key, 'downarrow')
    data.n = data.n + 1;
end


localfn_plot_phase(data.sdat.clust{data.m},data.sdat.clust{data.n},data.rat_conv_table,data.opt);
if(data.opt.draw_phase_extents)
localfn_plot_field_phase_extents(data.sdat.clust{data.m}, data.sdat.clust{data.n}, data.opt);
end
guidata(data.f,data);


function [xs,ys] = make_phase_extents_box(field, clust, pos)
start_end_phase = field_first_last_phase(clust,pos,'field',field);
x = min(field);
w = abs(diff(field));
if(field(2) > field(1)) % outbound field: put it between 0 and 4pi
    while (min(start_end_phase) < 0)
        start_end_phase = start_end_phase + 2*pi;
    end
elseif(field(2) < field(1))
    while (max(start_end_phase) > 0)
        start_end_phase = start_end_phase - 2*pi;
    end
end
y = min(start_end_phase);
h = -1*diff(start_end_phase);
xs = [x, x+w, x+w, x, x];
ys = [y, y,   y+h, y+h, y];


function localfn_plot_field_phase_extents(clust_m,clust_n,opt)
if(isempty(opt.pos_info))
    error('You must include ''pos_info''');
end
fields_m = field_bounds(clust_m);
%out_fields_m = fields_m(:, diff(fields_m) > 0);
%in_fields_m = fields_m(:, diff(fields_m) < 0);
fields_n = field_bounds(clust_n);
%out_fields_n = fields_n(:, diff(fields_n) > 0);
%in_fields_n = fields_n( :, diff(fields_n) < 0);
for m = 1:size(fields_m,2)
    [xs,ys] = make_phase_extents_box(fields_m(:,m),clust_m,opt.pos_info);
    plot(xs,ys,'-','Color',[0 0 1]);
end
for n = 1:size(fields_n,2)
    [xs,ys] = make_phase_extents_box(fields_n(:,n),clust_n,opt.pos_info);
    plot(xs,ys,'-','Color',[0 1 0]);
end





function localfn_plot_phase(clust_m,clust_n,rat_conv_table,opt)
out_pos_ind_m = gh_dcbn(clust_m,'out_pos_at_spike');
in_pos_ind_m = gh_dcbn(clust_m,'in_pos_at_spike');
phase_ind_m = gh_dcbn(clust_m,'theta_phase');
out_pos_ind_n = gh_dcbn(clust_n,'out_pos_at_spike');
in_pos_ind_n = gh_dcbn(clust_n,'in_pos_at_spike');
phase_ind_n = gh_dcbn(clust_n,'theta_phase');

if(opt.overlay == false)
    hold off;
end

tg = ~isempty(opt.trode_groups);
if(tg)
    for a = 1:numel(opt.trode_groups)
        this_trodes = opt.trode_groups{a}.trodes;
        if(any(strcmp( clust_m.comp, this_trodes)))
            c_m = opt.trode_groups{a}.color;
        end
        if(any(strcmp( clust_n.comp, this_trodes)))
            c_n = opt.trode_groups{a}.color;
        end
    end
end
if(~tg)
    c_m = [0 0  1];
end
out_phases = mod(clust_m.data(:,phase_ind_m),2*pi);
data.axes = plot(clust_m.data(:,out_pos_ind_m),out_phases,'.','MarkerEdgeColor',c_m);
hold on
data.axes = plot(clust_m.data(:,out_pos_ind_m),out_phases+2*pi,'.','MarkerEdgeColor',c_m);
if(~tg)
    c_m = [0 0 1];
end
in_phases = mod(clust_m.data(:,phase_ind_m),2*pi);
data.axes = plot(clust_m.data(:,in_pos_ind_m),in_phases-2*pi,'.','MarkerEdgeColor',c_m);
data.axes = plot(clust_m.data(:,in_pos_ind_m),in_phases-4*pi,'.','MarkerEdgeColor',c_m);

if(~tg)
    c_n = [0 1 0];
end
out_phases = mod(clust_n.data(:,phase_ind_n),2*pi);
data.axes = plot(clust_n.data(:,out_pos_ind_n),out_phases,'.','MarkerEdgeColor',c_n);
data.axes = plot(clust_n.data(:,out_pos_ind_n),out_phases+2*pi,'.','MarkerEdgeColor',c_n);
if(~tg)
    c_n = [0 1 0];
end
in_phases = mod(clust_n.data(:,phase_ind_n),2*pi);
data.axes = plot(clust_n.data(:,in_pos_ind_n),in_phases-2*pi,'.','MarkerEdgeColor',c_n);
data.axes = plot(clust_n.data(:,in_pos_ind_n),in_phases-4*pi,'.','MarkerEdgeColor',c_n);

if(opt.draw_lines)
plot([0 4],[0 0],'k-');
plot([0 4],[2*pi 2*pi],'--','Color',[0 0 0]);
plot([0 4],[-2*pi -2*pi],'--','Color',[0 0 0]);
plot([0 4],[pi pi],'-.','Color',[0.7 0.7 0.7]);
plot([0 4],[-1*pi -1*pi],'-.','Color',[0.7 0.7 0.7]);
plot([0 4],[3*pi 3*pi],'-.','Color',[0.7 0.7 0.7]);
plot([0 4],[-3*pi -3*pi],'-.','Color',[0.7 0.7 0.7]);
end

xlim([0 4]);
ylim([0 2*pi]);
ylim([-4*pi 4*pi]);

if(opt.de)
text(0.1,10,{['Blue Comp: ', clean_name(clust_m.comp),'  cell: ', clean_name(clust_m.name)],['Green Comp: ', clean_name(clust_n.comp),'  cell: ', clean_name(clust_n.name)]});
end

ml_ind = find(strcmp('brain_ml',rat_conv_table.label));
ap_ind = find(strcmp('brain_ap',rat_conv_table.label));
comp_name_ind = find(strcmp('comp',rat_conv_table.label));
x = rat_conv_table.data(ml_ind,:);
y = rat_conv_table.data(ap_ind,:);
comp_list = rat_conv_table.data(comp_name_ind,:);

all_x = [];
all_y = [];
for a = 1:numel(x)
    all_x=[all_x,x{a}];
    all_y=[all_y,y{a}];
    %plot(x{a},y{a},'o','MarkerSize',7,'MarkerEdgeColor',[0.5 0.5 0.5]);
end
x_avg = mean(all_x);
y_avg = mean(all_y);
the_len = max(all_x) - min(all_x);
the_height = max(all_y) - min(all_y);
aspect = the_height / the_len;
pref_x = 0.5;
pref_y = -10;
pref_len = 0.5;
pref_height =2 ;
all_x = (all_x - x_avg)*pref_len/the_len + pref_x;
all_y = (all_y - y_avg)*pref_height/the_height + pref_y;

if(opt.de)
    plot(all_x,all_y,'o','MarkerSize',7,'MarkerEdgeColor',[0.5 0.5 0.5]);
end
ind_m = strcmp(clust_m.comp,comp_list);
ind_n = strcmp(clust_n.comp,comp_list);
comp_list;
clust_m.comp;
clust_n.comp;
if(opt.de)
if(~or(isempty(ind_m),isempty(ind_n)))
    plot(all_x(ind_m),all_y(ind_m),'o','MarkerSize',7,'MarkerEdgeColor',[0 0 0], 'MarkerFaceColor',[0 0 1]);
    plot(all_x(ind_n),all_y(ind_n),'o','MarkerSize',7,'MarkerEdgeColor',[0 0 0], 'MarkerFaceColor',[0 1 0]);
end

set(gca,'FontSize',16); set(gca,'YDir','normal');
end
%axis square;

