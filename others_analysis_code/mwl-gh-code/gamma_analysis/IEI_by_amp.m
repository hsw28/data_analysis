function fig = IEI_by_amp(cdat,env_cdat,varargin)

p = inputParser();
p.addParamValue('timewin',[cdat.tstart, cdat.tend],@isreal);
p.addParamValue('chans',1:size(cdat.data,2),@isreal);
p.addParamValue('massimo_way',true,@islogical);
p.addParamValue('hilbert_way',true,@islogical);
p.parse(varargin{:});

cdat = contchans(cdat,'chans',p.Results.chans);
cdat = contwin(cdat,p.Results.timewin);

env_cdat = contchans(env_cdat,'chans',p.Results.chans);
env_cdat = contwin(env_cdat,p.Results.timewin);

[local_max_inds, local_min_inds, down_zero_inds, up_zero_inds] = gamma_find_extremes(cdat);

ts = conttimestamp(cdat);
data_max = max(max(cdat.data));
dt = ts(2)-ts(1);

if(p.Results.massimo_way)
    figure; plot(ts,cdat.data,'k');
    hold on
    plot(ts(local_max_inds), cdat.data(local_max_inds), 'b.');
    plot(ts(local_min_inds), cdat.data(local_min_inds), 'r.');
    plot(ts(down_zero_inds), zeros(size(down_zero_inds)), 'bO');
    plot(ts(up_zero_inds), zeros(size(up_zero_inds)),'rO');
    xlabel('time (sec)');
    ylabel('Gamma band LFP (mV)');
    title('Gamma filtered LFP signal w/ marked peaks and troughs');
end


local_max_inds = reshape(local_max_inds,1,[]);
local_min_inds = reshape(local_min_inds,[],1);

local_max_inds_big = repmat(local_max_inds,numel(local_min_inds),1);
local_min_inds_big = repmat(local_min_inds,1,numel(local_max_inds));

max_to_min_n = local_min_inds_big - local_max_inds_big;
max_to_min_n(max_to_min_n < 1) = 100000; % eliminate previous mins from the running
col_mins = min(max_to_min_n,[],1);
max_to_min_n(max_to_min_n ~= repmat(col_mins,numel(local_min_inds),1)) = 0;
next_ind_adv_n = max_to_min_n(max_to_min_n ~= 0);

event_peak_to_trough_time = next_ind_adv_n .* dt;
event_peak_to_trough_amp = cdat.data(local_max_inds) - cdat.data(local_max_inds + next_ind_adv_n');
event_peak_to_peak_time = diff(local_max_inds) .* dt;

if(p.Results.massimo_way)
    figure; plot(event_peak_to_peak_time,event_peak_to_trough_amp(1:end-1),'.')
    figure; gh_scatter_image(event_peak_to_peak_time',event_peak_to_trough_amp(1:end-1),[0:0.001:0.04],[0:0.02:0.7]);
    xlabel('Peak to peak time (sec)');
    ylabel('Peak to trough amplitude (mV)');
    title('Amplitude vs. Interevent interval, Scanziani method');
end

hil = hilbert(cdat.data);
data_phase = unwrap(angle(hil));

freq = diff(data_phase) ./ dt ./ (2*pi);
freq_cdat = imcont('timestamp',ts(1:end-1)+dt/2,'data',freq);

smooth_fo = filtoptdefs;
smooth_fo = smooth_fo.smooth_sd_20ms;
smooth_fo.Fs = freq_cdat.samplerate;
smooth_filt = mkfilt('filtopt',smooth_fo);
freq_cdat_smooth = contfilt(freq_cdat,'filt',smooth_filt);

%figure; plot(conttimestamp(freq_cdat_smooth),freq_cdat_smooth.data);
%xlim([833 834]);

comb_cdat = contcombine(freq_cdat_smooth,env_cdat);
%figure; plot(comb_cdat.data(:,1),comb_cdat.data(:,2),'.');
figure; gh_scatter_image(comb_cdat.data(:,1),comb_cdat.data(:,2),[10:1:100],[0:0.005:0.2]);
xlabel('Instantaneous frequency (Hz)');
ylabel('Gamma envelope (mV)');
title('Instantaneous frequency predicts instantaneous amplitude?');

toff = 0.02;
noff = ceil(toff ./ dt);
comb_cdat.data(1:end-200,1);
comb_cdat.data(noff:end,2);
figure; gh_scatter_image(comb_cdat.data(1:end-noff,1), comb_cdat.data(noff:end,2),[10:1:100],[0:0.005:0.2]);
xlabel('Instantaneous frequency (Hz)');
ylabel('Gamma envelope (mV)');
title('Shifted 20ms: past frequency predicts amplitude?');

figure; gh_scatter_image(comb_cdat.data(noff:end,1), comb_cdat.data(1:end-noff+1,2),[10:1:100],[0:0.005:0.2]);
xlabel('Instantaneous frequency (Hz)');
ylabel('Gamma envelope (mV)');
title('Shifted 20ms: past amplitude predicts frequency?');

max_xcorr_time = 0.5;
max_xcorr_steps = max_xcorr_time / dt;
[c,lags] = xcorr(comb_cdat.data(:,1), comb_cdat.data(:,2),ceil(max_xcorr_steps));
figure; plot(lags.*dt,c);
