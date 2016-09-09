Contents:

MATLAB
FILTERING
deltafilt.m: lowpass filters in the delta band (<4)
gammafilt.m: bandpass filters in the gamma band (20-100)
ripfilt.m: bandpass filters in the ripple band (100-300)
thetafilt.m: bandpass filters in the theta band (6-10)

velocity.m: finds velocity from position data
assignvel.m: assigns velocities to every time point

abovetheta.m: finds points an inputed number of std devs above theta
belowtheta.m: finds points an inputed number of std devs below theta

eventcorr.m -- not sure (lol)
findrip.m: takes eeg data from gh_debuffer, filters it in ripple band, does a hilbert transformation, and returns times of ripple peaks
getHeaderGains.m: gets gains from eeg file after opening with mwlopen
gh_debuffer.m: imports an ARTE .eeg file
kw.m: performs a Kruskal-Wallis test on two groups of data
mua_rate.m: finds rate of MUA, outputs as number of spikes per time bin
oat2pos.m: imports OATE position csv made from extract_pos_no_HD_Arte. uses the same x and y value for front and back LEDs
psth.m: makes a psth graph of events around a trigger point
specto.m: creates a spectograph from raw lfps

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


