function f = plot_xcorr_at_smooths(xcorrs)

xcorrData = xcorrs(:).xcorr;

imagesc(xcorrData);