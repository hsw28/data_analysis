function plot_phase_pref(pref_list)

length = 0.2;
cell_dist_range = [0.05 0.3];
plot_clumped = false;
plot_cells = true;
opt.plot_patch = false;

for k = 1:pref_list.n_trode_phase_pref
    this_trode = pref_list.trode_phase_pref(k);
    plot(this_trode.brain_ml,this_trode.brain_ap,'o');
    hold on
    if(plot_clumped)
        plot(this_trode.brain_ml+length.*[0, cos(this_trode.clumped_mean_phase)],...
            this_trode.brain_ap+length.*[0, sin(this_trode.clumped_mean_phase)]);
    end
    if(plot_cells)
        n_unit = this_trode.n_unit;
        dists = linspace(cell_dist_range(1),cell_dist_range(2),n_unit);
        for j = 1:n_unit
            lfun_plot_unit(this_trode,this_trode.unit_phase_pref(j), dists(end - (j-1)),j,opt);
        end
    end
end

axis equal;

function lfun_plot_unit(trode,unit,the_dist,id,opt)
n_pts = 100;
var_factor = 1;
colors = [1 0 0; 0 0.5 0; 0 0 1; 0 0.5 0.5; 0.5 0 0.5; 0.5 0.5 0];
n_colors = size(colors,1);
center_theta = unit.trial_long_phase_pref;
thetas = linspace(center_theta -unit.trial_long_circ_var.*pi*var_factor,...
    center_theta + unit.trial_long_circ_var.*pi*var_factor,n_pts);
if(opt.plot_patch)
    thetas = [0,thetas,0];
end
x_ctr = trode.brain_ml;
y_ctr = trode.brain_ap;
%x_ctr = 0;
%y_ctr = 0;
if(~opt.plot_patch)
    plot(x_ctr + the_dist.*cos(thetas), y_ctr + the_dist.*sin(thetas),'Color',colors(mod(id,n_colors)+1,:),'LineWidth',2);
else
    r = [0, the_dist .* ones(size(thetas)-[0, 2]),0];
    patch(x_ctr + r.*cos(thetas), y_ctr + r.*sin(thetas),colors(mod(id,n_colors)+1,:),'EdgeColor','none');
    colors = [0 0 0];
    n_colors = 1;
end
hold on;
plot(x_ctr+[0 the_dist.*cos(center_theta)],y_ctr + [0 the_dist.*sin(center_theta)],'Color',colors(mod(id,n_colors)+1,:),'LineWidth',2);
