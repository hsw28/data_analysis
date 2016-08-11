function h = gh_show_field_construction(clust,pos_info)

h= gca;
set(h,'NextPlot','add');
%subplot(2,1,1);

out_bouts = pos_info.out_run_bouts;
n_out_bouts = size(out_bouts,1);
in_bouts = pos_info.in_run_bouts;
n_in_bouts = size(in_bouts,1);

for m = 1:n_out_bouts
    position = [0,out_bouts(m,1),...
        max(pos_info.lin_filt.data),diff(out_bouts(m,:))];
    rectangle('Position',position,'LineStyle','none','FaceColor',[0.5 0.5 1]);
end
for m = 1:n_in_bouts
    position = [0, in_bouts(m,1),...
        max(pos_info.lin_filt.data),diff(in_bouts(m,:))];
    rectangle('Position',position,'LineStyle','none','FaceColor',[0.5 1 0.5]);
end

plot(pos_info.lin_filt.data(:,1), conttimestamp(pos_info.lin_filt),'k');

plot(clust.data(:,gh_dcbn(clust,'pos_at_all_spikes')), clust.data(:,gh_dcbn(clust,'time')),'ko');