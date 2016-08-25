Contents:

MATLAB
eeg2mat: converts file into an eeg structure
filtoptdefs: makes filter with necessary parameters for ripples, theta, gamma, and delta (calls mkfiltopt.m)
getHeaderGains.m: gets gains from eeg file after opening with mwlopen
imcont: converts to eeg2mat file to continuous structure
mkfiltopt.m: makes filter options objects for use by mkfilt
mkfilt.m: makes a filter
oat2pos.n: imports OATE position csv made from extract_pos_no_HD_Arte. uses the same x and y value for front and back LEDs

OTHER
extract_pos_no_HD_Arte: extracts position from oate into a csv file


look into:
ripple detection: mwl-gh-code/tetrode-analysis-matlab/ripples/eegRipples.m

