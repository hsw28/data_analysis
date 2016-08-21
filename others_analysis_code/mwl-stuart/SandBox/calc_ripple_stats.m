function data = calc_ripple_stats(exp)
    epochs = exp.epochs;
    
    
    for ep = epochs;
        e = ep{:};
        
        eeg = exp.(e).eeg(1).data;
        ts = exp.(e).eeg_ts;
        
        filt = getfilter(exp.(e).eeg(1).fs, 'ripple', 'win');
        ripple = filtfilt(filt,1,eeg);
        hilb = abs(hilbert(ripple));
        
        rt = exp.(e).rip_burst.windows;
        
        
        %data.(e).h_max = nan(length(rt),1);
        %data.(e).h_mean = nan(length(rt),1);
        %data.(e).h_diff = nan(length(rt),1);
        
        %data.(e).r_max = nan(length(rt),1);
        %data.(e).r_mean = nan(length(rt),1);
        %data.(e).r_diff = nan(length(rt),1);
        data.(e).h_sum = nan(length(rt),1);
        
        %data.(e).raw_max = nan(length(rt),1);
        %data.(e).raw_mean = nan(length(rt),1);
        %data.(e).raw_diff = nan(length(rt),1);
        c = 0;
        for i=1:length(rt)

            dt = rt(i,2) - rt(i,1);
            if  dt >= .05 && dt <=1.5
                c = c +1;
                ind = ts>= rt(i,1) & ts<=rt(i,2);
                %data.(e).r_max(c) = max(ripple(ind));
                %data.(e).r_mean(c) = mean(ripple(ind));
                %data.(e).r_diff(c) = max(ripple(ind)) - min(ripple(ind));
                


                %data.(e).h_max(c) = max(hilb(ind));
                %data.(e).h_mean(c) = mean(hilb(ind));
                %data.(e).h_diff(c) = max(hilb(ind)) - min(hilb(ind));
               
                data.(e).h_sum(c) = sum(hilb(ind)) / dt;

         %       data.(e).raw_max(c) = max(eeg(ind));
         %       data.(e).raw_mean(c) = mean(eeg(ind));           
         %       data.(e).r_diff(c) = max(ripple(ind)) - min(ripple(ind));
                
            end
            %{
                data.(e).r_max  = data.(e).r_max(~isnan(data.(e).r_max));
                data.(e).r_mean = data.(e).r_mean(~isnan(data.(e).r_mean));
                data.(e).r_diff = data.(e).r_diff(~isnan(data.(e).r_diff));
                
                data.(e).h_max  = data.(e).h_max(~isnan(data.(e).h_max));
                data.(e).h_mean = data.(e).h_mean(~isnan(data.(e).h_mean));
                data.(e).h_diff = data.(e).h_diff(~isnan(data.(e).h_diff));

%}
  
                
          %      data.(e).raw_max  = data.(e).raw_max(~isnan(data.(e).raw_max));
          %      data.(e).raw_mean = data.(e).raw_mean(~isnan(data.(e).raw_mean));
          %      data.(e).raw_diff = data.(e).raw_max - data.(e).raw_mean;
        end

    end
    
end

%%

