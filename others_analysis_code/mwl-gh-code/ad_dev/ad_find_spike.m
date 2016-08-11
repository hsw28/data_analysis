function [times,waveforms,peaks_vals] = ad_find_spikes(data1,data2,pre_trig_spike_samps,post_trig_spike_samps,threshold,timeout_samps, n_chans)
% Sandboxing a spike finder that will look like
% the one in ad2.

%%%%%%%%%%%%%%%   INPUTS & CALLER RESPONSIBILITIES    %%%%%%%%%%%%%%%%%
% data1 and data2 are the second-most and most-recenly acquired buffers.
% The calling function will write to dataA until it's full, then write to
% dataB, until it's full, then back to dataA.
% Every time a buffer fills, both buffers are passed (in a way that the
% earlier buffer is always called 1, and the later always called 2).
% This prevents edge effects from preventing us from losing spikes whose
% waveforms are closer to the edge than the desired spike width