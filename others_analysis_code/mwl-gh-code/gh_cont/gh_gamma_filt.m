function [lfp_gamma, lfp_phase, lfp_env] = gh_gamma_filt(lfp,varargin)

p = inputParser();
p.addParamValue('samplerate',[]);
p.addParamValue('timewin',[lfp.tstart,lfp.tend],@isreal);
p.addParamValue('passband',[]);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

if(not(all([lfp.tstart,lfp.tend] == p.Results.timewin)))
    lfp = contwin(lfp,p.Results.timewin);
end

if(lfp.samplerate ~= p.Results.samplerate);
    lfp.data = double(lfp.data);
    lfp = contresamp(lfp,'resample',p.Results.samplerate/lfp.samplerate);
end

gamma_fo = filtoptdefs();
gamma_fo = gamma_fo.gamma;
if(~isempty(p.Results.passband))
    gamma_fo.F = p.Results.passband;
end
gamma_fo.Fs = lfp.samplerate;
gamma_filt = mkfilt('filtopt',gamma_fo);

lfp_gamma = contfilt(lfp,'filt',gamma_filt,'autoresample',false);
lfp_gamma.chanlabels = lfp.chanlabels;

lfp_phase = multicontphase(lfp_gamma);
lfp_phase.chanlabels = lfp.chanlabels;

lfp_env = multicontenv(lfp_gamma);
lfp_env.chanlabels = lfp.chanlabels;

lfp_env.data( isnan(lfp_env.data) ) = 0;

if(opt.draw)
    ax(1) = subplot(2,1,1);
    gh_plot_cont(lfp);
    ax(2) = subplot(2,1,2);
    gh_plot_cont(lfp_env);
    linkaxes(ax, 'x');
end