function [lfp_ripple, lfp_phase, lfp_env] = gh_ripple_filt(lfp,varargin)

p = inputParser();
p.addParamValue('samplerate',[]);
p.addParamValue('F',[]);
p.addParamValue('timewin',[]);
p.parse(varargin{:});

if ~isempty(p.Results.timewin)
  lfp = contwin(lfp,p.Results.timewin);
end

if(not(isempty(p.Results.samplerate)))
    %error('Resampling!');
    lfp.data = double(lfp.data);
    lfp = contresamp(lfp,'resample',p.Results.samplerate/lfp.samplerate);
end

ripple_fo = filtoptdefs();
ripple_fo = ripple_fo.ripple;
if (~isempty(p.Results.F))
    ripple_fo.F = p.Results.F;
end
ripple_fo.Fs = lfp.samplerate;
ripple_filt = mkfilt('filtopt',ripple_fo);

lfp_ripple = contfilt(lfp,'filt',ripple_filt,'autoresample',false);
lfp_ripple.chanlabels = lfp.chanlabels;

lfp_phase = multicontphase(lfp_ripple);
lfp_phase.data( isnan(lfp_phase.data) ) = 0;
lfp_phase.chanlabels = lfp.chanlabels;

lfp_env = multicontenv(lfp_ripple);
lfp_env.data( isnan(lfp_env.data) ) = 0;
lfp_env.chanlabels = lfp.chanlabels;