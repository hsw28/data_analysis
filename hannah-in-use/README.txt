Contents:

MATLAB
FILTERING
deltafilt.m: lowpass filters in the delta band (<4)
gammafilt.m: bandpass filters in the gamma band (20-100)
lowpass300.m: lowpass filters below 300
ripfilt.m: bandpass filters in the ripple band (100-300)
thetafilt.m: bandpass filters in the theta band (6-10)

FANCIER FILTERING
findrip.m: takes eeg data from gh_debuffer and returns times of ripple peaks
abovetheta.m: finds points an inputed number of std devs above theta
belowtheta.m: finds points an inputed number of std devs below theta

POS/VEL/ACCEL
accel.m: finds acceleration for position data
acc_lfp.m: finds points of acceleration and plots corresponding LFPs
assignvel.m: assigns velocities to every time point
assigntic.m: assigns a tic number from the video to an event
direction.m: takes an timestamps and finds the animal's direction at times
velocity.m: finds velocity from position data
placeevent.m: if you have event times, this will match with place data to get place cells or whatever

COMPARISIONS
acc_lfp.m: finds points of acceleration and plots corresponding LFPs
LSlfpcompare.m:  takes raw LS LFP and finds the weird LS events and the time and duration, then plots the LFP for the other thing youre looking for during the same time
orderLSevent.m: plots LS events in order by duration

RANDOM
boundedline.m: shades bounds around a line
eventcorr.m -- not sure (lol)
getHeaderGains.m: gets gains from eeg file after opening with mwlopen
gh_debuffer.m: imports an ARTE .eeg file
kw.m: performs a Kruskal-Wallis test on two groups of data
mua_rate.m: finds rate of MUA, outputs as number of spikes per time bin
oat2pos.m: imports OATE position csv to binary. uses the same x and y value for front and back LEDs
psth.m: makes a psth graph of events around a trigger point
specto.m: creates a spectograph from raw lfps

OTHER (mostly python)
extract_OATpos.py: extracts position from oate into a csv file. use this for importing to matlab
pos_extract.py: extracts position into seperate doctuments



--------

DEPRECATED (mostly AD stuff):
eeg2mat: converts file into an eeg structure
filtoptdefs: makes filter with necessary parameters for ripples, theta, gamma, and delta (calls mkfiltopt.m)
imcont: converts to eeg2mat file to continuous structure
mkfiltopt.m: makes filter options objects for use by mkfilt
mkfilt.m: makes a filter


