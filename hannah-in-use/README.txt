Contents:

MATLAB
findrip.m: takes eeg data from gh_debuffer, filters it in ripple band, does a hilbert transformation, and returns times of ripple peaks
deltafilt.m: filters in the delta band (2-4)
gammafilt.m: filters in the gamma band (20-100)
getHeaderGains.m: gets gains from eeg file after opening with mwlopen
gh_debuffer: imports an ARTE .eeg file
oat2pos.n: imports OATE position csv made from extract_pos_no_HD_Arte. uses the same x and y value for front and back LEDs
ripfilt.m: filters in the ripple band (100-300)
thetafilt.m: filters in the theta band (6-10)

OTHER
extract_OATpos.py: extracts position from oate into a csv file. use this for importing to matlab
pos_extract.py: extracts position into seperate doctuments



--------

DEPRECATED (mostly AD stuff):
eeg2mat: converts file into an eeg structure
filtoptdefs: makes filter with necessary parameters for ripples, theta, gamma, and delta (calls mkfiltopt.m)
imcont: converts to eeg2mat file to continuous structure
mkfiltopt.m: makes filter options objects for use by mkfilt
mkfilt.m: makes a filter


look into:
ripple detection: mwl-gh-code/tetrode-analysis-matlab/ripples/eegRipples.m

