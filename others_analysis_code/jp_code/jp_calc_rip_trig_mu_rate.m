function [samp, sampTs] = jp_calc_rip_trig_mu_rate(ripTs, mua, win)

    if nargin==2
        win = [-.25 .75];
    end  

    [samp, sampTs] = meanTriggeredSignal(ripTs, mua.timestamps, mua.rate, win); 
    
end

