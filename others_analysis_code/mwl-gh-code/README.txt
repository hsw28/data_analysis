/ad_dev/
ad_find_spike.m
correct_arte_offset.m

/analysis_hints/
general__traveling_wave.m
notes.txt

/cluster_match/
cluster_match.m
cm_done.m
cm_init_gui.m
cm_match.m
cm_plot_waveforms.m
cm_select_trode.m
cm_toggle_interneuron.m
cm_toggle_noisecluster.m
cm_update_anal.m
cm_update_views.m
get_epoch_info.m
init_gui.m

/cont_mov/
mkcontmovopt.m

/dips_vs_ripples/
dip_ripple_env_xcorr.m
k_complex_filter.m
plot_xcorr_at_smooths.m
xcorr_at_smooths.m

/drop_spikes_at_phase/
assign_theta_phase2.m - assign 'theta phase' to each spike in sdat
build_eeg_for_units.m - assign 'theta phase' to each spike in sdat
drop_spikes_by_field_extent.m - for each place cell, drop all spikes that fall in the second half of each place field
drop_spikes_in_phase_range.m - 
lookup_t.m

/extract/
extract_dataOLD
tauto40greg
tauto40greg_nopos
tauto80greg
tauto80greg_nopos
tauto80greg_octrode
tautoNlynx

/gamma_analysis/
IEI_by_amp.m
average_acorr_by_theta_phase.m
gamma_find_extremes.m
gamma_pref_wave_try_multi_freq.n
gh_find_peaks.m
gh_gamma_pref_wave.m
gh_scatter_image.m
gh_theta_mod_of_gamma.m
gh_trig_waveform_anatomical_coords.m
scratch_acorr_movie.n
scratch_acorr_movie_single_chan.m
short_win_acorr.m

/gh_cont/
contchans_r.m
contchans_r_trode_group.m
contchans_trode_group.m
conttimestamp.m
easycontdisp.m
eeg_3d_frame.m
eeg_polad_frame.m
gh_disp_bouts.m
gh_gamma_filt.m
gh_plot_cont.m
gh_ripple_filt.m
gh_smooth_cont.m
gh_theta_couts.m
gh_theta_filt.m
gh_zero_bouts.m
line_browser.m
mkmov.m
mkmovopt.m
mkratecont.m
multi_chan_template_match.m
multicontenv.m
multicontphase.m
patch_broser.m
ripp_3d_frame.m
theta_3d_frame.m

/gh_segs/
gh_combine_segs.m

/gh_xcorr/
gh_psth.m
gh_psth_multi.m
gh_xcorr.m
psth_grd.m

/gpos/
gpos_get_raw.m
gpos_get_render.m
gpos_new.m - is a struct of timeseries of x, y coordinates
gpos_new_render.m
gpos_render_opt.m - a structure of parameters for rendering an occupancy field (data inclusion criteria like epoch, min velocity), and 'smoothing' parameters.
gpos_render_opt_fields.m
gpos_set_raw.m
gpos_set_raw_opt_fields.m - is a struct of info about the track (epoch definitions, track dimensionality (lin vs. open field), pixeto meter conversions...)
info.txt

/misc/
_parseArgs.m
anim_dists.m
anim_dists_assign_rand_pos.m
anim_dists_calc_strains.m	
anim_dists_draw.m
anova_rm.m
bin_centers_to_edges.m
bin_edges_to_centers.m
circ_from_points.m	
circspace.m	
clean_name.m	
cmap.m
date_ad_to_alpha.m
draw_track_and_fields.m	
fix_rat3_trode_names.m
get_cdat_list_for_sdat.m
get_rat3_eeg.m
getgains.m
gh_add_line.m	
gh_add_polar.m
gh_between.m
gh_bout_intersect.m	
gh_circular_mean.m	
gh_circular_subtract.m
gh_clear_axis.m	
gh_colors.m	
gh_cos_phase_model.m	
gh_dcbn.m	
gh_interp_floor.m	
gh_is_local_max.m
gh_is_local_min.m	
gh_polar_expectation.m	
gh_raster_points.m	
gh_sdat_raster_points.m	
gh_smooth.m	
gh_times_in_timewins.m	
gh_whistc.m	
heatRegress.m	
hector_coords.m	
hector_plot_tmp.m	
import_adinfo.m	
inv_sort.m	
isfieldmult.m	
nextDate.m	
nlinfitsome.m	
parameter_estimation.m	
plotTwoMeans.m	
pp.m	
quick_eeg.m	
quick_get_waveform.m	
reference_issue.m	
rm_anova2.m	
scratch_ripp2d.m	
strContains.m	
test_freq_shift.m	
theta_from_mua.m	
unwrap_by.m	
volume_conduction_demo.m

