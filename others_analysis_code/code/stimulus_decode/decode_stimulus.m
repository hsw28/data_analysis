function stimulus_pdf = decode_stimulus( spike_array, varargin )

p = inputParser();
% either give the fields
p.addParamValue('neuron_fields',[]);
% or give enough info to compute them
p.addParamValue('stimulus', []);
p.addParamValue('options_for_stimulus',cell(0));

p.addParamValue('unsampled_field_rate', 0.01);

% options specific to the generated pdf
p.addParamValue('timewin',...
    [min(min( cellfun(@(x) min(x.stimes), spike_array.clust ))), ...
     max(max(cellfun(@(x) max(x.stimes), spike_array.clust )))]);
p.addParamValue('r_tau', 0.1);
p.addParamValue('timebouts', []);

p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.unsampled_field_rate))
    opt.neuron_fields(isnan(opt.neuron_fields)) = opt.unsampled_field_rate;
end

ok_for_histc = false;

if(isempty(opt.timebouts))
    t_edges = opt.timewin(1) : opt.r_tau : opt.timewin(2);
    opt.timebouts = [t_edges(1:(end-1))' , t_edges(2:end)'];
    ok_for_histc = true;
end

if(all( opt.timebouts((2:end), 1) >= opt.timebouts((1:(end-1)),2)))
    ok_for_histc = true;
end

n_bouts = size(opt.timebouts,1);
dt_bouts = diff(opt.timebouts, [], 2);
timebouts_cell = mat2cell(opt.timebouts, ones(n_bouts, 1), 2)';

if(isempty(opt.neuron_fields))
    if( isempty(opt.stimulus) )
        error('decode_stimulus:not_enough_info', 'Need to pass neuron_fields or stimulus and options_for_stimulus');
    end
    opt.neuron_fields = compute_fields(spike_array, opt.stimulus, opt.options_for_stimulus{:});
end

spike_array = reshape(spike_array, 1, []);  % put spikes in a row array

ok_for_histc

if(ok_for_histc)
    histc_edges = reshape(opt.timebouts',1,[]);
    rate_array = cellfun(@(x) lfun_spike_counts_by_histc(x, histc_edges), spike_array.clust, 'UniformOutput', false);
    rate_array = rate_array( (1:2:end), :);
else
    rate_array = cellfun(@(x) lfun_spike_counts_in_timebouts(x, timebouts_cell), spike_array.clust,'UniformOutput', false);
end
rate_array = cell2mat(rate_array);
n_stimulus_dim = numel( size(opt.neuron_fields) ) - 1;
% array for computation should be [ time, stim_d1, stim_d2, ..., stim_dn, neuron_id]
% so send the neuron_id dimension to the back
rate_array = permute(rate_array, [1, (1:n_stimulus_dim)+ 2, 2]); 
field_array = permute(opt.neuron_fields,[n_stimulus_dim+2, (1:n_stimulus_dim)+1, 1]);
field_array_big = repmat(field_array, size(rate_array,1), 1);

prod_of_count_exponentiated_fields = prod( bsxfun(@power, field_array, rate_array), 4);
exp_term = bsxfun(@times, dt_bouts, sum(field_array, n_stimulus_dim + 2));
%big_array = bsxfun(@(x) pow(opt.neuron_fields, rate_array)

%stimulus_pdf = bsxfun(@times, count_exponentiated_fields, exp_term);
stimulus_pdf = prod_of_count_exponentiated_fields .* exp_term;

pdf_time_sum = stimulus_pdf;
for n = 1:n_stimulus_dim
    pdf_time_sum = sum(pdf_time_sum, n+1);
end

stimulus_pdf = bsxfun( @rdivide, stimulus_pdf, pdf_time_sum );
end

function spike_counts = lfun_spike_counts_in_timebouts( neuron, timebouts )
    spike_times = neuron.stimes;
    spike_counts = cellfun(@(x) sum(and(x(1) <= spike_times, x(2) >= spike_times)), timebouts);
end

function spike_counts = lfun_spike_counts_by_histc( neuron, time_edges )
    spike_times = neuron.stimes;
    spike_counts = histc( spike_times, time_edges );
    spike_counts = spike_counts(1:2:(end-1));
end