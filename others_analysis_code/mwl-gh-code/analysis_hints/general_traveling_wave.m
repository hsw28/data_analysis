% Import spike data
cd ~/data/mrwolf/032711;
spikes = imspike('spikes');

% Get pos info
[pos_info,track_info,run_timewin,click_points] = linearize_track('l27.p','timewin_guide',true);

% Compute place fields, assign them to place cells, and add run speed
% annotations to pos_info
[spikes, pos_info] = assign_field(spikes,pos_info,'n_track_seg',100,'timewin',[],'smooth_sd_segs',[]);

% Manually check place cells.  Left-right to view different candidates.  Up
% to add candidate to keep-list.  Enter to assign keep-list into workspace
sv_field_browse(spikes, 'pos_info', pos_info);
place_cells = sdatslice(spikes,'index',keep_list);

% If it's not done yet, make ratname_rat_conv_table
[xs,ys] = trode_draw_locations(feducial_xs, feducial_ys);
% Copy xs into M/L fields and ys into A/P fields of
% ratname_rat_conv_table.m

% Edit ratname_trode_groups.m to group tetrodes together right.

% decode with trode position
[r_pos, g_sdat] = decode_pos_with_trode_pos(place_cells,pos_info,ratname_trode_groups, 'r_tau', 0.01,'field_direction','outbound');

% import eeg files
% edit quick_eeg.m to set filenames and channel labels
eeg = quick_eeg();
eeg_r = prep_eeg_for_regress(eeg,'timewin_buffer',2);
wave_movie(eeg_r,mrwolf_rat_conv_table,'timewin',[4673 4676],'time_scale',6,'frame_rate',24);

% make triggered reconstruction
r_pos_trig = gh_triggered_reconstruction(r_pos,pos_info);

% plot it
plot_multi_r_pos(r_pos_trig,pos_info,'breakout_chans',true,'norm_c',true, 'draw_mode', true);

% import mua
mua_files = mrwolf_mua_filelist({'01','02','03','04','06','08','09','10','12','18','19','21','23','25','27','29'}, '040311b');
% limit spikewidth to 16 samps or higher (or 't_width_guide' to do this
% interactively)
[mua, mua_rate] = immua(mua_files,'timewin', run_timewin, 't_width', [16 Inf]);
mua_rate.chanlabels = mua_files.comp_list;  % this should be taken care of in immua

[cycle_centers, cycles, cycle_depth, cycle_opt] = find_theta_cycles( mua_r.raw );

b_mua = gh_long_wave_regress(mua_r, mrwolf_rat_conv_table, 'timewins', cycles);
b_eeg = gh_long_wave_regress(mua_r, mrwolf_rat_conv_table, 'timewins', cycles);