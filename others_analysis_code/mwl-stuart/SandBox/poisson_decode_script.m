time_range = [2426 3455];

[amps id] = make_tetrode_maps(nephron12,'saline');
tt = 6;
%%
amps_t = select_amps_by_feature(amps, 'feature', 'velocity',  'range', [.1 Inf]);
amps_t = select_amps_by_feature(amps_t, 'feature', 'ts',  'range', time_range);


% clust = nephron12.saline.clusters;
% 
% tt_id = {};
% sc = [];
% bins = 3340:.025:3440;
% for i=1:numel(clust)
%     tt_id{i} = clust(i).ttfile;
%     sc(i,:) = histc(clust(i).time, bins);
% end

%%
tt_ind = [1];
epoch = nephron12.saline;

stim = nearest(epoch.position.lin_pos'*10)/10;

while sum(isnan(stim))
    stim(find(isnan(stim))) = stim(find(isnan(stim))-1);%#ok
end

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
decode_range = [3751 3753];
amps_d = select_amps_by_feature(amps, 'feature', 'ts', 'range', decode_range);
time_win = .01;
ampk = 15;
posk = .05;

disp(['using dt:', num2str(dt)]);
p.response_kernel_width = repmat(ampk,1,4);
p.stimulus_kernel_width = posk;

t = decode_range(1);
n_est = abs(diff(decode_range))/dt;


warning off;
tic;
clear test_r est;
for i=1:n_est 
    tr = cell(0,numel(amps_d));
    for tt = 1:numel(amps_d)
        ind = amps_d{tt}(:,5)>=t & amps_d{tt}(:,5)<t+dt;
        tr{tt} = amps_d{tt}(ind,1:4);

    end

%    tr = amps_d{tt}(ind,1:4);
    %test_r(i,:,:) = tr;
    est(:,i) = p.decode(tr, dt);
    t = t+dt;
end
tbins = decode_range:dt:t;
elapsed = toc;
warning on;
figure; imagesc(tbins, stim_grid, est); set(gca,'YDir','Normal');
title(['tt:[', num2str(tt_ind), '] Kw:', num2str(k), ' time:', num2str(dt) ]);


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
