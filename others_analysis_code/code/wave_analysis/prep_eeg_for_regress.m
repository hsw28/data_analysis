function [eeg_for_regress, eeg_for_regress_small] = prep_eeg_for_regress(eeg,varargin)

p = inputParser();
p.addParamValue('timewin_buffer',2);
p.addParamValue('small_timewin',[]);
p.addParamValue('samplerate',[]);
p.addParamValue('gamma',false,@islogical);
p.addParamValue('gamma_win',[20 30 80 100]);
p.addParamValue('gamma_range',false,@islogical);
p.addParamValue('ripple',false,@islogical);
p.parse(varargin{:});

eeg.data = double(eeg.data);

if(not(isempty(p.Results.samplerate)))
    if(not(p.Results.samplerate == eeg.samplerate))
        resamp = p.Results.samplerate / eeg.samplerate;
        eeg = contresamp(eeg,'resample',resamp);
    end
end

[tmp_theta, tmp_phase, tmp_env] = gh_theta_filt(eeg);
if(p.Results.ripple)
    [tmp_ripple, tmp_ripple_phase,tmp_ripple_env] = gh_ripple_filt(eeg);
end

if(p.Results.gamma)
    [tmp_gamma, tmp_gphase, tmp_genv] = gh_gamma_filt(eeg,'passband',p.Results.gamma_win);
end

timewin = [eeg.tstart, eeg.tend];

if(not(isempty(p.Results.timewin_buffer)))
    timewin = timewin + p.Results.timewin_buffer.*[1 -1];
else
    warning('You should specify a timewin buffer, b/c the hilbert call in prep_eeg_for_regress can produce some NaN edge effects.');
end

ts = conttimestamp(eeg);
zero_bool = or( ts < timewin(1), ts > timewin(2));

buffer_fun = (@(cdat)  lfun_contzero(cdat, zero_bool) );
%buffer_fun = (@(cdat) contwin(cdat,timewin));

eeg_for_regress.raw = buffer_fun(eeg);
eeg_for_regress.theta = buffer_fun(tmp_theta);
eeg_for_regress.phase = buffer_fun(tmp_phase);
eeg_for_regress.env = buffer_fun(tmp_env);

if(p.Results.ripple)
    eeg_for_regress.ripple = buffer_fun(tmp_ripple);
    eeg_for_regress.ripple_phase = buffer_fun(tmp_ripple_phase);
    eeg_for_regress.ripple_env = buffer_fun(tmp_ripple_env);
end

if(p.Results.gamma)
    eeg_for_regress.gamma = buffer_fun(tmp_gamma);
    eeg_for_regress.gammaphase = buffer_fun(tmp_gphase);
    eeg_for_regress.gammaenv = buffer_fun(tmp_genv);
end

if(p.Results.gamma_range)
    low_gamma = [25 30 55 60];
    high_gamma = [75 80 140 150];
    [tmp_gamma, tmp_phase, tmp_env] = gh_gamma_filt(eeg,'passband',low_gamma);
    eeg_for_regress.low_gamma = buffer_fun(tmp_gamma);
    eeg_for_regress.low_gamma_phase = buffer_fun(tmp_phase);
    eeg_for_regress.low_gamma_env = buffer_fun(tmp_env);
    [tmp_gamma, tmp_phase, tmp_env] = gh_gamma_filt(eeg,'passband',high_gamma);
    eeg_for_regress.high_gamma = buffer_fun(tmp_gamma);
    eeg_for_regress.high_gamma_phase = buffer_fun(tmp_phase);
    eeg_for_regress.high_gamma_env = buffer_fun(tmp_env);
end

if(not(isempty(p.Results.small_timewin)))
    eeg_for_regress_small = contwin_r(eeg_for_regress,p.Results.small_timewin);
end

fs = fieldnames(eeg_for_regress);
for f = 1:numel(fs)
    toZero = isnan(eeg_for_regress.(fs{f}).data);
    eeg_for_regress.(fs{f}).data(toZero) = 0;
end

function new_cdat = lfun_contzero(cdat, zero_bool)
new_cdat = cdat;
new_cdat.data = cdat.data .* repmat((~zero_bool)', 1, size(cdat.data,2));