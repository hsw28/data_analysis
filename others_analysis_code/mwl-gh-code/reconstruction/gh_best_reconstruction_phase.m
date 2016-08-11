function [best_phase, phase_data] = gh_best_reconstruction_phase(...
    place_cells, eeg_r_for_theta, pos_info, varargin)

p = inputParser();
p.addParamValue('r_tau', 0.030);
p.addParamValue('target_phases', circspace(-pi,pi,24));
p.addParamValue('run_direction','outbound');
p.addParamValue('timewin',[]);
p.addParamValue('plot_results',false);
p.addParamValue('trode_groups',[]);
p.addParamValue('run_speed_thresh',0.1);
p.parse(varargin{:});
opt = p.Results;

n_target_phases = numel(opt.target_phases);

n_trodegroups = 1;
if(~isempty(opt.trode_groups))
    n_trodegroups = numel(opt.trode_groups);
end

p_at_mode = zeros(n_trodegroups, n_target_phases);
for n = 1:n_target_phases
    [ok_times, ~] = gh_troughs_from_phase(eeg_r_for_theta,...
           'phase',opt.target_phases(n), 'pos_info', pos_info, ...
           'run_speed_thresh', opt.run_speed_thresh, ...
           'run_direction', opt.run_direction);
       
       trig_diff = diff(ok_times);
       ok_diffs = [1, trig_diff > opt.r_tau];
       
       if( any( ok_diffs == 0))
           n_times = numel(ok_times);
           num_ok = sum(ok_diffs);
           disp(['deleting ', num2str(n_times - num_ok), ...
               ' trig times that are too close to preceding one, out of ', ...
               num2str(n_times)]);
           ok_times = ok_times( logical(ok_diffs) );
       end
       
       this_multi_r_pos = gh_decode_independent_timepoints(place_cells,...
           pos_info, ok_times, 'trode_groups', opt.trode_groups,...
           'field_direction', opt.run_direction, 'r_tau', opt.r_tau);
       
       this_p_at_mode = reconstruction_p_at_mode(this_multi_r_pos);
       p_at_mode(:,n) = reshape(mean (this_p_at_mode, 2), [], 1);
end

expect = gh_polar_expectation(opt.target_phases, p_at_mode');
best_phase = expect;
phase_data.target_phase = opt.target_phases;
phase_data.p_at_mode = p_at_mode;

if(opt.plot_results)
    total_max = max(max(p_at_mode));
    ex_for_plot = repmat(expect', 1, 2);
    p_at_mode_for_plot = [p_at_mode, p_at_mode(:,1)];
    target_phases_for_plot = [opt.target_phases, opt.target_phases(1)];
    
    for n = 1:n_trodegroups
        this_color = opt.trode_groups{n}.color;
        polar(target_phases_for_plot, p_at_mode_for_plot(n,:), '-');
        hold on;
        polar(ex_for_plot(n,:), [0, total_max],'-');
        c = get(gca,'Children')
        set(c(  [1, 2]), 'Color', this_color);
        %set(get(gca,'Children'), 'Color', this_color);
    end
end