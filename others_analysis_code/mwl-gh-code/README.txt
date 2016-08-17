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
assign_over_track.m	
clean_raw_pos.m	
gh_animate_pos.m	
gh_interp_pos.m	
gh_plot_pos.m	
gh_track_to_patches.m	 
linearize_track.m	 
linearize_track2.m	 
linearize_track_rat3.m	 
p2gpos.m	 
velocity_cdat.m	 
velocity_state.m

/reconstruct_rem/
decode_rem_time.m	 
delete_r_pos_diagonal.m	 
rem_sort_units.m

/reconstruction/
chimeric_trig.m	 
decode_pos_with_trode_pos.m	 
gh_best_reconstruction_phase.m	 
gh_decode_around_theta_phase.m	 
gh_decode_independent_timepoints.m	 
gh_decode_pos.m	 
gh_find_reconstruction_timepoints.m	 
gh_find_reconstruction_timewins.m	 
gh_plot_rpos_stack.m	 
gh_triggered_reconstruction.m	 
gh_triggered_reconstruction_multiphase.m	 
gh_troughs_from_phase.m	 
plot_multi_r_pos.m	 
plot_pos_xcorr_matrix.m	 
plot_r_pos.m	 
plot_total_and_breakout_reconstruction.m	 
reconstructionAnalysis.m	 
reconstruction_ci.m	 
reconstruction_entropy.m	 
reconstruction_p_at_mode.m	 
reconstruction_pos_at_mode.m	 
reconstruction_simple_xcorr_by_time.m	 
reconstruction_ts.m	 
reconstruction_xcorr_pos.m	 
reconstruction_xcorr_shift.m	 
test_find_reconstruction_timepoints.m	 
trode_pos_color_map.m

/ripple_analysis/
do_ripple_analysis.m	 
do_ripple_analysis_arg.m	 
do_ripple_analysis_import.m	 
filterBurstsByBehavior.m	 
rippleBursts.m	 
ripplesFromEEG.m	 
ripplesFromMUARate.m

/shift_and_reconstruct/
shift_reconstruct.m	 
shift_sdat.m

/sleep_score/
depricated_gh_bridge_segs.m	 
depricated_gh_draw_segs.m	 
depricated_gh_intersection_segs.m	 
depricated_gh_invert_segs.m	 
depricated_gh_signal_to_segs.m	 
depricated_gh_union_segs.m	 
depricated_seg_criterion.m	 
sleep_states.m	 
theta_delta_ratio.m

/spectrum_analysis/
gh_cross_frequency_coupling.m	 
gh_cross_frequency_populate_array.m	 
gh_spectrum.m

/spike_analysis/
assign_avg_waveform.m	 
assign_cdat_to_sdat.m	 
assign_cdat_to_sdat2.m	 
assign_field.m	 
assign_is_noise_cluster.m	 
assign_rate_by_time.m	 
assign_theta_phase.m	 
assign_waveforms.m	 
draw_phase_precession.m	 
drop_non_field_spikes.m	 
field_bounds.m	 
field_entry_phase_pref.m	 
field_extents.m	 
field_extents_raster.m	 
field_first_last_phase.m	 
gh_acorr_timecourse.m	 
gh_fix_compname.m	 
gh_fix_sdat_gains.m	 
gh_phase_precession_summary.m	 
gh_place_cell_xcorr.m	 
gh_plot_field.m	 
gh_polar_raster_points.m	 
gh_show_field_construction.m	 
gh_sig_acorr.m	 
gh_sig_xcorr.m	 
gh_spike_acorr.m	 
gh_spike_xcorr.m	 
immua.m	 
imspike.m	 
isolate_field_with_phase.m	 
mean_phase_precession.m	 
mua_at_date.m	 
mua_get_pyramidal.m	 
mua_sort_by_spike_width.m	 
newemptyclust.m	 
plot_rpos_and_fe_raster.m	 
quick_combine_raster_cdat.m	 
sdat_filt_on_data.m	 
sdat_filter_group.m	 
sdat_get.m	 
sdat_keep_one_cell_per_trode.m	 
sdat_raster.m	 
sdatflatten.m	 
sdatflatten_by_trode_group.m	 
sdatmergelikecomps.m	 
sdatmergelikenames.m	 
sdatslice.m	 
sort_sdat_by_field.m	 
spikechans.m	 
spiketime_to_phase.m	 
test_field_extents.m	 
trode_color.m	 
trode_group.m	 
unwrap_linear_field.m

/spike_view/
spike_view.m	 
spike_view_controls.m	 
sv_add_cdat.m	 
sv_add_clust.m	 
sv_add_pos.m	 
sv_field_browse.m	 
sv_phase_pair.m	 
sv_plot_all_cells_phase_precession.m	 
sv_test.m	 
sv_xcorr_browse.m

/staxis_fieldsize/
staxis_fieldsize_array.m	 
staxis_fieldsize_plot.m	 
staxis_stats.m

/staxis_phase_precession/
staxis_phase_precession_array.m	 
staxis_phase_precession_plot.m	 
staxis_phase_precession_stats.m

