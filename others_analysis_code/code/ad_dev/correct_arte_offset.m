function correction_factor = correct_arte_offset(varargin)

p = inputParser();
p.addParamValue('ad_file',[]);
p.addParamValue('ad_ind',[]);
p.addParamValue('arte_file',[]);
p.addParamValue('arte_ind',[]);
p.addParamValue('samplerate',2000);
p.addParamValue('timewin',[]);
p.addParamValue('xcorr_max_lag_secs',0.5);
p.addParamValue('min_ok_peak_xcorr',0.5);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

[~,~,ad_eeg] = gh_debuffer(opt.ad_file,'chans',opt.ad_ind,'timewin',opt.timewin,...
    'quick_resample',opt.samplerate,'system','ad');

[~,~,arte_eeg] = gh_debuffer(opt.arte_file,'chans',opt.arte_ind,'timewin',opt.timewin,...
    'quick_resample',opt.samplerate,'system','arte','gains',5000,'arte_correction_factor',0);

%if(~isempty(opt.timewin))
%    ad_eeg = contwin(ad_eeg,opt.timewin);
%    arte_eeg = contwin(arte_eeg,opt.timewin);
%end

dt = 1/opt.samplerate;

maxlag = ceil(opt.xcorr_max_lag_secs / dt);

ad_ts = conttimestamp(ad_eeg)';
arte_eeg.data = interp1( conttimestamp(arte_eeg), arte_eeg.data, ad_ts, 'cubic','extrap');

[xc,lags_n] = xcorr( arte_eeg.data, ad_eeg.data, maxlag, 'coeff' );

lags_s = lags_n .* dt;

i_max_xcorr = xc == max(xc);
t_max_xcorr = lags_s(i_max_xcorr);
c_max_xcorr = xc(i_max_xcorr);

if(max(xc) < opt.min_ok_peak_xcorr)
    error('correct_arte_offset:uncorrelated_series',['Max crosscorrelation was ', num2str(c_max_xcorr)]);
end

correction_factor = -1 * t_max_xcorr;

if(opt.draw)
    subplot(2,1,1);
    plot(lags_s, xc);
    hold on;
    plot(t_max_xcorr, c_max_xcorr,'g*');
    text(t_max_xcorr, c_max_xcorr, ['t: ', num2str(t_max_xcorr)]);
    subplot(2,1,2);
    plot( conttimestamp(ad_eeg), ad_eeg.data, 'b');
    hold on;
    plot( conttimestamp(arte_eeg), arte_eeg.data, 'g');
    plot( conttimestamp(arte_eeg) + correction_factor, arte_eeg.data,'r');
    legend();
end
