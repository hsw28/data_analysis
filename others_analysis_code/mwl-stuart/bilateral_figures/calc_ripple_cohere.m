

clear; clc;
ripples = dset_load_ripples;

rippleCoherence.run = calc_bilateral_ripple_coherence(ripples.run);
rippleCoherence.sleep = calc_bilateral_ripple_coherence(ripples.sleep);

save ~/data/thesis/bilateral_ripple_coherence.mat rippleCoherence;
disp('Saved bilateral_ripple_cohere.mat');
