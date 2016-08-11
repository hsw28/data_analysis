function xc = dip_ripple_env_xcorr( rippleEnv, dipEnv, varargin )

p = inputParser();
p.addParamValue('smoothSec',0.5);
p.addParamValue('maxLagSec',10);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

rF = rippleEnv.samplerate;
dF = dipEnv.samplerate;

if( abs(rF-dF) / (rF+dF) > 0.01 )
    error('dip_ripple_env_xcorr:unsynchronized_inputs','rippleEnv and dipEnv on very different timebases');
end

nLag = ceil( opt.maxLagSec * ripple_env.samplerate );

lags = (-nLag):1:nLag;
lagsSec = lags / rF;

xs = xcorr( mean(rippleEnv.data,2)', mean(dipEnv.data,2)', nLag, 'coeff' );

xc.ts = lagsSec;
xc.xs = xs;

if(opt.draw)
    plot(xc.ts, xc.xs);
end