%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               LFP ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Data
 clc;
ripples = dset_load_ripples;

%% - XCorr the ripple bands
rippleXCorr.run = calc_bilateral_ripple_band_xcorr('run');
rippleXCorr.sleep = calc_bilateral_ripple_band_xcorr('sleep');
rippleXCorr.sleep2.xcorrCont = rippleXCorr.sleep.xcorrCont(:,[1:7,9:end]);
rippleXCorr.sleep2.xcorrIpsi = rippleXCorr.sleep.xcorrIpsi(:,[1:7,9:end]);

%%
plot_bilateral_ripple_band_xcorr(rippleXCorr.run); title('Run');
plot_bilateral_ripple_band_xcorr(rippleXCorr.sleep2); title('Sleep');

%% - Bilateral Ripple Coherence

% This statistic is computed as ripSignalBase vs ripSignalCont
% the shuffles are derived from shuffling the contra-lateral signal.
% the base signal is always more coherent with itself than it is with a
% contralateral channel.  So if the two signals are considered to be the
% same, then a shuffled cont should work like a shuffled base?!?!


rippleCoherence.run = calc_bilateral_ripple_coherence(ripples.run);
rippleCoherence.sleep = calc_bilateral_ripple_coherence(ripples.sleep);

save ~/data/thesis/bilateral_ripple_coherence.mat rippleCoherence;

f = plot_bilateral_ripple_coherence(rippleCoherence.run); set(f,'Name','RUN');
f = plot_bilateral_ripple_coherence(rippleCoherence.sleep); set(f,'Name', 'SLEEP');

%% - Bilateral Ripple Frequency Correlations
clearvars -except ripples

rippleFreqCorr.run.spec =  calc_bilateral_ripple_freq_correlations_spec(ripples.run);
rippleFreqCorr.sleep.spec = calc_bilateral_ripple_freq_correlations_spec(ripples.sleep);
rippleFreqCorr.run.mean = calc_bilateral_ripple_freq_correlations_mean(ripples.run);
rippleFreqCorr.sleep.mean = calc_bilateral_ripple_freq_correlations_mean(ripples.sleep);

save ~/data/thesis/bilateral_ripple_frequency_correlation.mat rippleFreqCorr;
%%
f = plot_bilateral_ripple_freq_correlations(rippleFreqCorr.run); set(f,'name', 'RUN');
f = plot_bilateral_ripple_freq_correlations(rippleFreqCorr.sleep); set(f,'name', 'SLEEP');

%% Bilateral ripple frequency distribution
plot_bilateral_ripple_freq_distribution(ripples.run); set(gcf,'name','Run');
plot_bilateral_ripple_freq_distribution(ripples.sleep); set(gcf,'name','Run');


%% - Mean LFP triggered on ripples
meanRipTrigLfp.run = calc_ripple_triggered_mean_lfp(ripples.run);
meanRipTrigLfp.sleep = calc_ripple_triggered_mean_lfp(ripples.sleep);
%
plot_ripple_trig_lfp(meanRipTrigLfp.run); title('RUN');
plot_ripple_trig_lfp(meanRipTrigLfp.sleep); title('SLEEP');

%% - Compute the difference in ripple phases between the hemispheres
ripplePhaseDiff.run = calc_bilateral_ripple_phase_diff(ripples.run);
ripplePhaseDiff.sleep = calc_bilateral_ripple_phase_diff(ripples.sleep);

nEvent = numel(ripplePhaseDiff.sleep.p1);
uPts = linspace(-pi, pi, 30);
uCdf = unifcdf( uPts, -pi, pi);
[~, p1] = kstest(ripplePhaseDiff.sleep.dPhase, [uPts', uCdf']);
[~, p2] = chi2gof(ripplePhaseDiff.sleep.dPhase, 'cdf', @(x) unifcdf(x, -pi, pi));

%% - Distribution of Bilateral Ripple Freq Differences



%% - Ripple triggered LFP Averages

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               UNIT AND DECODING ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

%% Load Data and compute reconstruction
%[recon.stats, recon.replay] = dset_calc_replay_with_stats(d);

runReconFiles = dset_get_recon_file_list('run');
sleepReconFiles = dset_get_recon_file_list('sleep');

%% Correlate the number of spikes and the replay score between hemispheres

[eventCorr.run, eventData.run] = calc_correlation_between_nspike_replay_score('run');
plot_correlation_between_nspike_replay_score(eventCorr.run, eventData.run);

%% Correlate the replay scores between the two hemispheres
%unilatReplayStatsCorr = calc_unilateral_replay_bilateral_correlations(d, recon.replay, recon.stats);

%% Correlate the individual columns of the replay PDFS 
bilatReplayCorr.run = calc_unilateral_replay_bilateral_pdf_correlation('run');
plot_unilateral_replay_bilateral_pdf_correlation(bilatReplayCorr.run);




%% Determine whidh UNILATERAL events are significant
nShuffle = 100;
[lIdx, rIdx, bIdx] = dset_calc_cl_idx(d);
smoothPdf = 1;
shuffles = [0 1 0 0 0];
[replayShuf.L, shufNames] = dset_calc_replay_shuffle_scores(d, recon.replay.L, nShuffle, recon.stats.L.slope, recon.stats.L.intercept, lIdx, shuffles, smoothPdf, 0);
[replayShuf.R] = dset_calc_replay_shuffle_scores(d, recon.replay.R, nShuffle, recon.stats.R.slope, recon.stats.R.intercept, rIdx, shuffles, smoothPdf, 0);

pVal.L = dset_calc_replay_significance(recon.stats.L, replayShuf.L, .05);
pVal.R = dset_calc_replay_significance(recon.stats.R, replayShuf.R, .05);


%% NO MORE ANALYSIS UNDER HERE!!!!
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              DEBUGGING AREA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
rippleCoherence.run = calc_bilateral_ripple_coherence(ripples.run);
f = plot_bilateral_ripple_coherence(rippleCoherence.run); set(f,'Name','RUN');


%% - Mean LFP triggered on ripples

for i = 1:numel(ripples.run)
    %meanRipTrigLfp.run = calc_ripple_triggered_mean_lfp(ripples.run(i));
    meanRipTrigLfp.sleep = calc_ripple_triggered_mean_lfp(ripples.sleep(i));
%
    %plot_ripple_trig_lfp(meanRipTrigLfp.run); title('RUN');
    
    plot_ripple_trig_lfp(meanRipTrigLfp.sleep); title('SLEEP');
    set(gcf,'Name', [ripples.run(i).description, num2str(i)]);
end