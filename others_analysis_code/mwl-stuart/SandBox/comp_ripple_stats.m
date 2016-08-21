function data = comp_ripple_stats(exp)
    epochs = exp.epochs;
    
    
    for ep = epochs;
        e = ep{:};
        
        eeg = exp.(e).eeg(1).data;
        ts = exp.(e).eeg_ts;
        
        filt = getfilter(exp.(e).eeg(1).fs, 'ripple', 'win');
        ripple = filtfilt(filt,1,eeg);
        hilb = abs(hilbert(ripple));
        
        rt = exp.(e).rip_burst.windows;
        
        
        data.(e).h_max = nan(length(rt),1);
        data.(e).h_mean = nan(length(rt),1);
        
        data.(e).r_max = nan(length(rt),1);
        data.(e).r_mean = nan(length(rt),1);
        
        data.(e).raw_max = nan(length(rt),1);
        data.(e).raw_mean = nan(length(rt),1);
        for i=1:length(rt)

            ind = ts>= rt(i,1) & ts<=rt(i,2);
            data.(e).r_max(i) = max(ripple(ind));
            data.(e).r_mean(i) = mean(ripple(ind));
            
            data.(e).h_max(i) = max(hilb(ind));
            data.(e).h_mean(i) = mean(hilb(ind));
            
            data.(e).raw_max(i) = max(eeg(ind));
            data.(e).raw_mean(i) = mean(eeg(ind));           
            
        end

    end
    
end
