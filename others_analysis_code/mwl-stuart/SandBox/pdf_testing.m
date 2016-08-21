%% using tetrode maps to do reconstruction
%% Load raw data
[maps06 tt_id06] = make_tetrode_maps(nephron06, 'saline');
%%
exp = nephron06;
map = maps06;
%%
lp = exp.saline.position.lin_pos;
pt = exp.saline.position.timestamp;
st = pt(1);
et = pt(end);

mub = exp.saline.multiunit.burst_times;
%% create the kernels
vel_t = .1;
min_spike_n = 250;

kernel_width = [10 10 10 10 .05]';

disp('Creating the kernels');
kernels = cell(numel(map),1);
for i=1:numel(map)
    vel = map{i}(:,7);
    moving = vel>=vel_t;
    if sum(moving)>min_spike_n
        m = map{i}(moving,[1 2 3 4 6]);
        k = kde(m', kernel_width); 
        kernels{i} = k;
    end
end


%%



%est  = cell(numel(map),1);
tbins = st:.001:et;
pbins = 0:.05:3.1;
%pdf = repmat([0], [size(tbins,2), n_p_bins, numel(kernels)]);

estimates = cell(numel(map),1);
timestamps = cell(numel(map),1);

for k=1:numel(kernels)
    est = [];
    
   
    if ~isempty(kernels{k})

        set(wb2, 'Name', '% spikes analyzed');
        est = nan(numel(pbins), size(map{k},1));
        for s = 1:size(map{k},1)
            amps = map{k}(s,1:4)';
             
            cond = condition(kernels{k},[1,2,3,4], amps);
            est(:,s) = (evaluate(cond, pbins));

            
        end
        estimates{k} = est;
        timestamps{k} = map{k}(:,5);
    end
    disp(k)
end

    %%
 est(est==(max(max(est)))) = 0;
 %%
 imagesc(normalize(est))
 %%
 
 


 time_win = st:.001:st+30;
 
 pdf_win = zeros(numel(pbins), numel(time_win), numel(estimates));
 
 for e=1:numel(estimates)
     idx = interp1(time_win, (1:numel(time_win))', timestamps{e}, 'nearest'); 
     idx = idx(~isnan(idx));
     for i=1:numel(idx)
        pdf_win(:,idx(i),e) = estimates{e}(:,i);
     end
     
 end


 
%%

pdf_norm = zeros(size(pdf_win));
for e = 1:numel(estimates)
    e
    pdf_norm(:,:,e) = normalize(smoothn(pdf_win(:,:,e), 'kernel', 'my_kernel', 'my_kernel', linspace(1,0,125)), 2, 'sum');
end
pdf_norm_s = sum(pdf_norm,3);
imagesc(normalize(pdf_norm_s));



































