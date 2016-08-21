function trighist = EventTrigHist(trigtimes, events, binsize, time_bef_trig, time_aft_trig)

% just make sure all inputs are on the same timescale!

% set up output array
bins = -time_bef_trig:binsize:time_aft_trig;
trighist = zeros(length(trigtimes), length(bins));

for i=1:length(trigtimes)
    
    trighist(i,:) = histc(events, trigtimes(i) - (-1*bins));
    
end
