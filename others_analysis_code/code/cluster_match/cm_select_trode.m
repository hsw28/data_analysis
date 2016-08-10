function f = cm_select_trode(f,userdata)

cm_h = guidata(f);

get_waves = get(cm_h.waveforms_button,'Value');

%sdat = cm_h.sdat;

nclust = numel(cm_h.sdat.clust);

trode_ind = get(cm_h.trode_popup,'Value');
trode_names= get(cm_h.trode_popup,'String');
trode_name = trode_names{trode_ind};

epoch_names = cm_h.enames;
nepoch = cm_h.nepoch;



keep_ind = [];
for i = 1:nclust
    if(strcmp(trode_name,cm_h.sdat.clust{i}.trode))
        keep_ind = [keep_ind,i];
    end
end
if(numel(keep_ind) > 0);
    trode_sdat = sdatslice(cm_h.sdat,'index',keep_ind);
else
    trode_sdat.clust = cell(0);
end
nclust = numel(trode_sdat.clust);

e_keep_ind = cell(0);
e_sdat = cell(0);
e_clust_names = cell(nepoch);
for i = 1:nepoch
    e_name = epoch_names{i};
    e_keep_ind{i} = [];
    this_e_names = cell(0);
    for j = 1:nclust
        if(strcmp(trode_sdat.clust{j}.epochs,e_name))
            e_keep_ind{i} = [e_keep_ind{i},j];
            this_e_names = [this_e_names,trode_sdat.clust{j}.name];
        end
    end
    this_e_names = [this_e_names, 'NaC'];
    if(numel(e_keep_ind{i}>0))
        e_clust_names{i} = this_e_names;
        e_sdat{i} = sdatslice(trode_sdat,'index',e_keep_ind{i});
    else
        e_clust_names{i} = {'NaC'};
        e_sdat{i} = struct();
        e_sdat{i}.clust = cell(0);
    end
end

for i = 1:nepoch
    set(cm_h.clust_popup(i),'String',e_clust_names{i})
    set(cm_h.clust_popup(i),'Value',1);
end

% going to assume all clusts claiming to be of the same tetrode
% have the same .tt file.  They should.

%if(get_waves)

%    file_name = e_sdat{1}.clust{1}.from_tt_file;
%
%    cm_h.all_spikes = tt2mat(file_name);
%
%end


cm_h.e_sdat = e_sdat;


% NOTE - THIS COMMENTED BLOCK CRASHES INEXPLICABLY
% WHEN BOTH DISP COMMANDS AND TT2MAT ARE UNCOMMENTED
%cm_h.all_spikes = cell(1,nepoch);
%for i = 1:nepoch
    %disp(e_sdat{i}.clust{1}.name)
%    disp(e_sdat{i}.clust{1}.from_tt_file)
    %a=1
%    cm_h.all_spikes{i} = tt2mat(['',e_sdat{i}.clust{1}.from_tt_file]);
%end

guidata(f,cm_h);

cm_update_views(f,userdata);
%f = f;
