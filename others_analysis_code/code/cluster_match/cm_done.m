function cm_done(f,userdata)

cm_h = guidata(f);
%handles = guihandles(f)

nclust = numel(cm_h.sdat.clust);
n_new_clust = numel(cm_h.new_sdat.clust);

for i = 1:nclust
    %i
    cm_h.new_sdat.clust{n_new_clust+1} = cm_h.sdat.clust{i};
    n_new_clust = n_new_clust + 1;
end
cm_h.new_sdat.nclust = numel(cm_h.new_sdat.clust);
assignin('base',cm_h.new_sdat_name,cm_h.new_sdat);
disp('Thanks for using cluster_match.');
close(gcf);