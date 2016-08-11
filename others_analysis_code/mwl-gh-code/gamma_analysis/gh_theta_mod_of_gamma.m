function [mod_score,phase_pref,powers,h] = gh_theta_mod_of_gamma(eeg_r,varargin)

p = inputParser;
p.addParamValue('timewin',[]);
p.addParamValue('theta_threshold',[]);
p.addParamValue('theta_ind',1);
p.addParamValue('gamma_ind',1);
p.addParamValue('hist_edges',linspace(-pi,pi,17));
p.addParamValue('method','hist');
p.addParamValue('draw',false);
p.parse(varargin{:});

mod_score = NaN;
phase_pref = NaN;
powers = NaN;

if(~isempty(p.Results.timewin))
    eeg_r = contwin_r(eeg_r,p.Results.timewin);
end

theta_phase = eeg_r.phase.data(:,p.Results.theta_ind);
theta_env = eeg_r.env.data(:,p.Results.theta_ind);
gamma_env = eeg_r.gammaenv.data(:,p.Results.gamma_ind);

if(~isempty(p.Results.theta_threshold))
    ok_ind = (theta_env > p.Results.theta_threshold);
    theta_phase = theta_phase(ok_ind);
    gamma_env = gamma_env(ok_ind);
end

bin_means = gh_whistc(theta_phase,gamma_env,linspace(-pi,pi,20),'means',true);

if(p.Results.draw)
    h = plot(theta_phase,gamma_env,'.','MarkerSize',1);
    hold on;
    plot(linspace(-pi,pi,19),bin_means(1:end-1),'k','LineWidth',4);
else
    h = NaN;
end
