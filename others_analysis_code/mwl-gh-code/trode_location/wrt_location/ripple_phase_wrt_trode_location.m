function ripple_phase_wrt_trode_location(data, trode_i, trode_j, wrt_opt, varargin)

p = inputParser();
p.addParamValue('env_i_thresh',3);
p.addParamValue('env_j_thresh',3);
p.addParamValue('env_units','sd');
p.addParamValue('n_bins',40);
p.parse(varargin{:});
opt = p.Results;


trode_xy = mk_trodexy(data.raw, wrt_opt.rat_conv_table);

%env_i = data.ripple_env.data(:,trode_i);
phase_i = data.ripple_phase.data(:,trode_i);

for j = trode_j
%env_j = data.ripple_env.data(:,j);
phase_j = data.ripple_phase.data(:,j);

if(strcmp(opt.env_units,'sd'))
    env_i_thresh = opt.env_i_thresh .* std(data.ripple_env.data(:,trode_i));
    env_j_thresh = opt.env_j_thresh .* std(data.ripple_env.data(:,j));
else
    env_i_thresh = opt.env_i_thresh;
    env_j_thresh = opt.env_j_thresh;
end
   
keep_ok = data.ripple_env.data(:,trode_i) >= env_i_thresh & ...
          data.ripple_env.data(:,j) >= env_j_thresh & ...
          (~isnan(data.ripple_env.data(:,trode_i))) & ...
          (~isnan(data.ripple_env.data(:,j)));

theta_centers = linspace(0,2*pi,opt.n_bins);
theta_edges = bin_centers_to_edges(theta_centers);

phase_diffs = gh_circular_subtract(phase_j(keep_ok), phase_i(keep_ok));
phase_diffs = (mod(phase_diffs - theta_edges(1), 2*pi)) + theta_edges(1);

counts = histc(phase_diffs, theta_edges)';

gh_add_polar(theta_centers, counts(1:end-1), ...
    'pos', trode_xy(j, :), 'max_r',0.25,'circ_mean_has_magnitude',false);

end