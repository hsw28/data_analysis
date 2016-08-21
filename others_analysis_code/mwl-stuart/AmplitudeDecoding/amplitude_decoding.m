
%%
[amps id] = make_tetrode_maps(nephron12,'saline');
%%
epoch = nephron12.saline;
stim = nearest(epoch.position.lin_pos'*10)/10;


while sum(isnan(stim))
    stim(find(isnan(stim))) = stim(find(isnan(stim))-1);%#ok
end
%%
training_range = [2435 2973];
amps_t = select_amps_by_feature(amps, 'feature', 'velocity',  'range', [.1 Inf]);
amps_t = select_amps_by_feature(amps_t, 'feature', 'ts',  'range', training_range);


spike_stim = cell(1,numel(amps_t));
spike_resp = cell(1,numel(amps_t));
for i=1:numel(amps_t)
    s = amps_t{i}(:,6);
    s = nearest(s*10)/10;
    spike_stim{i} = s;
    spike_resp{i} = amps_t{i}(:,1:4);
end

t = abs(diff(time_range));

stim_k = 0;
stim_k_w = .1;

resp_k = [0 0 0 0];
kw = 5;
resp_k_w = repmat(kw,1,4);
stim_grid = min(stim):.1:max(stim);
%%
p = poisson_decode(t, stim, spike_stim, spike_resp,...
    'stimulus_kernel_type', stim_k, ...
    'stimulus_kernel_width', stim_k_w, ...
    'response_kernel_type', resp_k, ...
    'response_kernel_width', resp_k_w, ...
    'stimulus_grid', {stim_grid});
%%
%decode_range = [3751 3753]; % replay
%dt = .01;
decode_range = [3138 3568];
dt = .25;

amps_d = select_amps_by_feature(amps, 'feature', 'ts', 'range', decode_range);

ampk = 20;
p.response_kernel_width = repmat(ampk,1,4);

posk = .1;
p.stimulus_kernel_width = posk;



t1 = decode_range(1);
n_est = abs(diff(decode_range))/dt;


warning off;
tic;
clear test_r est;
for i=1:n_est 
    tr = cell(0,numel(amps_d));
    for tt = 1:numel(amps_d)
        ind = amps_d{tt}(:,5)>=t1 & amps_d{tt}(:,5)<t1+dt;
        tr{tt} = amps_d{tt}(ind,1:4);

    end

    est(:,i) = p.decode(tr, dt);
    t1 = t1+dt;
end
elapsed = toc;
warning on;

tbins = decode_range:dt:t1;
%% Plot the Estimate and Position

figure; a = axes;
imagesc(tbins, stim_grid, est, 'Parent', a); set(gca,'YDir','Normal');
title(['Clusterless dt:', num2str(dt), ' ampk:', num2str(ampk(1)), ' posk:', num2str(posk)]);

p_ind = pts>=decode_range(1) & pts<decode_range(2);
line(pts(p_ind), pb(p_ind), 'color', 'w', 'LineStyle', '--', 'Parent', a);
%%
est_s = smoothn(est, 3, 'kernel', 'box');
[mm mind] = max(est_s);
pos_est = stim_grid(mind);
pos_est(end+1) = pos_est(end);

pos2 = interp1(pts, pos, tbins);
ismoving = logical(interp1(pts,abs(vel)>.1,tbins, 'nearest'));
err = abs(pos_est - pos2);  

    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
