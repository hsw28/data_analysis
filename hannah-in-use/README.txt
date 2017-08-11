Contents:

MATLAB
FILTERING
deltafilt.m: lowpass filters in the delta band (<4)
gammafilt.m: bandpass filters in the gamma band (20-100)
lowpass20.m: lowpass filters below 20
lowpass50.m: lowpass filters below 50
lowpass300.m: lowpass filters below 300
ripfilt.m: bandpass filters in the ripple band (100-300)
thetafilt.m: bandpass filters in the theta band (6-10)

FANCIER FILTERING
findrip.m: takes eeg data from gh_debuffer and returns times of ripple peaks
abovetheta.m: finds points an inputed number of std devs above theta
belowtheta.m: finds points an inputed number of std devs below theta

THETA SHIT
firingphase.m: finds and plots the theta phase of spike data
powermap.m: plots a heat map of power by location
powerVsFiringRate.m: plots theta against firing rate
thetaphase.m: returns times of peaks in theta (0 degrees)
thetaPowerVsTime.m: plots theta power against time

COHERENCE
cohere.m: finds the coherence of two lfps
cohereruns.m: computes coherence from a starttimes, goal times, or middletimes file
cohVsFiringRate.m: finds coherence versus unit firiting rate
powermap.m: says it's for power put can also plot a heat map of coherence by location

POS/VEL/ACCEL
accel.m: finds acceleration for position data
acc_lfp.m: finds points of acceleration and plots corresponding LFPs
accelVsFiringRate.m: plots accel versus firing rate
assignpos.m assigns position to all timepoints
assignvel.m: assigns velocities to every time point
assigntic.m: assigns a tic number from the video to an event
centerdirection.m: finds direction on the center stem if the animal is going towards or away from the reward arms, point by point (for run by tun use middletimes.m)
direction.m: takes an timestamps and finds the animal's direction at times
maxaccel.m: finds times of high acceleration and returns them along with accell values
middletimes.m: run by run, finds times the animal is in the center stem and the direction of travel
normalizePosData.m: normalizes position data for time spent in each part of the track and outputs a heat map
phaseVaccel.m plots spike phase versus acceleration
placeevent.m: if you have event times, this will match with place data to get place cells or whatever
starttimes.m: finds time animal starts each trial and returns a matrix of all start & end times and index values
velocity.m: finds velocity from position data

UNITS
accelVsFiringRate.m: plots accel versus firing rate
firingphase.m: finds and plots the theta phase of spike data
isi.m: finds interspike interval
normalizePosData.m: normalizes position data for time spent in each part of the track and outputs a heat map
phaseVaccel.m plots spike phase versus acceleration
placeevent.m: if you have event times, this will match with place data to get place cells or whatever
powerVsFiringRate.m: plots theta against firing rate
rasterplot.m: makes a raster plot
spikehisto.m: makes a vector of  the number of spikes per bin for a histogram of spikes. also good for autocorr
spiketrain.m: makes a spike train of data
STA.m: finds spike triggered average

COMPARISIONS/FREQUENCIES
acc_lfp.m: finds points of acceleration and plots corresponding LFPs
cohVsFiringRate.m: finds coherence versus unit firiting rate
compareISI.m: compares and plots some thing (acc, phase, power, etc) to ISI
corr.m: finds the cross correlation and plots
findLSFrequencies: finds all LS events and makes a frequency plot of them
LSevents.m: finds LS events
LSlfpcompare.m:  takes raw LS LFP and finds the weird LS events and the time and duration, then plots the LFP for the other thing youre looking for during the same time
orderLSevent.m: plots LS events in order by duration
powerMap.m: plots power by location
psth.m: makes a psth graph of events around a trigger point
spikehisto.m: makes a histogram of spikes in binned time

BULK
uipickfiles.m: lets you pick files and puts path into an array (not my code)
clusterimport.m: outputs a structure of all cluster times imported from uipickfiles
posimport.m: outputs a structure of pos/vel/acc from imported pos files from uipickfiles
timeimport.m: outputs a structure of multiple lfp times from files selected with uipickfiles
MASSaccelVsFiringRate.m: does acceleration vs firing rates for tons of clusters at once using bulk data

RANDOM
binning.m: bins stuff
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
