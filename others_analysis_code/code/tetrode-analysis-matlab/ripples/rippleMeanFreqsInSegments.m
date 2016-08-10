function meanFreqs = rippleMeanFreqsInSegments(rippleFreqs, ...
                                               rippleWindows)
    ts = conttimestamp(rippleFreqs);
    f = mean(rippleFreqs.data,2);
    meanFreqs = cmap( @(w) mean(f(ts >= w(1) & ts <= w(2))), ...
                      rippleWindows);
    meanFreqs = cell2mat(meanFreqs);
    meanFrexs = meanFreqs(~isnan(meanFreqs));
    meanFreqs = meanFreqs(meanFreqs < 100);
end