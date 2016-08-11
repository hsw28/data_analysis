function f = rippleDipXCorr(rippleEnv, dipEnv, smoothSubtractSec,timewin)

rippleEnv = contwin(rippleEnv,timewin);
rippleEnv.data(isnan(rippleEnv.data)) = 0;
rippleEnv.data = mean(rippleEnv.data,2);

dipEnv = contwin(dipEnv,timewin);
dipEnv.data(isnan(dipEnv.data)) = 0;
dipEnv.data = mean(dipEnv.data,2);

ts = conttimestamp(rippleEnv);
dt = ts(2)-ts(1);
nSmooth = smoothSubtractSec / dt;
rippleEnvSmooth = rippleEnv;
rippleEnvSmooth.data = smooth(rippleEnvSmooth.data, nSmooth);
rippleEnv.data = rippleEnv.data - rippleEnvSmooth.data;

ts = conttimestamp(dipEnv);
dt = ts(2) - ts(1);
nSmooth = smoothSubtractSec / dt;
dipEnvSmooth = dipEnv;
dipEnvSmooth.data = smooth(dipEnvSmooth.data, nSmooth,'moving');
dipEnv.data = dipEnv.data - dipEnvSmooth.data;

maxLagSec = 5;
maxNLag = maxLagSec / dt;

[x,lags] = xcorr(rippleEnv.data, dipEnv.data, floor(maxNLag),'coeff');

plot(lags * dt, x,'LineWidth',3);