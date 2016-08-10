function cm_match(f,userdata)

cm_h = guidata(f);
nepoch = numel(cm_h.e_sdat);

sel_clust = zeros(1,nepoch);
tn_for_sdat = [];
ind_for_sdat = [];
tmp_sdat = cell(1,nepoch);
name = cell(1,nepoch);
sel_epoch_list = [];
%e_sdat{1}
for i = 1:nepoch
    nac_ind = numel(get(cm_h.clust_popup(i),'String'));
    sel_clust(i) = get(cm_h.clust_popup(i),'Value');
    if(sel_clust(i) < nac_ind)
        sel_epoch_list = [sel_epoch_list,i];
        tn_for_sdat = [tn_for_sdat, cm_h.e_sdat{i}.clust{sel_clust(i)}.tracking_number];
        tmp_t_sdat = cm_h.e_sdat{i};
        tmp_sdat{i} = sdatslice(tmp_t_sdat,'index',sel_clust(i));
        name{i} = tmp_sdat{i}.clust{1}.name;
    end
end
%name1 = name
%sel_clust

sel_epoch_list
match_sdat = tmp_sdat{sel_epoch_list(1)};
a = numel(sel_epoch_list) > 1
if (a)%    (numel(sel_epoch_list > 1))
    for i = sel_epoch_list(2:end)
        get(cm_h.clust_popup(i),'String')
        nac_ind = numel(get(cm_h.clust_popup(i),'String'))
        if(sel_clust(i) < nac_ind);
            disp(['Think we found a clust in epoch ',num2str(i)]);
            if(not(isempty(tmp_sdat{i})));
                tmp_t_sdat = tmp_sdat{i};
                match_sdat.clust{i} = tmp_t_sdat.clust{1}
            end
        end
    end
end
assignin('base','msd',match_sdat);
match_sdat = sdatflatten(match_sdat);

% cut matched clusters from e_sdats, from sdat

for i = 1:nepoch
    nclust = numel(cm_h.sdat.clust);
    nac_ind = numel(get(cm_h.clust_popup(i),'String'));
    if(sel_clust(i) < nac_ind)
        for j = 1:nclust
            if (any(cm_h.sdat.clust{j}.tracking_number == tn_for_sdat))
                ind_for_sdat = [ind_for_sdat, j];
            end
        end
      
    %sel_clust(i)
    cm_h.e_sdat{i} = sdatslice(cm_h.e_sdat{i},'index',sel_clust(i),'exclude',true);   
    end
end

for i = 1:numel(ind_for_sdat)
    %this_name = cm_h.sdat.clust{ind_for_sdat(i)}.name
end
cm_h.sdat = sdatslice(cm_h.sdat,'index',ind_for_sdat,'exclude',true);

ind_new_sdat = numel(cm_h.new_sdat.clust) + 1;
cm_h.new_sdat.clust{ind_new_sdat} = match_sdat.clust{1};

assignin('base','new_sdat',cm_h.new_sdat);

guidata(f,cm_h);
cm_select_trode(f,userdata);