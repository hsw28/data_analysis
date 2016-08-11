function phase_limits = field_first_last_phase(clust, pos_info, varargin)
% phase_limits = FIELD_FIRST_LAST_PHASE(clust,pos, ['ecdf_lims', [0.1 0.9]]
%                                                  ['field_limit_opts',[]]
%                                                  ['field',[]])
%  For each of clust's place fields, consider the phases of all spikes
%  within that field.   Report the 'first' (field-entry) phase, and the
%  'last' (field-exit) phases.
%  Different fields listed in different columns

p = inputParser();
p.addParamValue('field_limit_opts',[]);
p.addParamValue('ecdf_lims', [0.9 0.2]);
p.addParamValue('field_lims',[0.2 0.8]);
p.addParamValue('field',[]);
p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.field))
    fields = opt.field;
else
    if(~isempty(opt.field_limit_opts))
        fields = field_bounds(clust,opt.field_limit_opts{:});
    else
        fields = field_bounds(clust);
    end
end

phase_limits = zeros(size(fields));

for n = 1:size(fields,2)
    field = fields(:,n);
    if(field(1) < field(2)) % outbound field
        pos_col = find(strcmp('out_pos_at_spike', clust.featurenames),1);

        run_timewins = pos_info.out_run_bouts;
        field_windows = [ [min(field); opt.field_lims(1) * diff(field) + min(field)], ...
                          [max(field) - opt.field_lims(2) * diff(field); max(field)] ];
        [~,in_field_b_start] = gh_times_in_timewins( clust.data(:,pos_col), field_windows(:,1)' );
        [~,in_field_b_end]   = gh_times_in_timewins( clust.data(:,pos_col), field_windows(:,2)');
    else
        pos_col = find(strcmp('in_pos_at_spike', clust.featurenames),1);
        run_timewins = pos_info.in_run_bouts;
        field_windows = [ [max(field) + opt.field_lims(1) * diff(field); max(field)], ...
                          [min(field); min(field) - (1-opt.field_lims(2)) * diff(field)] ];
        [~,in_field_b_start] = gh_times_in_timewins( clust.data(:,pos_col), field_windows(:,1)' );                      
        [~,in_field_b_end]   = gh_times_in_timewins( clust.data(:,pos_col), field_windows(:,2)' );
    end
    [~,during_run_b] = gh_times_in_timewins( clust.stimes, run_timewins );
    phases_start = clust.data( (in_field_b_start & during_run_b),  find(strcmp('theta_phase', clust.featurenames),1) );
    phases_end =   clust.data( (in_field_b_end   & during_run_b),  find(strcmp('theta_phase', clust.featurenames),1) );
    
    if(isempty(phases_start) || isempty(phases_end))
        phase_start = 0;
        phase_end = 0;
        warning('No phases in bounds!');
    else
    phase_start = lfun_mean_phase(phases_start, opt.ecdf_lims(1));
    phase_end =   lfun_mean_phase(phases_end,   opt.ecdf_lims(2));
    while(phase_start - phase_end < pi)
        phase_end = phase_end - 2*pi;
    end
    end
    phase_limits( :,n ) = [phase_start;phase_end];
end
    
function p = lfun_mean_phase(phases, quantile)
phase_bins = linspace(0,2*pi,20);
bin_centers = bin_edges_to_centers(phase_bins);
phases = mod(phases,2*pi);
spike_count = histc( phases, phase_bins );
spike_count = spike_count(1:(end-1));
[~,min_bin] = min(spike_count);
min_phase = bin_centers(min_bin);
phases = mod(sort( mod((phases - min_phase),2*pi) ) + min_phase, 2*pi);
p = phases( ceil( numel(phases) * quantile ) );
    