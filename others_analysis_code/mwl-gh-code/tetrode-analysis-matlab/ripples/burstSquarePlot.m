function burstSquarePlot(peakTimes)

preIntervals  = diff(peakTimes(1:(end-1)));
postIntervals = diff(peakTimes(2:end));

loglog(postIntervals,preIntervals,'.');
