function [xcorr_vals, xcorr_lags, r_threshold] = gh_xcorr(vals1,vals2,varargin)
% GH_XCORR computes simple cross correlations
% [xcorr_vals, xcorr_lags,r_threshold] in units of r, dt [default: dt = 1
% sec], and r
% [xcorr_vals, xcorr_lags,r_threshold] = gh_xcorr(vals1,vals2,['dt',1,'n_lags_per_side',20]);
% high r at negative lag means vals1 is predicted by past vals2
% high r at positive lag means vals1 predicts future vals2
% vals1[n] and vals2[n] should correspond to different data sampled at the
% same time (no time offset in input)
%
% Use when vals1 and vals2 are almost gaussian.  If one has small counts
% [0,1], then use a PSTH instead.

p = inputParser();
p.addParamValue('dt',1);
% default n_lags is 1/10 n_datapoins.  80% of data used at each lag
p.addParamValue('n_lags_per_side',floor(min(numel(vals1),numel(vals2))/10));
p.addParamValue('memory_limit', 1e7);
p.addParamValue('verbose',false);
p.addParamValue('hypothesis_alpha',0.05);
p.parse(varargin{:});
opt = p.Results;

xcorr_lags = [(-1*opt.dt*opt.n_lags_per_side):...
    opt.dt :...
    (opt.dt*opt.n_lags_per_side)];
n_lags = numel(xcorr_lags);

% vals1 'moves' from left (negitive lags) to right (positive lags)
% vals2 is stationary.  cut n_lags from each side

% each vals should be a row vector
vals1 = reshape(vals1,1,[]);
vals2 = reshape(vals2,1,[]);

% cut the sides off the stationary vals.
vals2 = vals2((opt.n_lags_per_side+1):(end-opt.n_lags_per_side));
n_elem = numel(vals2);

if ( numel(vals2)*numel(xcorr_lags) < opt.memory_limit)
    % can use repmat to do the xcorr in 1 step
    lags = (-opt.n_lags_per_side:1:opt.n_lags_per_side)';
    lags = repmat(lags,1,n_elem);
    inds = repmat( (1:n_elem)+opt.n_lags_per_side, n_lags, 1);
    inds = inds + lags;
    vals1_for_xcorr = vals1(inds);
    rhos = corr(vals2',vals1_for_xcorr'); % corr compares pairs of columns
    xcorr_vals = rhos';
else
    % intermediate repmat matrix would be too big.  calculate xcorr 1 step
    % at a time
    xcorr_vals = zeros(1,n_lags);
    for n = 1:n_lags
        this_inds = (1:1:n_elem)+n-1;
        xcorr_vals(n) = corr(vals1(this_inds)',vals2');
    end
end
