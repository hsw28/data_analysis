function pref_phase = field_entry_phase_pref(clust,varargin)


disp('field_entry_phase_pref.m has been replaced by field_first_last_phase.m');
p = inputParser();
p.addParamValue('bound_fraction',[0 0.4]);
p.addParamValue('phase_quantile',0.9);
p.addParamValue('field_direction','bidirect', @(x) any(strcmp(x,{'biridect','outbound','inbound'})));
p.addParamValue('field_bound_opt',{});
p.parse(varargin{:});
opt = p.Results;

if(numel(opt.field_bound_opt) > 0)
    circular_track = varargin( find(strcmp('circular_track',varargin),1) + 1);
else
    circular_track = false;
end


bounds = field_bounds(clust, p.Results.field_bound_opt{:});
out_bounds = bounds(:, diff(bounds,1) > 0);
out_bounds = [out_bounds(1,:) + diff(out_bounds) .* opt.bound_fraction(1);...
    out_bounds(1,:) + diff(out_bounds) .* opt.bound_fraction(2)];
in_bounds  = bounds(:, diff(bounds,1) < 0);
tmp = in_bounds;
in_bounds(1,:) = tmp(2,:);
in_bounds(2,:) = tmp(1,:);
in_bounds = [in_bounds(2,:) - diff(in_bounds) .* opt.bound_fraction(2);...
    in_bounds(2,:) - diff(in_bounds) .* opt.bound_fraction(1)];

out_pos = clust.data(:, strcmp('out_pos_at_spike',clust.featurenames));
in_pos  = clust.data(:, strcmp('in_pos_at_spike', clust.featurenames));

phase_col = find(strcmp('theta_phase',clust.featurenames),1);
p = clust.data(:, phase_col);

if(isempty(phase_col))
    error('field_entry_phase_pref:no_phase_col','Cluster didn''t have phase data');
end

if(isempty(out_bounds))
    out_bounds  = [-100; -99]; % definitely empty bound
end
if(isempty(in_bounds))
    in_bounds = [-100; -99];
end
[~,is_out_bound] = gh_times_in_timewins(out_pos, out_bounds');
[~,is_in_bound]  = gh_times_in_timewins(in_pos,  in_bounds');

if(circular_track)
    dx = clust.field.bin_centers(2) - clust.field.bin_centers(1);
    [~,is_out_bound_aux] = gh_times_in_timewins(out_pos + max(clust.field.xs));
    is_out_bound = is_out_bound | is_out_bound_aux;
    [~,is_in_bound_aux] = gh_times_in_timewins(in_pos + max(clust.field.xs));
    is_in_bound = is_in_bound | is_in_bound_aux;
end

out_keep = and (is_out_bound, ~isnan(p));
in_keep =  and (is_in_bound,  ~isnan(p));

if(strcmp(opt.field_direction,'bidirect'))
    field_phases = p( out_keep | in_keep );
elseif(strcmp(opt.field_direction,'outbound'))
    field_phases = p( out_keep );
elseif(strcmp(opt.field_direction,'inbound'))
    field_phases = p( in_keep );
end

phase_mean = gh_circular_mean(field_phases);
% center the phases around 0, try to eliminate seams
field_phases = (mod(field_phases - phase_mean + pi, 2*pi)) - pi;

field_phases = sort(field_phases);

if(~isempty(field_phases))
    pref_phase = field_phases( floor(numel(field_phases) * opt.phase_quantile));
else
    pref_phase = NaN;
end