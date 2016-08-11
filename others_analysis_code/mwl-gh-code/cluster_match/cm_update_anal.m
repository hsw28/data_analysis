function f = cm_update_anal(f,userdata)

cm_h = guidata(f);

nepoch = cm_h.nepoch;

anal_list = get(cm_h.anal_popup,'String');
anal_type = anal_list(get(cm_h.anal_popup,'Value'));

for i = 1:nepoch
    nclust = numel(cm_h.e_sdat{i}.clust);
    if (and((nclust > 0),get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String'))))
        sel_clust(i) = get(cm_h.clust_popup(i),'Value');
    end
end

clust = cell(nepoch);
%tic
for i = 1:nepoch
    nclust = numel(cm_h.e_sdat{i}.clust);
    if (and((nclust > 0),get(cm_h.clust_popup(i),'Value') < numel(get(cm_h.clust_popup(i),'String'))))
        clust{i}  = cm_h.e_sdat{i}.clust{sel_clust(i)};
    
        if(strcmp(anal_type,'isi'))
            max_isi_for_anal = 0.05;
            isi = diff(clust{i}.stimes);
            isi = isi(isi < max_isi_for_anal);
            hist(cm_h.haxis(i),isi,50);
        end
    
        if(strcmp(anal_type,'acorr'))
            dt = 0.01;
            n_dt_ps = 20; % step count on either side of 0 offset
            n_offset = 2*n_dt_ps+1;
            t_offset = [-dt*n_dt_ps:dt:dt*n_dt_ps];
            ind_offsets = [-n_dt_ps:n_dt_ps];
            stimes_fix = clust{i}.stimes;
    
            t_start = min(stimes_fix);
            t_end = max(stimes_fix);
            n_bins = ceil((t_end-t_start)/dt);
            edges = [0:n_bins].*dt+t_start;
        
            counts = histc(stimes_fix,edges);
    
            static_start_bin_index = n_dt_ps+1;
            static_end_bin_index = n_bins - n_dt_ps;
            static_vals = counts(static_start_bin_index:static_end_bin_index);
            static_vals = reshape(static_vals,numel(static_vals),1);
    
            acorr_vals = zeros(size(t_offset));
            %tic
            for j = [1:n_offset]
                %tic
                ind_offset = ind_offsets(j);
                sliding_start_index = static_start_bin_index + ind_offset;
                sliding_end_index = static_end_bin_index + ind_offset;
                sliding_vals = counts(sliding_start_index:sliding_end_index);
                sliding_vals = reshape(sliding_vals,numel(sliding_vals),1);
                %tic
                acorr_vals(j) = (dot(static_vals,sliding_vals));   
                %toc
            end
            %toc
            acorr_vals = acorr_vals ./ max(acorr_vals);
            plot(cm_h.haxis(i),t_offset,acorr_vals);
            %set(cm_h.haxis(i),'YLim',[-1 1]);
        end % end if acorr
    else
        cla(cm_h.haxis(i));
    end
end
%toc

f = f;