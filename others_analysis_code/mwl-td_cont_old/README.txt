CONTENTS:

/Cont
contbootstrap - empty
contbouts – finds above threshold periods of a signal in a construct
contboutsbool – finds periods in a contdata structure when a given fn is true
contchans – extracts/removes channels from contdata structure
contcombine – combines several cont structures, interpolating data
contdatarange – updates datarange field of a contdata structure
contdiff – takes the diff of the signal
contenv –  gets the signal envelope 
contfilt – filters a contdata structure
contfn – applies a function to the data in a contdata structure
continterp – resamples and interpolates cont structure data to match timestamps
contlocalmax – applies localmax to each channel of a contdata structure and returns the time of peaks
contmean – returns the mean of channels in a construct
contphase – returns a cdat with the unwrapped phase of the input
contresamp – resamples data in a cont structure and returns new cont structure. Does appropriate filtering (meaning??)
contsegdata – gets raw data points from segments, no time info
contsegmean – measures mean/std/s.e.m. in windows during segments
contwin – selects a time window from a larger cdat structure
contwinsamp – selects a window of samples from a larger cdat structure
contxcorr – does an xcorr between 2 data channels, 2 data structures, or an autocorrelation on 1 channel/structure
imcont – makes a contdata structure from time series/mwl eeg structure/.eeg file
imconthist – makes contdata structure from event list (histogram)


/obj
mkcache – makes or updates a cache of objects
obj_cachesearch – does a cache search on an object
obj_cleanup - ?
obj_reparse -  parses ‘template’ args, does some other setup, for OBJs (???)

/obj/defs
filtoptdefs: generates common filters for eeg (theta, beta, ripple)

/obj/filt
mkenvopt – makes filter objions objects for use by mkfilt
mkfilt – makes filter objects with design parameters
mkfiltopt – makes filter options objects for use by mkfilt (unclear how different from mkenvopt)

/util
db2num – converts value in decibels to fraction
gausswindsd - ?
getGains – helper function for mwlIO filehandle to get gains from eeg file
hatwindow – creates a 1-D ‘mexican hat’ window
localmax – finds indexes of local maxima in an array
parseArgsLite – helper function for parsing varargin
sem – calculates the standard error of the mean of the samples in X
