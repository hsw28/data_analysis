function cm_plot_waveforms(f,userdata)

cm_h = guidata(f);

nepoch = cm_h.nepoch;

sel_clust = zeros(1,nepoch);
for i = 1:nepoch
    nclust = numel(cm_h.e_sdat{i}.clust);
    if (and((nclust > 0),get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String'))))
        sel_clust(i) = get(cm_h.clust_popup(i),'Value');
    end
end

filename = cm_h.e_sdat{1}.clust{1}.from_tt_file;

all_spikes = tt2mat(filename);

% populate the spike views
max_h = 0;
min_h = 0;
for i = 1:nepoch
    nclust = numel(cm_h.e_sdat{i}.clust);
    if (and((nclust > 0),get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String'))))
        % grab the cell's spikes (by id matching)
        %cm_h
        %nspike_here = numel(e_sdat{i}.clust{sel_clust(i)}.data(:,1))
        %spikes_size = size(this_all)
        this_spikes = all_spikes.waveform(:,:,cm_h.e_sdat{i}.clust{sel_clust(i)}.data(:,1));
        for j = 1:4
            cla(cm_h.saxis(i,j));
            wf = this_spikes(:,j,:);
            wf_size = size(wf);
            wf2 = reshape(wf,32,numel(wf)/32);
            wf2 = wf2';
            avg = mean(wf2);
            st_h = avg+std(wf2);
            st_l = avg-std(wf2);
            max_h = max([max_h,max(st_h)]);
            min_h = min([min_h,min(st_l)]);
            %plot(cm_h.saxes(i,j),1,1);
            plot(cm_h.saxis(i,j),...
                st_l,'r');
            hold(cm_h.saxis(i,j),'on');
    
            plot(cm_h.saxis(i,j),...
                st_h,'g');
            plot(cm_h.saxis(i,j),...
                avg,'LineWidth',3);
        end
    end
end
for i = 1:nepoch
    for j = 1:4 
        set(cm_h.saxis(i,j),'YLim',[min_h,max_h]);
    end
end

wave_id = zeros(1,nepoch);
for i = 1:numel(wave_id)
    nclust = numel(cm_h.e_sdat{i}.clust);
    if (and((nclust > 0),get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String'))))
        wave_id(i) = cm_h.e_sdat{i}.clust{sel_clust(i)}.tracking_number;
    end
end

cm_h.wave_id = wave_id;

guidata(f,cm_h);