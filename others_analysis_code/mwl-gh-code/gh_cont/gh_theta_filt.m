function [lfp_theta, lfp_phase, lfp_env] = gh_theta_filt(lfp,varargin)

p = inputParser();
p.addParamValue('samplerate',[]);
p.addParamValue('timewin',[lfp.tstart,lfp.tend],@isreal);
p.parse(varargin{:});

if(not(all([lfp.tstart,lfp.tend] == p.Results.timewin)))
    lfp = contwin(lfp,p.Results.timewin);
end

if(not(isempty(p.Results.samplerate)))
    error('Resampling!');
    lfp.data = double(lfp.data);
    lfp = contresamp(lfp,'resample',p.Results.samplerate/lfp.samplerate);
end

theta_fo = filtoptdefs();
theta_fo = theta_fo.theta;
theta_fo.Fs = lfp.samplerate;
theta_filt = mkfilt('filtopt',theta_fo);

lfp_theta = contfilt(lfp,'filt',theta_filt,'autoresample',false);
lfp_theta.chanlabels = lfp.chanlabels;

lfp_phase = multicontphase(lfp_theta);
lfp_phase.chanlabels = lfp.chanlabels;

lfp_env = multicontenv(lfp_theta);
lfp_env.chanlabels = lfp.chanlabels;