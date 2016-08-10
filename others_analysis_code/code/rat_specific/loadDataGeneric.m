function d = loadDataGeneric(m,varargin)

error('DEPRICATED - use loadData in ($TCM)/import/');

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('loadEEG',true);
p.addParamValue('loadMUA',true);
p.addParamValue('loadSpikes',true);
p.parse(varargin{:});

if(isempty(p.Results.timewin))
    timewin = m.loadTimewin;
else
    timewin = p.Results.timewin;
end

dayOfWeek = m.today(3:4);

d.epochs = loadMwlEpoch('filename',[m.basePath, '/epoch.epoch']);

if(~m.checkedArteCorrectionFactor)
    warning('loadDataGeneric:noCorrectionFactor',...
        'Using an un-checked correction factor');
end

if(p.Results.loadEEG)
d.eeg = quick_eeg('timewin',timewin,...
 'file1', m.f1File, 'f1_ind', m.f1Inds, 'f1_chanlabels', m.f1TrodeLabels, ...
 'file2', m.f2File, 'f2_ind', m.f2Inds, 'f2_chanlabels', m.f2TrodeLabels, ...
 'file3', m.f3File, 'f3_ind', m.f3Inds, 'f3_chanlabels', m.f3TrodeLabels, ...
 'file4', m.f4File, 'f4_ind', m.f4Inds, 'f4_chanlabels', m.f4TrodeLabels, ...
 'system_list',m.systemList,'sort_areas',true,'arte_correction_factor',m.arteCorrectionFactor,'samplerate',1000);
end

if(p.Results.loadMUA)
d.mua = mua_at_date(m.today, m.mua_filelist_fn, 'keep_groups', m.keepGroups,...
    'trode_groups', m.trode_groups_fn, 'timewin', m.loadTimewin, 'arte_correction_factor',m.arteCorrectionFactor,...
    'ad_trodes',m.ad_tts,'arte_trodes',m.arte_tts,'width_window',m.width_window,'threshold',m.threshold);
end

if(p.Results.loadSpikes)
d.spikes = imspike('spikes','arte_correction_factor',m.arteCorrectionFactor,...
    'ad_dirs',cmap(@(x) [x,dayOfWeek], m.ad_tts),'arte_dirs',cmap(@(x) [x,dayOfWeek],m.arte_tts)  );
end

if(~m.checkedArteCorrectionFactor)
    warning('loadDataGeneric:uncheckedCorrectionFactor',...
        'This day''s correction factor hasn''t been checked');
end