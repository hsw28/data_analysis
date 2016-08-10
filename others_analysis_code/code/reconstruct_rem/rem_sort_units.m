function sdat = rem_sort_units(sdat,varargin)
% REM_SORT_UNITS - organizes an sdat by time till first activity burst
%
% sdat = rem_sort_units(sdat,varargin)
% Inputs:
% -sdat (recommended that interneurons get removed, not mandatory tho)
% -[gauss_smooth (0.25)]: convolve gauss w/ this sd over spikes to get rates
% -[thresh (15)]: rate threshold unit must cross to be called active
% -[thresh_unit ('rate')]: thresh units ran be 'rate' or 'std'
% -[draw (false)]: draw the sdat

p = inputParser();
p.addParamValue('gauss_smooth',1);
p.addParamValue('thresh',0.5);
p.addParamValue('thresh_unit','rate');
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

sd = opt.gauss_smooth; % to be used later by the smoothing kernel
coeff = 1/sqrt(2*pi*sd.*2); % to be used later by the smoothing kernel
rate_samprate = 100;
rate_buffer = 1;
n_units = numel(sdat.clust);

thresh_times = zeros(1,n_units);
for n = 1:n_units
    this_times = sdat.clust{n}.stimes;
    n_spike = numel(this_times);
    this_ts = [(min(this_times)-rate_buffer):(1/rate_samprate):(max(this_times) + rate_buffer)];
    n_ts = length(this_ts);
    this_times_big = repmat(reshape(this_times,[],1),1,n_ts);
    big_ts = repmat(this_ts,n_spike,1);
    rate_array = coeff .* exp(-1 .* ( (big_ts - this_times_big).^2 ./ (2*sd.^2) ) );
    rate = sum(rate_array,1);
    
    if(strcmp(opt.thresh_unit,'std'))
        thresh_rate = opt.thresh .* std(rate) + mean(rate);
    elseif(strcmp(opt.thresh_unit,'rate'))
        thresh_rate = opt.thresh;
    end
    
    crossings = this_ts(diff(rate >= thresh_rate) == 1);
    if(numel(crossings) > 0)
        thresh_times(n) = crossings(1);
    else
        thresh_times(n) = max(this_times);
    end
end

[t, ord] = sort(thresh_times);

sort_sdat = sdatslice(sdat,'index',ord);
sort_times = thresh_times(ord);

if(opt.draw);
    h(1) = subplot(1,2,1);
    sdat_raster(sdat,[4280 4500]);
    h(2) = subplot(1,2,2);
    sdat_raster(sort_sdat,[4280,4500]);
end

sdat = sort_sdat;