function i = loadInterneuronData(d,m)

    mua_spike_width = [0,11];
    mua_thresh      = 65;
    i.mua = mua_at_date(m.today, m.mua_filelist_fn, 'keep_groups', m.keepGroups,...
    'trode_groups', m.trode_groups_fn, 'timewin', m.loadTimewin, 'arte_correction_factor',m.arteCorrectionFactor,...
    'ad_trodes',m.ad_tts,'arte_trodes',m.arte_tts,'width_window',mua_spike_width,'threshold',mua_thresh, ...
    'segment_style', 'areas');
    [~,i.mua_rate] = assign_rate_by_time(d.mua,'timewin',m.loadTimewin,'samplerate',400,'gauss_sd_sec',0.04);    

    [i.muaTheta, i.muaEnv, i.muaPhase] = gh_theta_filt(i.mua_rate);
    
    i.mua = assign_theta_phase(i.mua, ...
        contchans_r(d.eeg_r,'chanlabels',[m.singleThetaChan]),...
        'lfp_default_chan',m.singleThetaChan,...
        'power_threshold',0.02);
    
    
    
    
end