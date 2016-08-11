function xcorrs = xcorr_at_smooths (dip_points, ripple_points, varargin)
% Compute the xcorr of dip times and ripple times at multiple smoothing kernels

defaultMaxLagSec = 20;
defaultTimewin = [ min( [min(dip_points), min(ripple_points)]), ...
    max( [max(dip_points), max(ripple_points)]) ] + [-1.5,1.5]*defaultMaxLagSec;
okSmoothScales = {'linear','log'};
defaultSmoothScale = 'log';
defaultNSmooths = 6;
defaultSmoothLims = [0.01,10];

p = inputParser();
p.addParamValue('timewin',defaultTimewin);
p.addParamValue('smoothScale',defaultSmoothScale,@(x) any(strcmp(x,okSmoothScales)));
p.addParamValue('nSmooths', defaultNSmooths);
p.addParamValue('smoothLims', defaultSmoothLims);
p.addParamValue('xcorrSampleRate',200);
p.addParamValue('xcorrMaxLagSec', defaultMaxLagSec);
p.addParamValue('onlyZeroLag',false);
p.parse(varargin{:});
opt = p.Results;

if(strcmp(opt.smoothScale,'linear'))
    smooths = linspace( opt.smoothLims(1), opt.smoothLims(2), opt.nSmooths );
elseif(strcmp(opt.smoothScale,'log'))
    smooths = logspace( log10(opt.smoothLims(1)), ...
        log10(opt.smoothLims(2)), opt.nSmooths);
end

dt = 1/opt.xcorrSampleRate;
nLagOneSide = ceil( opt.xcorrMaxLagSec / dt );
lagSamps = [-nLagOneSide : 1 : nLagOneSide];

if(opt.onlyZeroLag)
    nLagOneSide = 0;
    lagSamps = 0;
end

xcorrs.ts = linspace( (-opt.xcorrMaxLagSec), opt.xcorrMaxLagSec, numel(lagSamps));
xcorrs.data = struct('smoothSD',cell(1,numel(smooths)),'xcorr',cell(1,numel(smooths)));

% Timecourses' time samples
tsTC = opt.timewin(1):dt:opt.timewin(2);

for n = 1:numel(smooths)

    dipTC = ksdensity    ( dip_points,    tsTC, 'width', smooths(n) );
    rippleTC = ksdensity ( ripple_points, tsTC, 'width', smooths(n) );

    xcorrs.data(n).smoothSD = smooths(n);
    xcorrs.data(n).xcorr = xcorr( dipTC, rippleTC, nLagOneSide, 'coeff' );
end