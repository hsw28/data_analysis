function [new_sdat,total_rates_cdat] = assign_rate_by_time(sdat,varargin)

% [new_sdat, total_rates_cdat] = ASSIGN_RATE_BY_TIME computes instanteous
% firing rate of units in an sdat (including MUA sdats)
% Add to each sdat clust a cdat describing the instantaneous firing rate
% optional params: timewin, samplerate, gauss_sd_secs, timebins

p = inputParser;
p.addParamValue('timewin',[]);
p.addParamValue('samplerate',400,@(x) (x > 0));
p.addParamValue('filtopt',[],@(x) not(isempty(x)));
p.addParamValue('gauss_sd_secs',[]);
p.addParamValue('timebins',[],@isreal);
p.parse(varargin{:});
opt = p.Results;

nclust = numel(sdat.clust);

if(isempty(opt.timewin))
    tw_temp = zeros(nclust,2);
    for i = 1:nclust
        tw_temp(i,:) = [min(sdat.clust{i}.stimes),max(sdat.clust{i}.stimes)];
    end
    opt.timewin = [min(tw_temp(:,1))-1, max(tw_temp(:,2))+1];
    % round to the next sampling period
    opt.timewin(1) = floor( opt.timewin(1) ./ (1/opt.samplerate) ) * (1/opt.samplerate);
    opt.timewin(2) = ceil(  opt.timewin(2) ./ (1/opt.samplerate) ) * (1/opt.samplerate);
end

if(isempty(opt.timebins))
    timebins = opt.timewin(1) : (1/opt.samplerate) : opt.timewin(2);
else
    timebins = opt.timebins;
end

dt_bin = timebins(2)-timebins(1);
n_bins = numel(timebins);
bin_centers = timebins + dt_bin/2;
timestamp_for_imcont = bin_centers';

if(nclust > 0)
total_rates_cdat = imcont('timestamp',timestamp_for_imcont,...
                          'data', zeros(n_bins,nclust));
else
error('assign_rate_by_time:no_clusts','There are no clusters in this cdat');
end

smoothing_kernel = [];
nyquist_period = 2*(1/opt.samplerate);
half_kernel_n_sd = 4;
if(opt.gauss_sd_secs == 0)
    disp('assign_rate_by_time: opted out of reccommended gauss_sd_secs');
    disp(['for your sampling rate, reccomended: ', num2str(nyquist_period)]);
else
    if(isempty(opt.gauss_sd_secs))
        opt.gauss_sd_secs = nyquist_period;
    end
    n_half_kernel_bins = ceil(opt.gauss_sd_secs / (1/opt.samplerate) ) * half_kernel_n_sd;
    full_kernel_times = (1/opt.samplerate) .* ...
        ( (-1*n_half_kernel_bins):n_half_kernel_bins);
    smoothing_kernel = exp( (-1 .* (full_kernel_times.^2))./(2 * opt.gauss_sd_secs^2));
    smoothing_kernel = smoothing_kernel ./ sum(smoothing_kernel);
    smoothing_kernel = reshape(smoothing_kernel,[],1);
end
    
for i = 1:nclust
    spikes = sdat.clust{i}.stimes';
    
    %bindif = [diff(timebins), (timebins(2)-timebins(1)) ]'; % fudge factor, to avoid div by 0 in case of spiketime equal to last bin edge
    % re: above.  Ok, but when do we actually use bindif & timestamp??  I
    % don't see how an end-aligned spike causes problems anymore.
    %timestamp = timebins' + bindif ./ 2;
    
    counts = histc(spikes,timebins);
    rates = counts'./(1/opt.samplerate);
    
    if(~isempty(smoothing_kernel))
        rates = conv(rates,smoothing_kernel,'same');
    end
    
    rates_for_imcont = reshape(rates, n_bins, 1);
    
    %timestamp = timestamp';
    %size(timestamp)
    %size(rates)
    sdat.clust{i}.rate_by_time = imcont('timestamp',timestamp_for_imcont,...
                                        'data',rates_for_imcont);
    sdat.clust{i}.rate_by_time.data = double(sdat.clust{i}.rate_by_time.data);
    sdat.clust{i}.rate_by_time.chanlabels = {sdat.clust{i}.comp};
    
    % old thing - unclear what the shape was when I put this in
    %total_rates_cdat.data(:,i) = reshape(rates,n_bins,1);
    
    total_rates_cdat.data(:,i) = rates_for_imcont;
    total_rates_cdat.chanlabels{i} = sdat.clust{i}.rate_by_time.chanlabels{1};

end

new_sdat = sdat;