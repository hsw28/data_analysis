function f = sv_add_clust(f,clust_index,color)

sv = guidata(f);

tic_height_frac = 0.01;

the_clust = sv.sdat.clust{clust_index};
tspike = the_clust.stimes';
timestamp = conttimestamp(sv.pos.lin_filt);
pos_timestamp = timestamp;
[counts,spike_pos_timestamp_ind] = histc(tspike,timestamp);
pos_lin = sv.pos.lin_filt.data';

% drop the spikes that aren't in any of our timebins
tspike = tspike(spike_pos_timestamp_ind > 0);
spike_pos_timestamp_ind = spike_pos_timestamp_ind(spike_pos_timestamp_ind > 0);

pspike = pos_lin(spike_pos_timestamp_ind);

ax_len = get(sv.axis_a,'YLim');
tic_height = (ax_len(2)-ax_len(1))*tic_height_frac;

spike_post_time = tspike - pos_timestamp(spike_pos_timestamp_ind);
time_to_next_pos_ts = pos_timestamp(spike_pos_timestamp_ind + 1) - pos_timestamp(spike_pos_timestamp_ind);
spike_post_frac = spike_post_time ./ time_to_next_pos_ts;
pos_lin_diff = pos_lin(spike_pos_timestamp_ind + 1) - pos_lin(spike_pos_timestamp_ind);

s_bottoms_x = pspike + pos_lin_diff.*spike_post_frac;
s_bottoms_y = tspike;
s_tops_x = pspike + pos_lin_diff.*spike_post_frac;
s_tops_y = tspike - tic_height;

nspike = numel(tspike);

ind1 = ([1:nspike]-1).*3+1;
ind2 = ([1:nspike]-1).*3+2;

xs = NaN.*zeros(1,nspike*3);
ys = NaN.*zeros(1,nspike*3);

xs(ind1) = s_bottoms_x;
xs(ind2) = s_tops_x;
ys(ind1) = s_bottoms_y;
ys(ind2) = s_tops_y;

hold(sv.axis_a,'on');
plot(sv.axis_a,xs,ys,'Color',color)