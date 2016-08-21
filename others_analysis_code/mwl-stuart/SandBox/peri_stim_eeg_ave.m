function [traces bins] = peri_stim_eeg_ave(eeg,eegTs, triggers, nSamples)

bins = -nSamples:nSamples;
nbins = numel(bins);
traces = zeros(numel(triggers), nbins);
idx = interp1(eegTs, 1:numel(eegTs), triggers, 'nearest');
idx = idx(idx>nSamples+1);
idx = idx(idx<(numel(eegTs)-nbins));
for i=1:numel(idx)
    traces(i,:) =  eeg(idx(i)+bins);
end
