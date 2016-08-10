function f = cm_update_views(f,userdata)

%disp('cm_update_views got called');

cm_h = guidata(f);
e_sdat = cm_h.e_sdat;

x_param_ind = get(cm_h.x_param_popup,'Value');
y_param_ind = get(cm_h.y_param_popup,'Value');
z_param_ind = get(cm_h.z_param_popup,'Value');

x_p = x_param_ind - 1; % shave off the 'none' option
y_p = y_param_ind - 1;
z_p = z_param_ind - 1;

nepoch = cm_h.nepoch;

sel_clust = zeros(1,nepoch);
for i = 1:nepoch
    sel_clust(i) = get(cm_h.clust_popup(i),'Value');
end

h_pyramid_color = [0 0 1];
h_inter_color = [0 1 0];
h_noise_color = [1 0 0];
pre_plot_params = cell(1,nepoch);
for i = 1:nepoch
    nclust = numel(e_sdat{i}.clust);
    if (and((nclust > 0),get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String'))))
        pre_plot_params{i} = {'.','MarkerFaceColor',h_pyramid_color,'MarkerEdgeColor',h_pyramid_color};
        if(e_sdat{i}.clust{sel_clust(i)}.is_interneuron)
            pre_plot_params{i} = {'.','MarkerFaceColor',h_inter_color,'MarkerEdgeColor',h_inter_color};
        end
        if(e_sdat{i}.clust{sel_clust(i)}.is_noise_clust)
            pre_plot_params{i} = {'.','MarkerFaceColor',h_noise_color,'MarkerEdgeColor',h_noise_color};
        end
    end
end
pre_plot_generic = {'LineStyle','none','MarkerSize',1,'MarkerEdgeColor',[0.5 0.5 0.5],'MarkerFaceColor',[0.5 0.5 0.5],'Marker','.'};

% do param plots
max_x = 0.001;
max_y = 0.001;
max_z = 0.001;
if (and(x_p, y_p))
    if(z_p)
        for i = 1:nepoch
            this_axis = cm_h.paxis(i);
            cla(this_axis);
            hold(this_axis,'off');
            nclust = numel(e_sdat{i}.clust);
            pa = get(cm_h.plot_all,'Value');
            if (nclust > 0)
                for j = 1:nclust
                    do_plot = (or(pa, (j == sel_clust(i))));
                    if(and(pa, j ~= sel_clust(i)))
                        plot_params = pre_plot_generic;
                    else
                        if (get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String')))
                            plot_params = pre_plot_params{i};
                        end
                    end
                    if (do_plot)
                        this_data = e_sdat{i}.clust{j}.data;
                        plot3(this_axis,...
                            this_data(:,x_p)',...
                            this_data(:,y_p)',...
                            this_data(:,z_p)',...
                            plot_params{:});
                        hold(this_axis,'on')
                        max_x = max([max_x,max(this_data(:,x_p))]);
                        max_y = max([max_y,max(this_data(:,y_p))]);
                        max_z = max([max_z,max(this_data(:,z_p))]);
                    end
                end
            end
        end
        for i = 1:nepoch
            %cla(this_axis);
            this_axis = cm_h.paxis(i);
            set(this_axis,'Xlim',[0 max_x]);
            set(this_axis,'Ylim',[0 max_y]);
            set(this_axis,'Zlim',[0 max_z]);
        end
    else
        for i = 1:nepoch
            this_axis = cm_h.paxis(i);
            cla(this_axis);
            hold(this_axis,'off');
            nclust = numel(e_sdat{i}.clust);
            pa = get(cm_h.plot_all,'Value');
            if (nclust > 0)
                for j = 1:nclust
                    do_plot = (or(pa, (j == sel_clust(i))));
                    if(and(pa, j ~= sel_clust(i)))
                        plot_params = pre_plot_generic;
                    else
                        if (get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String')))
                            plot_params = pre_plot_params{i};
                        end
                    end
                    if (do_plot)
                        this_axis = cm_h.paxis(i);
                        this_data = e_sdat{i}.clust{j}.data;
                        plot(this_axis,...
                            this_data(:,x_p),...
                            this_data(:,y_p),...
                            plot_params{:});
                        hold(this_axis,'on');
                        max_x = max([max_x,max(this_data(:,x_p))]);
                        max_y = max([max_y,max(this_data(:,y_p))]);
                    end
                end
            end
        end
        for i = 1:nepoch
            this_axis = cm_h.paxis(i);
            set(this_axis,'Xlim',[0 max_x]);
            set(this_axis,'Ylim',[0 max_y]);
        end
    end
end

% maybe clear the waveform views
for i = 1:nepoch
    nclust = numel(e_sdat{i}.clust);
    if (and((nclust > 0),get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String'))))
        if(e_sdat{i}.clust{sel_clust(i)}.tracking_number ~= cm_h.wave_id(i))
            for j = 1:4
                cla(cm_h.saxis(i,j));
            end
        end
    end
end




cm_update_anal(f,userdata);