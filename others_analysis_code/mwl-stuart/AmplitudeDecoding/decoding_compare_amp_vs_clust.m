%% Variables
vel_thold = .1;

%% Load DATA
exp = exp15;
ep = 'run';

if isfield('position', exp.(ep))
    pos = exp.(ep).position.lin_pos;
    vel = exp.(ep).position.lin_vel;
    pts = exp.(ep).position.timestamp;
else
    pos = exp.(ep).pos.lp;
    vel = exp.(ep).pos.lv;
    pts = exp.(ep).pos.ts;
end

while any(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end

%% Amplitues --------------------------
clear amps clust ns_th sqrt_amps amps_m ns method
ignore_cluster_amplitudes = 0;
th = [80, Inf];

[amps{1} ns{1}] = load_tetrode_amps(exp,ep, 'threshold', 80);
[amps{2} ns{2}] = select_amps_by_feature(amps{1}, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
[clust{1} ns{3}] = convert_cl_to_kde_format(exp, ep);
[clust{2} ns{4}] = select_amps_by_feature(clust{1}, 'feature', 'col', 'col_num', 8, 'range', [12 40]);

% if isfield(exp.(ep), 'clusters')
%     spike_times = {exp.(ep).clusters.time};
% else
%     spike_times = {exp.(ep).cl.st};
% end
% clust{1} = convert_cluster_format(spike_times, pos,  vel, pts);
% 

method = {'Amplitude', 'Amplitude-Wide Spikes', 'Clustered', 'Custered-Wide Spikes' };

%% Decode using both Amplitudes and Clustered Data

et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];
%r2 = [r2(1), r2(1)+100];

t_range = r1;
d_range = r2;



%%
clear est tbins pbins p;

for i=1:numel(amps)
    tic;
    est = decode_amplitudes(a{1}, pos', t_range, d_range);
    toc;
end

j = 0;
for i = 1:numel(clust)
    tic;
    est{end+1} = decode_clusters(clust{i}, pos', t_range, d_range, 'ignore_cluster_amplitudes', 1);
    toc;
end

%%
clear est tbins pbins p;
[est{1} tbins{1} pbins{1}] = decode_amplitudes(amps{2}, pos', t_range, d_range);
[est{2} tbins{2} pbins{2}] = decode_clusters(clust{1}, pos', t_range, d_range);
%est{3} = decode_clusters(clust{1}, pos', t_range, d_range, 'ignore_cluster_amplitudes', 0, 'amp_kw', [10 10 10 10]);
method = {'Wide Amplitudes', 'Clustered'};

%% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)
[me e f x] = plot_amp_decoding_estimate_errors(est,exp.(ep).pos, 'decode_range', d_range, 'legend', method, 'smooth', 1);






