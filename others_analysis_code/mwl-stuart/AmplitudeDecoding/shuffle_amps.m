function amps = shuffle_amps(amps, time_range)

for i=1:numel(amps)
   idx = find(time_range(1)<=amps{i}(:,5) & time_range(2)>=amps{i}(:,5));
   r_idx = randsample(idx,numel(idx));
   amps{i}(r_idx,1:4) = amps{i}(idx,1:4);
    
end




end
