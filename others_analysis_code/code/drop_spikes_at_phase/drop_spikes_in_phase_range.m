function new_sdat = drop_spikes_in_phase_range(sdat,phase_range, mod_opt)
% DROP_SPIKES_IN_PHASE_RANGE(sdat,phase_range) 

dp = mod(diff(phase_range), 2*pi);

if(diff(phase_range) > (2*pi))
    error('drop_spikes_in_phase_range:bad_phase_range',...
        'phase_range must have diff less than 2pi');
end

n_units = numel(sdat.clust);


for n = 1:n_units
    
    this_unit = sdat.clust{n};
    phase_index = find( strcmp('theta_phase', this_unit.featurenames), 1, 'first');
    this_phases = this_unit.data(:,phase_index);
    
    drop_bool = mod(this_phases - phase_range(1), 2*pi) < dp;
    
    sdat.clust{n}.data = sdat.clust{n}.data( ~drop_bool, :);

    time_index = strcmp('time',sdat.clust{n}.featurenames);
    sdat.clust{n}.stimes = sdat.clust{n}.data(:,time_index)';

end

new_sdat = sdat;