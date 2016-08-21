%%  construct global spike train NEW METHOD I need to bin and then strech
% or compress the template, this is something I wasn't doing before. Thank
% you miguel!
clear temp_cor run_bins run_spike_times template_bw temp_bins temp_cor template ;

scale_factor = [1, .1];
bw = .025;

  

run_bins = sl06.saline.epoch_times(1):bw:sl06.saline.epoch_times(2);

run_spike_times = single(zeros(numel(sl06.saline.clusters), numel(run_bins)));

ind = 0;
for c = sl06.saline.clusters
    ind = ind+1;
    run_spike_times(ind,:) = histc(c.time, run_bins);
end




burst_ind = 240;

warning off;
for i=1:numel(scale_factor)
    disp(scale_factor(i))
       
    temp_bins = sl06.saline.multiunit.burst_times(burst_ind,:);
    temp_bins = temp_bins(1):bw:temp_bins(2);
    %disp(size(temp_bins));

    template = single(zeros(numel(sl06.saline.clusters), numel(temp_bins)));
    scaled_temp_bins = temp_bins(1):bw*scale_factor(i):temp_bins(end);
    
    ind = 0;
    clear scaled_template;
    for c = sl06.saline.clusters
        ind = ind+1;
        template= histc(c.time, temp_bins); 
        template = smoothn(template, [0 .6]);
        scaled_template(ind,:) = interp1(temp_bins, template ,scaled_temp_bins);
    end    
    
    
    
    
   
    temp_cor(i,:) = template_corr2(scaled_template, run_spike_times);
    disp('loop');
end    
warning on;
disp('done');