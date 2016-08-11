function f = sv_add_cdat(f,chan_index,color)

chan_height_frac = 0.005;

sv = guidata(f);

the_cdat = sv.cdat;

cont_timestamp = conttimestamp(the_cdat);
numel(cont_timestamp)
cont_data = the_cdat.data(:,chan_index);

data_height = sv.cdat.datarange(chan_index,1)-sv.cdat.datarange(chan_index,2);

y_range = get(sv.axis_a,'YLim');
y_height = y_range(2)-y_range(1);

pos_timestamp = conttimestamp(sv.pos.lin_filt);
pos_lin = sv.pos.lin_filt.data';

%this prevents plotting the 'carriage returns'
%low_ind = (cont_data == min(cont_data));
%cont_timestamp(low_ind) = NaN;
%cont_data(low_ind) = NaN;

% drop data points not in our pos timewindow
ok_ind = ((cont_timestamp >= min(pos_timestamp))&(cont_timestamp <= max(pos_timestamp)));
cont_timestamp = cont_timestamp(ok_ind);
cont_data = cont_data(ok_ind);

% instead of plotting the cdat, let's assume we're getting phase by time,
% and plot unobtrusive tic marks when the phase jumps
d_phase = diff(cont_data);
jump_times = cont_timestamp(abs(d_phase) > 3*std(d_phase));

% find cdat times in pos time terms
[counts, pos_timebin_ind] = histc(cont_timestamp,pos_timestamp);

% find jump times in terms of pos time bins
[counts, jump_timebin_ind] = histc(jump_times,pos_timestamp);

%cont_x = pos_lin(pos_timebin_ind);
%cont_y = pos_timestamp(pos_timebin_ind) + (cont_data'./data_height.*2).*chan_height_frac.*y_height;

%plot(sv.axis_a,cont_x,cont_y,'Color',color);
%hold(sv.axis_a,'on');

% treating jump-times like spikes...
njump = numel(jump_times);
xs = NaN.*zeros(1,njump*3);
ys = NaN.*zeros(1,njump*3);

ind1 = ([1:njump]-1).*3 + 1;
ind2 = ([1:njump]-1).*3 + 2;

jump_post_time = jump_times - pos_timestamp(jump_timebin_ind);
time_to_next_pos_ts = pos_timestamp(jump_timebin_ind + 1) - pos_timestamp(jump_timebin_ind);
jump_post_frac = jump_post_time ./ time_to_next_pos_ts;
pos_lin_diff = pos_lin(jump_timebin_ind + 1) - pos_lin(jump_timebin_ind);


x = pos_lin(jump_timebin_ind) + jump_post_frac .* pos_lin_diff;

xs(ind1) = x;
xs(ind2) = x;
ys(ind1) = pos_timestamp(jump_timebin_ind);
ys(ind2) = pos_timestamp(jump_timebin_ind) + y_height*chan_height_frac;

plot(sv.axis_a,xs,ys,'Color',color);
hold(sv.axis_a,'on');