/pos/
assign_over_track.m	added more mwl specific code	5 days ago
clean_raw_pos.m	added more mwl specific code	5 days ago
gh_animate_pos.m	added more mwl specific code	5 days ago
gh_interp_pos.m	added more mwl specific code	5 days ago
gh_plot_pos.m	added more mwl specific code	5 days ago
gh_track_to_patches.m	added more mwl specific code	5 days ago
linearize_track.m	added more mwl specific code	5 days ago
linearize_track2.m	added more mwl specific code	5 days ago
linearize_track_rat3.m	added more mwl specific code	5 days ago
p2gpos.m	added more mwl specific code	5 days ago
velocity_cdat.m	added more mwl specific code	5 days ago
velocity_state.m

/rat_specific/
DELETE

/reconstruct_rem/
decode_rem_time.m	added more mwl specific code	5 days ago
delete_r_pos_diagonal.m	added more mwl specific code	5 days ago
rem_sort_units.m

/reconstruction/
chimeric_trig.m	added more mwl specific code	5 days ago
decode_pos_with_trode_pos.m	added more mwl specific code	5 days ago
gh_best_reconstruction_phase.m	added more mwl specific code	5 days ago
gh_decode_around_theta_phase.m	added more mwl specific code	5 days ago
gh_decode_independent_timepoints.m	added more mwl specific code	5 days ago
gh_decode_pos.m	added more mwl specific code	5 days ago
gh_find_reconstruction_timepoints.m	added more mwl specific code	5 days ago
gh_find_reconstruction_timewins.m	added more mwl specific code	5 days ago
gh_plot_rpos_stack.m	added more mwl specific code	5 days ago
gh_triggered_reconstruction.m	added more mwl specific code	5 days ago
gh_triggered_reconstruction_multiphase.m	added more mwl specific code	5 days ago
gh_troughs_from_phase.m	added more mwl specific code	5 days ago
plot_multi_r_pos.m	added more mwl specific code	5 days ago
plot_pos_xcorr_matrix.m	added more mwl specific code	5 days ago
plot_r_pos.m	added more mwl specific code	5 days ago
plot_total_and_breakout_reconstruction.m	added more mwl specific code	5 days ago
reconstructionAnalysis.m	added more mwl specific code	5 days ago
reconstruction_ci.m	added more mwl specific code	5 days ago
reconstruction_entropy.m	added more mwl specific code	5 days ago
reconstruction_p_at_mode.m	added more mwl specific code	5 days ago
reconstruction_pos_at_mode.m	added more mwl specific code	5 days ago
reconstruction_simple_xcorr_by_time.m	added more mwl specific code	5 days ago
reconstruction_ts.m	added more mwl specific code	5 days ago
reconstruction_xcorr_pos.m	added more mwl specific code	5 days ago
reconstruction_xcorr_shift.m	added more mwl specific code	5 days ago
test_find_reconstruction_timepoints.m	added more mwl specific code	5 days ago
trode_pos_color_map.m

/ripple_analysis/
do_ripple_analysis.m	added more mwl specific code	5 days ago
do_ripple_analysis_arg.m	added more mwl specific code	5 days ago
do_ripple_analysis_import.m	added more mwl specific code	5 days ago
filterBurstsByBehavior.m	added more mwl specific code	5 days ago
rippleBursts.m	added more mwl specific code	5 days ago
ripplesFromEEG.m	added more mwl specific code	5 days ago
ripplesFromMUARate.m

/shift_and_reconstruct/
shift_reconstruct.m	added more mwl specific code	5 days ago
shift_sdat.m

/sleep_score/
depricated_gh_bridge_segs.m	added more mwl specific code	5 days ago
depricated_gh_draw_segs.m	added more mwl specific code	5 days ago
depricated_gh_intersection_segs.m	added more mwl specific code	5 days ago
depricated_gh_invert_segs.m	added more mwl specific code	5 days ago
depricated_gh_signal_to_segs.m	added more mwl specific code	5 days ago
depricated_gh_union_segs.m	added more mwl specific code	5 days ago
depricated_seg_criterion.m	added more mwl specific code	5 days ago
sleep_states.m	added more mwl specific code	5 days ago
theta_delta_ratio.m

/spectrum_analysis/
gh_cross_frequency_coupling.m	added more mwl specific code	5 days ago
gh_cross_frequency_populate_array.m	added more mwl specific code	5 days ago
gh_spectrum.m

