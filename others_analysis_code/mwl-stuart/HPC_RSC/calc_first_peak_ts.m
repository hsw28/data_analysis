function pkTs = calc_first_peak_ts( events, ts, rate)

    nEvent = size(events,1);
    
    [~, pIdx] = findpeaks(rate);
    pTs = ts(pIdx);
    
    pkTs = nan(size(events,1),1);
    
    for iEvent = 1:nEvent
        
        b = events(iEvent,:);
        
        t = pTs( find( pTs >= b(1) & pTs<= b(2), 1,'first' ) );
        if isempty(t)
            continue;
        end
        pkTs(iEvent) =  t;
        
    end
    
end