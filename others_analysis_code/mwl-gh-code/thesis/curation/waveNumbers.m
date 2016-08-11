function r = waveNumbers()

    d0 = pwd();

    r.theta_frequency  = [];
    r.theta_wavelength = [];
    r.theta_direction  = [];
    r.r_squared        = [];
    r.r_squared_still  = [];
    
    c = curationData();
    rats = c.ca1Wave;
    for ratInd = 1:numel(rats)
    
        cd(rats{ratInd});
        m = metadata;
        if exist('d.mat')
            load d.mat
        else
            d = loadData(m,'segment_style','ml');
        end
        
        keepChan = cellfun(@(cName) ...
            any(strcmp( group_of_trode(d.trode_groups,cName), ...
            {'medial','mid','lateral'})),d.eeg_r.raw.chanlabels);
        
        ca1_eeg_r = contchans_r(d.eeg_r,'chanlabels',d.eeg_r.raw.chanlabels(keepChan));
        
        if exist('beta_data.mat')
            load beta_data.mat
        else
            warning('off');
            beta_data = gh_long_wave_regress(ca1_eeg_r,m.rat_conv_table);
            warning('on');
        end
        
        run_bouts = [d.pos_info.out_run_bouts; d.pos_info.in_run_bouts];
        keep = gh_points_are_in_segs(beta_data.timestamps, run_bouts);
        
        r.theta_frequency  = [r.theta_frequency, beta_data.est(1,keep)];
        r.theta_wavelength = [r.theta_wavelength, beta_data.est(2,keep)];
        r.theta_direction  = [r.theta_direction, beta_data.est(3,keep)];
        r.r_squared        = [r.r_squared, beta_data.r_squared(keep)];
        r.r_squared_still  = [r.r_squared_still, beta_data.r_squared(not(keep))];
        
    end
    
    
    cd(d0);  % Restore original directory
end