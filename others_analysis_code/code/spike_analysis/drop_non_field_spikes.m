function out_clust = drop_non_field_spikes(clust)

fields = field_bounds(clust);
out_fields = fields(:, fields(1,:) < fields(2,:));
in_fields = fields(:,fields(1,:) > fields(2,:));
in_fields = in_fields([2,1],:);

out_pos = clust.data( :, find(strcmp('out_pos_at_spike',clust.featurenames),1) );
in_pos = clust.data( :, find(strcmp('in_pos_at_spike',clust.featurenames),1) );

[~,out_ok] = gh_times_in_timewins(out_pos, out_fields');
[~,in_ok] = gh_times_in_timewins(in_pos, in_fields');

keep_bool = (~isnan(out_pos) & out_ok) | (~isnan(in_pos) & in_ok);

clust.data = clust.data( keep_bool, : );
clust.stimes = clust.data( :, find(strcmp('time',clust.featurenames),1));

out_clust = clust;