/spike_analysis/
assign_avg_waveform.m	added more mwl specific code	5 days ago
assign_cdat_to_sdat.m	added more mwl specific code	5 days ago
assign_cdat_to_sdat2.m	added more mwl specific code	5 days ago
assign_field.m	added more mwl specific code	5 days ago
assign_is_noise_cluster.m	added more mwl specific code	5 days ago
assign_rate_by_time.m	added more mwl specific code	5 days ago
assign_theta_phase.m	added more mwl specific code	5 days ago
assign_waveforms.m	added more mwl specific code	5 days ago
draw_phase_precession.m	added more mwl specific code	5 days ago
drop_non_field_spikes.m	added more mwl specific code	5 days ago
field_bounds.m	added more mwl specific code	5 days ago
field_entry_phase_pref.m	added more mwl specific code	5 days ago
field_extents.m	added more mwl specific code	5 days ago
field_extents_raster.m	added more mwl specific code	5 days ago
field_first_last_phase.m	added more mwl specific code	5 days ago
gh_acorr_timecourse.m	added more mwl specific code	5 days ago
gh_fix_compname.m	added more mwl specific code	5 days ago
gh_fix_sdat_gains.m	added more mwl specific code	5 days ago
gh_phase_precession_summary.m	added more mwl specific code	5 days ago
gh_place_cell_xcorr.m	added more mwl specific code	5 days ago
gh_plot_field.m	added more mwl specific code	5 days ago
gh_polar_raster_points.m	added more mwl specific code	5 days ago
gh_show_field_construction.m	added more mwl specific code	5 days ago
gh_sig_acorr.m	added more mwl specific code	5 days ago
gh_sig_xcorr.m	added more mwl specific code	5 days ago
gh_spike_acorr.m	added more mwl specific code	5 days ago
gh_spike_xcorr.m	added more mwl specific code	5 days ago
immua.m	added more mwl specific code	5 days ago
imspike.m	added more mwl specific code	5 days ago
isolate_field_with_phase.m	added more mwl specific code	5 days ago
mean_phase_precession.m	added more mwl specific code	5 days ago
mua_at_date.m	added more mwl specific code	5 days ago
mua_get_pyramidal.m	added more mwl specific code	5 days ago
mua_sort_by_spike_width.m	added more mwl specific code	5 days ago
newemptyclust.m	added more mwl specific code	5 days ago
plot_rpos_and_fe_raster.m	added more mwl specific code	5 days ago
quick_combine_raster_cdat.m	added more mwl specific code	5 days ago
sdat_filt_on_data.m	added more mwl specific code	5 days ago
sdat_filter_group.m	added more mwl specific code	5 days ago
sdat_get.m	added more mwl specific code	5 days ago
sdat_keep_one_cell_per_trode.m	added more mwl specific code	5 days ago
sdat_raster.m	added more mwl specific code	5 days ago
sdatflatten.m	added more mwl specific code	5 days ago
sdatflatten_by_trode_group.m	added more mwl specific code	5 days ago
sdatmergelikecomps.m	added more mwl specific code	5 days ago
sdatmergelikenames.m	added more mwl specific code	5 days ago
sdatslice.m	added more mwl specific code	5 days ago
sort_sdat_by_field.m	added more mwl specific code	5 days ago
spikechans.m	added more mwl specific code	5 days ago
spiketime_to_phase.m	added more mwl specific code	5 days ago
test_field_extents.m	added more mwl specific code	5 days ago
trode_color.m	added more mwl specific code	5 days ago
trode_group.m	added more mwl specific code	5 days ago
unwrap_linear_field.m

/spike_view/
spike_view.m	added more mwl specific code	5 days ago
spike_view_controls.m	added more mwl specific code	5 days ago
sv_add_cdat.m	added more mwl specific code	5 days ago
sv_add_clust.m	added more mwl specific code	5 days ago
sv_add_pos.m	added more mwl specific code	5 days ago
sv_field_browse.m	added more mwl specific code	5 days ago
sv_phase_pair.m	added more mwl specific code	5 days ago
sv_plot_all_cells_phase_precession.m	added more mwl specific code	5 days ago
sv_test.m	added more mwl specific code	5 days ago
sv_xcorr_browse.m

/staxis_fieldsize/
staxis_fieldsize_array.m	added more mwl specific code	5 days ago
staxis_fieldsize_plot.m	added more mwl specific code	5 days ago
staxis_stats.m

/staxis_phase_precession/
staxis_phase_precession_array.m	added more mwl specific code	5 days ago
staxis_phase_precession_plot.m	added more mwl specific code	5 days ago
staxis_phase_precession_stats.m

/stimulus_decode/
compute_fields.m	added more mwl specific code	5 days ago
decode_stimulus.m	added more mwl specific code	5 days ago
find_stimulus_timewins.m	added more mwl specific code	5 days ago
mk_stimulus.m	added more mwl specific code	5 days ago
mk_stimulus_lin_track.m	added more mwl specific code	5 days ago
mk_var_type.m	added more mwl specific code	5 days ago
smooth_fields.m

