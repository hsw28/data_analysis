function [counts, ts, aux_data] = gh_psth(triggers,spikes,varargin)

p = inputParser();
p.addParamValue('return_units','binned_counts',@(x) any(strcmp(x,{'binned_counts','binned_rates','smoothed_rates','times'})));
p.addParamValue('window_length',2); % seconds
p.addParamValue('bin_length',0.001);  % seconds
p.addParamValue('spike_smooth_sd',0.010); % seconds to gaussian smooth spikes
p.addParamValue('bouts', [], @(x) size(x,1) == 2); % want 2 x n intervals list
p.addParamValue('memory_limit',1e7);
p.parse(varargin{:});
opt = p.Results;

aux_data = 0;  % placeholder for other data that can come back with the psth
triggers = reshape(triggers,1,[]);
spikes = reshape(spikes,1,[]);

ts = (min(triggers)-opt.window_length/2): opt.bin_length : (max(triggers)+opt.window_length/2);
bin_centers = (-opt.window_length/2):opt.bin_length:(opt.window_length/2);
n_bins = numel(bin_centers);

% seems if smoothed_rates is wanted, can do this with xcorr
if(strcmp(opt.return_units,'smoothed_rates'))
    tinydt = 0.0001;
    if((max(ts)-min(ts))/tinydt > opt.memory_limit)
        dt = ts(2)-ts(1);
        warning('gh_psth:too_little_memory_for_big_array','gh_psth complaining about not enough memory for tiny_ts');
        single_gauss = 1/sqrt(2*pi*opt.spike_smooth_sd^2) .* exp(-(bin_centers - 0).^2 ./ (2*opt.spike_smooth_sd^2)) * dt;
        sum(single_gauss)
        trig_rate = zeros(size(ts));
        spike_rate = zeros(size(ts));
        for n = 1:numel(triggers)
            this_trigs = histc(triggers(n),[ts(1)-dt/2, (ts + dt/2)]);
            this_trigs = this_trigs(1:end-1);
            trig_rate = trig_rate + conv(this_trigs,single_gauss,'same');
        end
        for n = 1:numel(spikes)
            this_spikes = histc(spikes(n),[ts(1)-dt/2, (ts + dt/2)]);
            this_spikes = this_spikes(1:end-1);
            spike_rate = spike_rate + conv(this_spikes,single_gauss,'same');
        end
        
    else % there is enough memory for big vector
        tinyts = min(ts):tinydt:max(ts);
        tiny_windowts = min(bin_centers):tinydt:max(bin_centers);
        % draw a single gaussian around a spike at time 0 on bin_centers times
        single_gauss = 1/sqrt(2*pi*opt.spike_smooth_sd^2) .* exp(- (tiny_windowts - 0).^2 ./ (2*opt.spike_smooth_sd^2));
        trig_rate = histc(triggers,tinyts);
        trig_rate = conv(trig_rate,single_gauss,'same') .* tinydt;
        trig_rate = interp1(tinyts,trig_rate,ts);
        spike_rate = histc(spikes,tinyts);
        spike_rate = conv(spike_rate,single_gauss,'same') .* tinydt;
        spike_rate = interp1(tinyts,spike_rate,ts);
    end
    maxlags = (n_bins-1)/2;
    rs = xcorr(spike_rate,trig_rate,maxlags);
    tmp = 1;
    % NB: Seems the two methods of getting spike_rate and trig_rate result
    % in rs with very different y scale!  Have to figure out why.
end

if(any(strcmp(opt.return_units,{'binned_counts','binned_rates','times'})))
    % these all require each trigger to be subtracted from all spikes
    % for counts, count spikes in each bin
    % binned rates: just divide by (bin length * trig count) I think
    % times: return the flattened array of spikes - trigs itself
    dt = opt.bin_length;
    if((numel(triggers) * numel(spikes)) < opt.memory_limit)
        big_triggers = repmat( reshape(triggers,[],1), 1, numel(spikes));
        aux_data = repmat(reshape(spikes,1,[]),numel(triggers),[]) - big_triggers;
        clear big_triggers;
        in_win_log = abs(aux_data) <= opt.window_length/2;
        flat_times = reshape( aux_data(logical(in_win_log)),1,[]);
    else
        warning('gh_psth:too_little_memory_for_big_array','gh_psth running slow b/c not enough memory for big array');
        sub_times = cell(numel(triggers),1);
        for n = 1:numel(triggers)
            this_sub = spikes - triggers(n);
            this_sub = this_sub(abs(this_sub) <= opt.window_length/2);
            sub_times{n} = this_sub';
        end
        flat_times = reshape( cell2mat(sub_times),1,[]);
        tmp = 1;
    end
    counts = flat_times;
    ts = bin_centers; % not used yet in times, but user may want them later
    
    if(strcmp(opt.return_units,'binned_counts'))
        counts = histc(flat_times,[ts(1)-dt/2, ts + dt/2]);
        counts = counts(1:(end-1)); % drop catch-all bin from histc
    elseif(strcmp(opt.return_units,'binned_rates'))
        counts = histc(flat_times,[ts(1) - dt/2, ts + dt/2]);
        counts = counts(1:end-1) ./ (dt * numel(triggers));
    end
end



function lfun_plot_aux_data(aux_data)
for n = 1:size(aux_data,1)
    [xs,ys] = gh_raster_points(aux_data(n,:));
    plot(xs,ys+n); hold on;
end