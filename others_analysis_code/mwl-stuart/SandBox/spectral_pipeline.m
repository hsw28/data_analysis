
ind = 1:10000;
e_dat = gh.control.eeg(1);
e_dat.data = e_dat.data(ind);
ts = gh.control.eeg_ts(ind);

f1 = getfilter(e_dat.fs, 'theta', 'win');
f2 = getfilter(e_dat.fs, 'ripple', 'win');

theta = filtfilt(f1,1,e_dat.data(ind));
ripple = filtfilt(f2,1,e_dat.data);


a(1) = axes('Units', 'normalized', 'Position', [0 .67 1 .33]);
line_browser(e_dat.data, ts, a(1));

a(2) = axes('Units', 'normalized', 'Position', [0 .34 1 .33]);
line_browser(theta, ts, a(2));

a(3) = axes('Units', 'normalized', 'Position', [0 .0 1 .34]);
line_browser(ripple, ts, a(3));

set(a, 'XTick', [], 'YTick', []);
linkaxes(a, 'x');

b1 = min(e_dat.data):.01:max(e_dat.data);
b2 = min(theta):.01:max(theta);
b3 = min(ripple):.01:max(ripple);

figure;
h1 = hist(e_dat.data, b1);
h2 = hist(theta, b2);
h3 = hist(ripple, b3);
h1 = smoothn(h1,10);
h2 = smoothn(h2,10);
h3 = smoothn(h3,10);
plot(b1,h1, b2, h2, b3,h3);