/subthresh/
gh_amps_to_angs.m	added more mwl specific code	5 days ago
gh_plot_polar_spikes.m	added more mwl specific code	5 days ago
gh_polar_3d_hist.m	added more mwl specific code	5 days ago
gh_polar_clust.m	added more mwl specific code	5 days ago
gh_polar_get_amps.m	added more mwl specific code	5 days ago
gh_simple_trig_lfp.m	added more mwl specific code	5 days ago
plot_pre_spike.m

/tetrode-analysis-matlab/
chewArtifact	added more mwl specific code	5 days ago
conv	added more mwl specific code	5 days ago
eeg	added more mwl specific code	5 days ago
import	added more mwl specific code	5 days ago
mua	added more mwl specific code	5 days ago
papers	added more mwl specific code	5 days ago
position	added more mwl specific code	5 days ago
prelude	added more mwl specific code	5 days ago
reconstruction	added more mwl specific code	5 days ago
ripples	added more mwl specific code	5 days ago
rscDips	added more mwl specific code	5 days ago
segments	added more mwl specific code	5 days ago
stateScore	added more mwl specific code	5 days ago
triggeredAverage

/triggers/
gh_find_trig.m	added more mwl specific code	5 days ago
gh_trig_lfp.m	added more mwl specific code	5 days ago
trig_shift_theta.m

/trode_location/
field_xcorr_by_trode_location	added more mwl specific code	5 days ago
wrt_location	added more mwl specific code	5 days ago
area_dists.m	added more mwl specific code	5 days ago
assign_trode_info.m	added more mwl specific code	5 days ago
collect_by_group.m	added more mwl specific code	5 days ago
draw_trodes.m	added more mwl specific code	5 days ago
first_phase_by_trode_pos.m	added more mwl specific code	5 days ago
group_of_trode.m	added more mwl specific code	5 days ago
mk_trode_st_dp.m	added more mwl specific code	5 days ago
mk_trodexy.m	added more mwl specific code	5 days ago
plot_phase_offsets.m	added more mwl specific code	5 days ago
plot_spike_phase_by_trode_pos.m	added more mwl specific code	5 days ago
quick_rate_plot.m	added more mwl specific code	5 days ago
quick_time_plot.m	added more mwl specific code	5 days ago
spike_mod_opt.m	added more mwl specific code	5 days ago
test_plot_phase_offsets.m	added more mwl specific code	5 days ago
trode_colors.m	added more mwl specific code	5 days ago
trode_conv.m	added more mwl specific code	5 days ago
trode_draw_locations.m	added more mwl specific code	5 days ago
trode_pos_and_color.m

/wave_analysis/

..		
old_drafts	added more mwl specific code	5 days ago
quick_scratch	added more mwl specific code	5 days ago
contwin_r.m	added more mwl specific code	5 days ago
disp_reg_stats.m	added more mwl specific code	5 days ago
find_theta_cycles.m	added more mwl specific code	5 days ago
gh_circ_nlinfit.m	added more mwl specific code	5 days ago
gh_clean_phase.m	added more mwl specific code	5 days ago
gh_gen_test_wave.m	added more mwl specific code	5 days ago
gh_long_mua_regress.m	added more mwl specific code	5 days ago
gh_long_wave_regress.m	added more mwl specific code	5 days ago
gh_reg_quiver.m	added more mwl specific code	5 days ago
gh_short_wave_regress.m	added more mwl specific code	5 days ago
gh_various_regress.m	added more mwl specific code	5 days ago
mua_vs_lfp.m	added more mwl specific code	5 days ago
new_eeg_from_model.m	added more mwl specific code	5 days ago
phase_pref.m	added more mwl specific code	5 days ago
plane_wave_guess_beta.m	added more mwl specific code	5 days ago
plane_wave_model.m	added more mwl specific code	5 days ago
plane_wave_params.m	added more mwl specific code	5 days ago
plane_wave_regress_frame.m	added more mwl specific code	5 days ago
plane_wave_regress_slide.m	added more mwl specific code	5 days ago
plot_phase_pref.m	added more mwl specific code	5 days ago
plot_plane_wave_fit.m	added more mwl specific code	5 days ago
post_vm.m	added more mwl specific code	5 days ago
predicted_time_offset.m	added more mwl specific code	5 days ago
prep_eeg_for_regress.m	added more mwl specific code	5 days ago
test_plane_wave_model.m	added more mwl specific code	5 days ago
wave_movie.m

/wavelet_analysis/
compute_lfp_pca.m
compute_wavelet_pca.m
display_wavelet_pca.m

/xclust_process/
copt_pxywabw_file.m - creates a binary version of a pxyabw file
velocity_filter_pxyabw_files.m
