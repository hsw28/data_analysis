function neuron_fields = compute_fields(clust_array, stimulus)

% attach stimulus to each cell as a field; not sure how else to get an
% input argument in
%for n = 1:numel(clust_array)
%    clust_array{n}.stimulus = stimulus;
%end

%neuron_fields_cells = cellfun( @lfun_compute_field, clust_array, 'UniformOutput', false );
%neuron_fields = cat(1, neuron_fields_cells{:});
n_neurons = numel(clust_array);

stim_size = [1, cellfun( @numel, stimulus.value_mapping )];
stimulus_timewins = find_stimulus_timewins(stimulus);

big_timewins = repmat(stimulus_timewins, n_neurons, 1);
big_clust_array = repmat(reshape(clust_array,[],1), stim_size);
%big_clust_array = mat2cell(big_clust_array, ones(size(big_clust_array,1),1), ones(size(big_clust_array,2),1));

neuron_fields = cellfun( @lfun_spike_rate_in_timewins, big_clust_array, big_timewins);

end

function spike_rate = lfun_spike_rate_in_timewins( neuron, timewins )
    if(isempty(timewins))
        spike_rate = NaN;
        return
    end
    [~, in_win_logicals] = gh_times_in_timewins( neuron.stimes, timewins );
    spike_count = sum(in_win_logicals);
    total_time = sum( diff(timewins,[], 2), 1);
    spike_rate = spike_count / total_time;
end

