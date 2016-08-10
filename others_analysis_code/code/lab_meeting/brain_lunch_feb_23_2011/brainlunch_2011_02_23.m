%% General  data

good_morpheus_path = '~/data/morpheus/091810/';
good_mrwolf_path = '~/data/mrwolf/040311b/';
good_mrwolf_path2 = '~/data/mrwolf/032511/';
good_saturn_path = '~/data/saturn/082810/';
good_mnil_path = '?';
good_esm_path = ' ';
save rat_paths.mat

%% Best phase for reconstruction, broken out

cd(good_morpheus_path);
load data4.mat;

load data.mat click_points place_cells;

[pos_info, track_info] = linearize_track('l18.p','timewin', run_timewin,'click_points',click_points);
[place_cells, pos_info, track_info] = assign_field(place_cells, pos_info, 'n_track_seg',100,'track_info',track_info);

[~,mua_c] = assign_rate_by_time(mua,'samplerate',eeg_r.raw.samplerate);

[mua_p, mua_i] = mua_sort_by_spike_width(mua);
[~, mua_pc] = assign_rate_by_time(mua_p,'samplerate',eeg_r.raw.samplerate);
[~, mua_ic] = assign_rate_by_time(mua_i,'samplerate',eeg_r.raw.samplerate);

mua_pcr = prep_eeg_for_regress(mua_pc);
mua_icr = prep_eeg_for_regress(mua_ic);

trode_groups = morpheus_trode_groups();

% chan 1 has nice theta, use it as global theta
eeg_for_theta = contchans_r(eeg_r,'chans',1); 

save tmp.mat

%% Best phase Morpheus part 2

% around 40 degrees S to T
gh_best_reconstruction_phase(place_cells, eeg_for_theta, pos_info, ...
    'r_tau', 0.02, 'plot_results', true, 'target_phases', circspace(-pi, pi, 40),...
    'trode_groups', trode_groups,'run_direction','outbound','run_speed_thresh',0.20)

% closer to 80 degrees S to T
gh_best_reconstruction_phase(place_cells, eeg_for_theta, pos_info, ...
    'r_tau', 0.02, 'plot_results', true, 'target_phases', circspace(-pi, pi, 40),...
    'trode_groups', trode_groups,'run_direction','inbound','run_speed_thresh',0.20)

% note - with 5ms windows multi_r_pos for normal time (not phase-picked)
% shows some nice interesting replays

%% Load data for mr_wolf

clear;
load rat_paths
cd(good_mrwolf_path);
load data3_with_mua_eeg_and_mua mua;
samplerate = 400;
[~,mua_c] = assign_rate_by_time(mua,'samplerate',samplerate);

[mua_p, mua_i] = mua_sort_by_spike_width(mua);
[~, mua_pc] = assign_rate_by_time(mua_p,'samplerate',samplerate);
[~, mua_ic] = assign_rate_by_time(mua_i,'samplerate',samplerate);

mua_pcr = prep_eeg_for_regress(mua_pc);
mua_icr = prep_eeg_for_regress(mua_ic);

total_mua = sdatflatten(mua,'index', 1:16);
[total_mua_p, total_mua_i] = mua_sort_by_spike_width(total_mua);
[~,mua_all_pc] = assign_rate_by_time(total_mua_p, 'samplerate', samplerate);
mua_for_theta = prep_eeg_for_regress( mua_all_pc );

trode_groups = mrwolf_trode_groups();
conv_table = mrwolf_rat_conv_table();
draw_trodes(conv_table, 'red_trode', trode_groups{1}.trodes,...
    'green_trode', trode_groups{2}.trodes, 'blue_trode', trode_groups{3}.trodes);

load data.mat place_cells pos_info click_points run_timewin;
save labmeeting_data_mrwolf_fav_phases.mat


%% mrwolf fav theta sequence phase, next part

% results (57 cell day) is opposite direction from the one in morpheus 
% is the reconstruction quality worse?  Or is the apparent best phase kind
% of random?  doesn't seem very modulated in this rat.
gh_best_reconstruction_phase(place_cells, mua_for_theta, contchans_r(eeg_r,'chans',1), pos_info, ...
    'r_tau', 0.01, 'plot_results', true, 'target_phases', circspace(-pi, pi, 24),...
    'trode_groups', trode_groups,'run_direction','inbound','run_speed_thresh',0.30)

%% Load a different mrwolf day
% this day has good phase precession.  The first mrwolf has terrible
% precession
cd(good_mrwolf_path2);
load data.mat;
run_timewin = [min(pos_info.timestamp), max(pos_info.timestamp)];
trode_groups = mrwolf_trode_groups();
mua_complist = {'01','02','03','04','06','08','09','10','12','18','19','21','23','25','27','29'};
mua = immua(mrwolf_mua_filelist(mua_complist, '032511'),'timewin', run_timewin + [-10 10]);
[mua_p, ~] = mua_sort_by_spike_width(mua);
clear mua;
[~,mua_ps] = assign_rate_by_time(mua_p,'samplerate', 400);
mua_r = prep_eeg_for_regress(mua_ps);
mua_groups = sdatflatten_by_trode_group(mua_r, trode_groups);

eeg_for_theta = contchans_r(eeg_r, 'chans', 14);
place_cells = assign_theta_phase(place_cells, eeg_for_theta);
multi_r_pos = decode_pos_with_trode_pos(place_cells,pos_info,trode_groups,...
    'r_tau', 0.02, 'field_direction', 'outbound')
multi_r_pos2 = decode_pos_with_trode_pos(place_cells,pos_info,trode_groups,...
    'r_tau', 0.02, 'field_direction', 'inbound')

save mrwolf_data_2.mat;
%% Show some grouped replay

plot_multi_r_pos(multi_r_pos2,pos_info,'norm_c',true,'timewin',[4148.0 4149.4]); % nice replay
% full group r_pos with r_tau = 0.015 frac_overlap = 0.75 is pretty good
plot_multi_r_pos(r_pos, pos_info, 'norm_c', true, 'timewin', [4209.4 4209.0]); % funny replay
plot_multi_r_pos(r_pos, pos_info, 'norm_c', true, 'timewin', [4382.1 4382.9]); % cool hybrid theta sequence/replay thing

%% find best reconstruction phases for this mrwolf day
gh_best_reconstruction_phase(place_cells, contchans_r(eeg_r,'chans',1), pos_info, ...
    'r_tau', 0.02, 'plot_results', true, 'target_phases', circspace(-pi, pi, 24),...
    'trode_groups', trode_groups,'run_direction','inbound','run_speed_thresh',0.30)

