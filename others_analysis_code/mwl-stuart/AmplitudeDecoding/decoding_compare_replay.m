%% Variables
vel_thold = .1;

%% Load DATA
exp = exp12;
ep = 'saline';

if isfield('position', exp.(ep))
    pos = exp.(ep).position.lin_pos;
    vel = exp.(ep).position.lin_vel;
    pts = exp.(ep).position.timestamp;
else
    pos = exp.(ep).pos.lp;
    vel = exp.(ep).pos.lv;
    pts = exp.(ep).pos.ts;
end

i = 1;
while isnan(pos(1))
    i = i+1;
    pos(1) = pos(i);
end

while any(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end

%% Amplitues --------------------------
clear amps clust ns_th sqrt_amps amps_m ns method
ignore_cluster_amplitudes = 0;
th = [80, Inf];

[amps{1} ns{1}] = select_amps_by_feature(load_tetrode_amps(exp,ep, 'threshold', 80), 'feature', 'col', 'col_num', 8, 'range', [12 40]);
[clust{1} ns{2}] = convert_cl_to_kde_format(exp, ep);


% if isfield(exp.(ep), 'clusters')
%     spike_times = {exp.(ep).clusters.time};
% else
%     spike_times = {exp.(ep).cl.st};
% end
% clust{1} = convert_cluster_format(spike_times, pos,  vel, pts);
% 

method = {'Amplitude', 'Clustered'};





%% Decode using both Amplitudes and Clustered Data

et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];
r2 = [3839 3850];

t_range = r1;
d_range = r2;




%%
clear est tbins pbins p est_r;
dt = .0075;
[est{1} tbins{1} pbins{1}] = decode_amplitudes(amps{1}, pos', t_range, d_range, 'dt', dt);
%[est{2} tbins{2} pbins{2}] = decode_clusters(clust{1}, pos', t_range, d_range, 'dt', dt, 'ignore_cluster_amplitudes', 1);
%est{3} = decode_clusters(clust{1}, pos', t_range, d_range, 'ignore_cluster_amplitudes', 0, 'amp_kw', [10 10 10 10]);
method = {'Wide Amplitudes', 'Clustered'};
est_r(:,:,1) = est{1};
est_r(:,:,2) = est{1};
est_r(:,:,3) = est{1};
%% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)







