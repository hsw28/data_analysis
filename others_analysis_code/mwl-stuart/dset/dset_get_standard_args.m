function args = dset_get_standard_args()
% DSET_GET_STANDARD_ARGS - returns a struct ARGS with the standard arguments for dset based analysis

%General arguments
args.velocityThreshold = .1;

% Load everything
args.load_all.epoch = 'run';
args.load_all.structure = 'CA1';

% Place field calculation args
args.placefields.positionBinWidth = .05;
args.placefields.positionSmoothingKernelWidth = .1;
args.placefields.velocityThreshold = args.velocityThreshold;

% Single Unit Loading args
args.clusters.load_place_field = 1;
args.clusters.sleep_load_run_fields = 1;
args.clusters.default_run_epoch = 2;
args.clusters.frank_lab_pf_idx = 5;
args.clusters.base_firing_rate = .05;

% Multi Unit loading args
args.multiunit.threshold = 100;
args.multiunit.param_str = 'Max height change';
args.multiunit.timewin = [0 0];
args.multiunit.dt = .005;
args.multiunit.load_time_from_position = 1;
args.multiunit.spike_samp_rate = 10000;
args.multiunit.smooth = 1;
args.multiunit.smooth_dt = .01;
args.multiunit.electrodes = 1:30;
args.multiunit.pos_struct = [];
args.multiunit.left = [];
args.multiunit.right = [];

%MultiUnit Bursts args
args.mua_burst.velocity_threshold = 7;
args.mua_burst.high_threshold = 4;
args.mua_burst.low_threshold = .5;
args.mua_burst.pos_struct = [];
args.mua_burst.filter_on_velocity = 1;
args.mua_burst.min_burst_len = .01;


% Reconstruction default args
args.reconstruct.time_win = [ 0 0];
args.reconstruct.tau = .25;
args.reconstruct.area = {'all'};
args.reconstruct.hemisphere = {'all'};
args.reconstruct.pbins = [];
args.reconstruct.directional = 1;
args.reconstruct.smooth = 0;
args.reconstruct.traj_pf = 0;
args.reconstruct.traj_n = 0;
args.reconstruct.spatial_bins = [];
args.reconstruct.trajectory_type = 'simple';
args.reconstruct.trajectory_number = 1;
args.reconstruct.shuffle_tuning_curves = 0;

% Reconstruction plotting arguments
args.plot_reconstruction.smooth_position = 0;
args.plot_reconstruction.pos_marker = '.';
args.plot_reconstruction.pos_color = 'w';
args.plot_reconstruction.grayscale = 0;
args.plot_reconstruction.axes = [];

% Amplitude Decoding Parameters
spike_sample_rate = 30000;

args.amplitude.filter_narrow_spikes = 1;
args.amplitude.filter_low_amplitude_spikes = 1;
args.amplitude.min_voltage_threshold = 125;
args.amplitude.min_width_threshold_ms = 300;
args.amplitude.min_width_threshold_samples = round(1000 / spike_sample_rate * args.amplitude.min_width_threshold_ms);


% Position Loading arguments
args.position.compare_dates = 0;

args.analysis.ripple_dt_thold = .015;
end