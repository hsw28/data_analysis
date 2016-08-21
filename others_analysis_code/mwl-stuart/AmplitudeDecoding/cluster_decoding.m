c_time = {nephron12.saline.clusters.time};
pos = nephron12.saline.position.lin_pos;
vel = nephron12.saline.position.lin_vel;
pts = nephron12.saline.position.timestamp;
%% Build list of spike times and pos by cluster
while sum(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end
c = cell(1,numel(c_time));
for i=1:numel(c)
    nspike = numel(c_time{i});
    c{i}(:,1) = ones(nspike,1)*i;           %1 - CL ID
    c{i}(:,2) = c_time{i};                  %2 - Spike time
    c{i}(:,3) = interp1(pts,pos,c_time{i}); %3 - Position
    c{i}(:,4) = interp1(pts,vel,c_time{i}); %4 - Velocity
end


%% Select by training time range and only cluster with >100 spikes
training_range = [2426 3455];
vel_thold =.1;
c_t = select_amps_by_feature(c, 'feature', 'col', 'col_num', 2, 'range', training_range);
c_t = select_amps_by_feature(c, 'feature', 'col', 'col_num', 4, 'range', [vel_thold, inf]);

clust_ind = logical(1:numel(c_t));
for i=1:numel(c_t)
    if numel(c_t{i})<100
        clust_ind(i) = 0;
    end
end
c_t = c_t(clust_ind);

%% Prepare the variables for the decoder
t = abs(diff(training_range));
stim = pos;
stim_grid = min(stim):.1:max(stim);
clear spike_stim spike_resp

for i=1:numel(c_t);
    s = nearest(c_t{i}(:,3)*10)/10;
    spike_stim{i} = s;
    spike_resp{i} = ones(size(s,1),0);
    
end

stim_k = 0;
stim_kw = .1;

resp_k = ones(0,1);
resp_kw = ones(0,1);

%%
p_clust = poisson_decode(t, stim', spike_stim, spike_resp,...
    'stimulus_kernel_type', stim_k, ...
    'stimulus_kernel_width', stim_kw, ...
    'response_kernel_type', resp_k, ...
    'response_kernel_width', resp_kw, ...
    'stimulus_grid', {stim_grid});
%% Decoding

%decode_range = [3751 3753]; % replay
%dt = .01;
decode_range = [3495 3577];
dt = .25;

c_d = select_amps_by_feature(c(clust_ind), 'feature', 'col','col_num', 2, 'range', decode_range);


posk = .1;
p.stimulus_kernel_width = posk;

cur_t = decode_range(1);
n_est = abs(diff(decode_range))/dt;

clear test_r est_cl;
warning off;
for i=1:n_est
    tr = cell(0,numel(c_d));
    for cc = 1:numel(c_d)
        ind = c_d{cc}(:,2)>=cur_t & c_d{cc}(:,2)<cur_t+dt;
        tr{cc} = ones( sum(ind),0);
    
    end
    
    est_cl(:,i) = p_clust.decode(tr,dt);
    cur_t = cur_t+dt;
end
tbins = decode_range:dt:t1;

%%
figure; a = axes;
imagesc(tbins, stim_grid, est_cl, 'Parent', a); set(gca,'YDir','Normal');


p_ind = pts>=decode_range(1) & pts<decode_range(2);
line(pts(p_ind), pb(p_ind), 'color', 'w','LineStyle', '--', 'Parent', a);

title(['Clustered dt:', num2str(dt),  ' posk:', num2str(posk)]);


est_clust_s = smoothn(est_clust







































