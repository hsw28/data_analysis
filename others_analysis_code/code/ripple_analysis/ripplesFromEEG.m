function ripples = ripplesFromEEG(eeg,varargin)

error('DEPRICATED.  Use eegRipples.m')

p = inputParser();
p.addParamValue('envSampleRate', min(250, eeg.samplerate));
p.addParamValue('peakBeyondMeanStd', 3);
p.addParamValue('edgeBeyondMeanSdt', 0);
p.addParamValue('min_width_pre_bridge',0.03);
p.addParamValue('bridge_max_gap', 0.005);
p.addParamValue('minFracAgreement', 0.2);
p.parse(varargin{:});
opt = p.Results;

nChan = size(eeg.data,2);
resampFrac = opt.envSampleRate / eeg.samplerate;

% Preallocate space for whether ripple is happing at each timepoint
isRip = contresamp( eeg, 'resample', resampFrac );

isRipTS = conttimestamp(isRip);

for c = 1:nChan
    thisCdat = contchans(eeg,'chans',c);
    [~,~,thisEnv] = gh_ripple_filt(thisCdat);
    thisEnv = contresamp(thisEnv,'resample',resampFrac);
    peakThresh = mean(thisEnv.data) + stdev(thisEnv.data)*opt.peakBeyondMeanStd;
    edgeThresh = mean(thisEnv.data) + stdev(thisEnv.data)*opt.edgeBeyondMeanStd;

    ripple_segs = seg_criterion('name','singleChanLfpRippleCriteria',...
        'peak_min', opt.peakThresh, 'min_width_pre_bridge', opt.min_width_pre_bridge);


end