/stimulus_decode/
compute_fields.m	 
decode_stimulus.m	 
find_stimulus_timewins.m	 
mk_stimulus.m	 
mk_stimulus_lin_track.m	 
mk_var_type.m	 
smooth_fields.m

/subthresh/
gh_amps_to_angs.m	 
gh_plot_polar_spikes.m	 
gh_polar_3d_hist.m	 
gh_polar_clust.m	 
gh_polar_get_amps.m	 
gh_simple_trig_lfp.m	 
plot_pre_spike.m

/tetrode-analysis-matlab/chewArtifact/
waveformHasChewArtifact.m

/tetrode-analysis-matlab/conv/
makeKernel.m 

/tetrode-analysis-matlab/eeg/
contZipWith.m	
contmap.m	 
eegByArea.m

/tetrode-analysis-matlab/import/
checkMetadata.m	 
loadData.m	 
loadMwlEpoch.m	 
sampleDayLog.yaml

/tetrode-analysis-matlab/mua/
muaByArea.m

/tetrode-analysis-matlab/position/
defaultCamScales.m	 
defaultEpochCams.m

/tetrode-analysis-matlab/prelude/
filterCell.m	 
filterMapKeys.m	 
flipCFun.m	 
foldl.m	 
mapCompose.m	 
mapMap.m	 
mapReduce.m	 
sortBy.m

/tetrode-analysis-matlab/reconstruction/
smoothRpos.m

/tetrode-analysis-matlab/ripples/
burstSquarePlot.m	 
eegRipples.m - returns [cellarray of time intervals corresponding to ripples, array of ripple peak times]
evalEegRipplesParams.m	 
getBurstsOfArity.m	 
groupInterRippleIntervalsByArity.m	 
orderOfBursts.m	 
plotBurstsOnTimeseries.m	 
plotOrderedBursts.m	 
rippleBurstFirstOfArity.m	 
rippleBursts.m - Take a list of ripple peak times, collect them by how many ripples in the burst.  One cell in top-level array for burst arity. One cell in each top-level cell for each burst.
rippleMeanFreqsInSegments.m	 
rippleSpectrogramFreq.m

/tetrode-analysis-matlab/rscDips/
find_dips_frames.m	 
find_dips_frames_by_lfp.m	 
rscDipsOutline.m

/tetrode-analysis-matlab/segments/
gh_bridge_segs.m	 
gh_draw_segs.m	 
gh_event_rate_in_segments.m	 
gh_intersection_segs.m	 
gh_invert_segs.m	 
gh_points_are_in_segs.m	 
gh_points_in_segs.m	 
gh_signal_to_segs.m	 
gh_split_segs_at_trough.m	 
gh_subtract_segs.m	 
gh_union_segs.m	 
psth_in_windows.m	 
seg_criterion.m

/tetrode-analysis-matlab/stateScore/
behavioralState.m	 
drawStateScore.m	 
readme.m	 
readmeStateScore.m

/tetrode-analysis-matlab/triggeredAverage/
eegTriggeredAverage.m	 
triggeredReconstructionMergeDirections.m

/triggers/
gh_find_trig.m	 
gh_trig_lfp.m	 
trig_shift_theta.m

/trode_location/
field_xcorr_by_trode_location	 
wrt_location	 
area_dists.m	 
assign_trode_info.m	 
collect_by_group.m	 
draw_trodes.m	 
first_phase_by_trode_pos.m	 
group_of_trode.m	 
mk_trode_st_dp.m	 
mk_trodexy.m	 
plot_phase_offsets.m	 
plot_spike_phase_by_trode_pos.m	 
quick_rate_plot.m	 
quick_time_plot.m	 
spike_mod_opt.m	 
test_plot_phase_offsets.m	 
trode_colors.m	 
trode_conv.m	 
trode_draw_locations.m	 
trode_pos_and_color.m

/wave_analysis/old_drafts/
scratch_phase_pref.m
sdat_phase_pref.m	
sdat_phase_pref2.m
sdat_vs_lfp.m

/wave_analysis/quick_scratch/ 
quick_lfp_phases.m
quick_mua_phases.m

/wave_analysis/
contwin_r.m	 
disp_reg_stats.m	 
find_theta_cycles.m	 
gh_circ_nlinfit.m	 
gh_clean_phase.m	 
gh_gen_test_wave.m	 
gh_long_mua_regress.m	 
gh_long_wave_regress.m	 
gh_reg_quiver.m	 
gh_short_wave_regress.m	 
gh_various_regress.m	 
mua_vs_lfp.m	 
new_eeg_from_model.m	 
phase_pref.m	 
plane_wave_guess_beta.m	 
plane_wave_model.m	 
plane_wave_params.m	 
plane_wave_regress_frame.m	 
plane_wave_regress_slide.m	 
plot_phase_pref.m	 
plot_plane_wave_fit.m	 
post_vm.m	 
predicted_time_offset.m	 
prep_eeg_for_regress.m	 
test_plane_wave_model.m	 
wave_movie.m

/wavelet_analysis/
compute_lfp_pca.m
compute_wavelet_pca.m
display_wavelet_pca.m

/xclust_process/
copt_pxywabw_file.m - creates a binary version of a pxyabw file
velocity_filter_pxyabw_files.m
