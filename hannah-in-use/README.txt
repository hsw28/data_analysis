Contents:

MATLAB
FILTERING
deltafilt.m: lowpass filters in the delta band (<4)
filter812.m: filters in 8-12hz
gammafilt.m: bandpass filters in the gamma band (20-100)
lowpass4.m: lowerpass filters below 4
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
chunkingrungs.m: chunks H maze into times in each arm (forced, center, reward) of maze
derivative_dwt.m: differentiation (derivative) of sampled data based on discrete wavelet transform
direction.m: takes an timestamps and finds the animal's direction at times
maxaccel.m: finds times of high acceleration and returns them along with accell values
middletimes.m: run by run, finds times the animal is in the center stem and the direction of travel
middlevel.m: gets velocity times for middle runs
movementunits.m: returns units only when the animal is actually running
noiselessVelocity.m: computes velocity in a supposedly smoother way
normalizePosData.m: normalizes position data for time spent in each part of the track and outputs a heat map
phaseVaccel.m plots spike phase versus acceleration
placeevent.m: if you have event times, this will match with place data to get place cells or whatever
rewardtimes.m: tells you the time animal went to reward site and amount of time spent there
spikeprobrun.m: bins vel/acc then finds spiking prob for each acc/vel bin
starttimes.m: finds time animal starts each trial and returns a matrix of all start & end times and index values
velocity.m: finds velocity from position data
veltimes.m: tells you the time animal was below a particular velocity

UNITS
accelVsFiringRate.m: plots accel versus firing rate
firingphase.m: finds and plots the theta phase of spike data
isi.m: finds interspike interval
isiShuffle.m: shuffles data for ISI analysis
movementunits.m: returns units only when the animal is actually running
phaseVaccel.m plots spike phase versus acceleration
placeevent.m: if you have event times, this will match with place data to get place cells or whatever
powerVsFiringRate.m: plots theta against firing rate
rasterplot.m: makes a raster plot
spiketrain.m: makes a spike train of data
STA.m: finds spike triggered average
STAfake.m: plots a real spike triggered average and a fake spike striggered average on same graph
STAshuffledStats.m: shuffles data to get a STA for random data

COMPARISIONS/FREQUENCIES
acc_lfp.m: finds points of acceleration and plots corresponding LFPs
cohVsFiringRate.m: finds coherence versus unit firiting rate
compareISI.m: compares and plots some thing (acc, phase, power, etc) to ISI
corr.m: finds the cross correlation and plots
findLSFrequencies: finds all LS events and makes a frequency plot of them
lfpfreq.m: takes LFP and finds power spectrum. does NOT filter in any way
LSevents.m: finds LS events
LSlfpcompare.m:  takes raw LS LFP and finds the weird LS events and the time and duration, then plots the LFP for the other thing youre looking for during the same time
orderLSevent.m: plots LS events in order by duration
powerMap.m: plots power by location
psth.m: makes a psth graph of events around a trigger point
slidingWindowCorr.m: Plots the max autocorrelation value calculated for a window of specified length across time
spectralPowerVsTime.m: Plots the power of frequency bands specified in bins against time
spikehisto.m: makes a histogram of spikes in binned time

BULK
clusterimport.m: takes clusters found using uipickfiles and makes a structure of clusters
MASSaccelVsFiringRate.m: does a mass correlation of cluster firing versus accel, across days
MASSchunkingruns.m: chunks multiple runs into run number and place in run and returns structure
MASSCHUNKaccVsFiringRate.m: does same as MASSaccelVsFiringRate.m but for one day and with H maze runs chunked by position
MASSCHUNKcorrFiringRate.m: takes clusters from one day and correlates firing with acc and vel for different parts of maze
MASSCHUNKvelVsFiringRate.m: does same as MASSvelVsFiringRate.m but for one day and with H maze runs chunked by position
MASSrewardratios: input entry time to reward box on maze, tells you spiking difference between pre entry and entry
MASSskinnerratios: input cue time, tells you spiking difference between intertrial, cue, and reward
MASSvelVsFiringRate.m: does a mass correlation of cluster firing versus vel, across days
posimport.m: takes pos files found using uipickfiles and makes a structure of pos/vel/acc
timeimport.m: takes lfps found using uipickfiles and makes a structure of time data

DECODE
binAcc.m: bins actual velocities in same bins as decode shit, so you can compare your decoded data
binVel.m: bins actual accelerations in same bins as decode shit, so you can compare your decoded data
decodeshit.m: decodes velocity based on cell firing
decodeshitACC.m: decodes acceleration based on cell firing
firingPerAcc.m: outputs average firing rate per acceleration
firingPerVel.m: outputs average firing rate per velocity

WHEEL
wheelPos.m: cleans up wheel data and interpolates data for all time points, returning XY coord and degrees
wheelACCEL.m: accel of rotating wheel
wheelVEL.m: vel of rotating wheel
wheelwrap.m: unwraps degree data

RANDOM
assigntic.m: outputs times of a video tic mark
binning.m: bins stuff
boundedline.m: shades bounds around a line
eventcorr.m -- not sure (lol)
getHeaderGains.m: gets gains from eeg file after opening with mwlopen
gh_debuffer.m: imports an ARTE .eeg file
glmtest!.m: constantly in prep, but for generalized linear models
kw.m: performs a Kruskal-Wallis test on two groups of data
mua_rate.m: finds rate of MUA, outputs as number of spikes per time bin
oat2pos.m: imports OATE position csv to binary. uses the same x and y value for front and back LEDs
plotLFP.m: plots all 8 LFPs from one lfp set
psth.m: makes a psth graph of events around a trigger point
randomlfp.m: randomizes LFP data
randomunits.m: makes fake unit data, enter time and number of units you want
specto.m: creates a spectograph from raw lfps

OTHER (mostly python)
extract_OATpos.py: extracts position from oate into a csv file. use this for importing to matlab
extract_tick.py: extracts times and video tick marks
pos_extract.py: extracts position into seperate doctuments



--------

DEPRECATED (mostly AD stuff):
eeg2mat: converts file into an eeg structure
filtoptdefs: makes filter with necessary parameters for ripples, theta, gamma, and delta (calls mkfiltopt.m)
imcont: converts to eeg2mat file to continuous structure
mkfiltopt.m: makes filter options objects for use by mkfilt
mkfilt.m: makes a filter
