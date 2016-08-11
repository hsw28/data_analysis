function f = scratch_acorr_movie_single_chan(acorr_by_t,eeg_r,varargin)

p = inputParser();
p.addParamValue('framerate',30);
p.addParamValue('lfp_view_range',3);
p.addParamValue('chan',1);
p.addParamValue('timewin',[]);
p.addParamValue('ylim',[]);
p.parse(varargin{:});
opt = p.Results;

n_acorr_ts = size(acorr_by_t.data,2);
n_lags = size(acorr_by_t.data,1);
n_chans = size(acorr_by_t.data,3);
acorr_ts = linspace(acorr_by_t.tstart,acorr_by_t.tend,n_acorr_ts);

win_bounds = [min(acorr_by_t.lags_secs),  max(acorr_by_t.lags_secs)];
win_width = diff(win_bounds);
eeg_bounds = win_bounds .* opt.lfp_view_range;
eeg_width = diff(eeg_bounds);

eeg_ts = conttimestamp(eeg_r.raw);
eeg_inds = 1:numel(eeg_ts);

if(isempty(opt.timewin))
    opt.timewin = [eeg_r.raw.tstart + eeg_width, eeg_r.raw.tend - eeg_width];
end


acorr_inds = find(and(acorr_ts >= min(opt.timewin), ...
    (acorr_ts <= max(opt.timewin))));
acorr_centers = acorr_ts( and(acorr_ts >= min(opt.timewin),...
                                                        acorr_ts <= max(opt.timewin)));
acorr_lags = acorr_by_t.lags_secs;

eeg_data = eeg_r.raw.data(:,opt.chan)';

eeg_starts = interp1(eeg_ts, eeg_inds, acorr_centers - eeg_width/2,'nearest');
eeg_ends = interp1(eeg_ts, eeg_inds, acorr_centers + eeg_width/2,'nearest');

eeg_n_samps = eeg_ends - eeg_starts;

eeg_tstarts = eeg_ts(eeg_starts);
eeg_tends = eeg_ts(eeg_ends);

ax(1) = subplot(2,1,1);
ax(2) = subplot(2,1,2);

for n = 1:numel(acorr_centers)
    
    plot(ax(1), acorr_lags, ...
             reshape( acorr_by_t.data(:, acorr_inds(n)), 1,[]));
         xlim(ax(1), [min(acorr_by_t.lags_secs), max(acorr_by_t.lags_secs)]);
         if(~isempty(opt.ylim));
             ylim(ax(1), opt.ylim);
         end
    
    plot(ax(2),  linspace(eeg_bounds(1), eeg_bounds(2), eeg_n_samps(n)+1),...
        eeg_data( eeg_starts(n):eeg_ends(n) ));
    hold on;
    plot([win_bounds(1),win_bounds(1)],[-0.5 0.5]);
    plot([win_bounds(2),win_bounds(2)],[-0.5 0.5]);
    ylim([-0.75 0.75]);
    hold off;
    
    pause(1/opt.framerate);
end