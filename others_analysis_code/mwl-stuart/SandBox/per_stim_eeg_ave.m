function [counts centers] = per_stim_eeg_ave(eeg,eegTs, triggers, nSamples)

bins = -nSamples:nSamples;
nbins = numel(bins);
traces = zeros(numel(triggers), nbins);

for i=1:numel(triggers)
    idx = interp1(eegTs, 1:numel(eegTs), triggers(i));
    traces(i,:) =  eeg(idx+bins);
end
