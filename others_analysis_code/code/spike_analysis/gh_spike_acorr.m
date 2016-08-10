function [rs_mean,rs_indiv,t] = gh_spike_acorr(spikes,varargin)
%GH_SPIKE_ACORR Spike autocorrelogram
%    [RS_MEAN, RS_INDIV] = gh_spike_acorr(SPIKES, varargin) returns the
%    spike counts or rates of autocorrelogram bins of spike times in SPIKES
%    RS_MEAN is the 

p = inputParser();
p.addParamValue('view',0.2); % max time offset
p.addParamValue('bin_size',0.01); % step size
p.addParamValue('windows',[]); % 2 by n list of timewins, autocorr each individually and report the individual fns and mean fn.
p.addParamValue('gh_spike_acorr_opt',[]);
p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.gh_spike_acorr_opt))
    opt = gh_spike_acorr_opt;
end % gives a chance to override with saved opts

mean_isi = (spikes(end) - spikes(1))/(numel(spikes)-1);

if(~(opt.view / opt.bin_size) == floor(opt.view / opt.bin_size))
    error('opt.view must be an integer multiple of opt.bin_size');
end

if(isempty(opt.windows))
    opt.windows = [spikes(1), spikes(end)]' + mean_isi.*[-0.5, 0.5]'; % pad beginning and end of train in undefined window with appropriate isi
end

n_win = size(opt.windows,2);
n_bin_per_view = opt.view / opt.bin_size;
n_slide = 2 * n_bin_per_view + 1;
rs_indiv = zeros(n_win,n_slide);
rs_mean = zeros(1,n_slide);

t = linspace(-1*opt.view, 1*opt.view, n_slide);

for win = 1:size(opt.windows,2)
    this_win = opt.windows(:,win);
    this_win_duration = diff(this_win);
    this_spikes = spikes(and(spikes >= this_win(1), spikes < this_win(2)));
    this_edges = [this_win(1):opt.bin_size:this_win(2)];
    if(mod(numel(this_edges),2)) % if num of this_edges is odd
        this_edges = this_edges(1:end-1);
    end % number of edges must be even, so bin count is odd
    counts = histc(this_spikes,this_edges);
    counts = counts(1:end-1); % drop off the tail bin
    n_bins = numel(counts);
    n_bin_per_slider = n_bins - n_slide + 1;
    if(n_bin_per_slider < 5)
        warning('n_bin_per_slider is less than 5');
    end
    %if(n_slide < n_bin_per_view)
    %    this_rs = NaN.*ones(1,n_slide);
    %    warning(['Window ', num2str(win), 'had too few slide positions']);
    %else
        ind_mat = repmat([1:n_slide],n_bin_per_slider,1) + repmat([1:n_bin_per_slider]',1,n_slide) - 1;
        slides = counts(ind_mat);
        corr_mat = corr(slides);
        this_rs = corr_mat((n_slide+1)/2,:);  % take the odd diagonals of correlation matrix
    %end
    rs_indiv(win,:) = this_rs;
end

for bin = 1:n_slide
    this_bin = rs_indiv(:,bin);
    this_bin = this_bin(~isnan(this_bin));
    rs_mean(bin) = mean(this_bin);
end
    