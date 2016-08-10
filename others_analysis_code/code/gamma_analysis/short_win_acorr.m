function acorr_by_t = short_win_acorr(x,ts_secs,win_length_secs,varargin)

% acorr_by_t = SHORT_WIN_ACORR computes the autocorrelation in a small
% window centered in turn on each data point in x (M channels x N samples)
% 

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('suppress_zero_lag',false);
p.addParamValue('max_lags_secs',[]);
p.addParamValue('acorr_norm','unbiased');
p.addParamValue('post_norm',true);
p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.timewin))
    ok_bool = and(ts_secs >= min(opt.timewin), ts_secs <= max(opt.timewin));
    x = x(:, ok_bool);
    ts_secs = ts_secs(ok_bool);
end

n_chans = size(x,1);
n_ts =    size(x,2);

dt_secs = ts_secs(2) - ts_secs(1);
win_length_secs = floor(win_length_secs / dt_secs) * dt_secs;
win_length_samps = win_length_secs / dt_secs;
win_length_samps_one_sided = (win_length_samps - 1)/2;

highest_possible_max_lags_samps = win_length_samps - 1;
if(isempty(opt.max_lags_secs))
    max_lags_samps = highest_possible_max_lags_samps;
else
    max_lags_samps = floor(opt.max_lags_secs / dt_secs);
    if(max_lags_samps > highest_possible_max_lags_samps)
        warning('short_win_acorr:too_high_max_lag_secs',...
                ['shortinging max_lag_secs to ',...
                 num2str(highest_possible_max_lags_samps * dt_secs)]);
        max_lags_samps = highest_possible_max_lags_samps;
    end
end

lags = (-1*max_lags_samps):(max_lags_samps);
n_lags = numel(lags);
lags_secs = lags .* dt_secs;

% zero-pad input data as needed
n_pad_ts = win_length_samps;
pads = zeros(n_chans,n_pad_ts);
x = [pads, x, pads];

acorr_by_t.data = zeros(n_lags, n_ts, n_chans);

this_col_ind = (1+n_pad_ts) : ...
    ((1+n_pad_ts) + n_ts - 1);

additional_row_ind = lags;

inds_matrix = repmat(this_col_ind, n_lags, 1) + ...
    repmat(additional_row_ind', 1, n_ts);

for m = 1:n_chans
    this_x = x(m, :);
    windowed_data = this_x(inds_matrix);
    for n = 1:n_ts
        frac_finished = n/n_ts;
        if(frac_finished == floor(frac_finished*100)/100)
            display([ num2str(frac_finished*100), '% done']);
        end
        acorr_by_t.data(:,n,m) = xcorr(windowed_data(:,n),max_lags_samps,opt.acorr_norm);
    end
end
acorr_by_t.lags_secs = lags_secs;

if(opt.post_norm)
    for c = 1:n_chans
        zero_lag_val_by_t = acorr_by_t.data(acorr_by_t.lags_secs == 0, :, c);
        acorr_by_t.data(:,:,c) = acorr_by_t.data(:,:,c) ./ ...
            repmat(zero_lag_val_by_t, n_lags, 1);
    end
end

if(opt.suppress_zero_lag)
    acorr_by_t.data( (lags == 0), :, : ) = 0;
end

acorr_by_t.tstart = min(ts_secs);
acorr_by_t.tend =   max(ts_secs);
acorr_by_t.samplerate = 1/(ts_secs(2)-ts_secs(1));