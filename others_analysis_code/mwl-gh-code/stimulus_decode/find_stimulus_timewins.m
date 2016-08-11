function stim_timewins = find_stimulus_timewins(stimulus)

stim_size = cellfun(@numel, stimulus.value_mapping);

stim_timewins = cell([1,stim_size]);  % save the first dimension for time or neuron identity
%timebouts = mat2cell(  stimulus.timebouts, ones( (size(stimulus.timebouts,1)),1), 2);
timebouts = stimulus.timebouts;
%stim_timewins = accumarray(stimulus.value, timebouts, stim_size, @(x) {x});

stim_time_starts = accumarray(stimulus.value, timebouts(:,1), stim_size, @(x) {x});
stim_time_ends =     accumarray(stimulus.value, timebouts(:,2), stim_size, @(x) {x});

stim_timewins = cellfun(@(x,y) cat(2,x,y), stim_time_starts, stim_time_ends, 'UniformOutput',false);

stim_timewins = permute(stim_timewins, [stimulus.stim_dim + 1,  1:stimulus.stim_dim]);