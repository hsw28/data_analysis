function tdr = theta_delta_ratio(eeg_r_for_theta,varargin)

p = inputParser();
p.addParamValue('smooth_t',30);
p.addParamValue('eeg_r_for_delta',[]);
p.addParamValue('resample',true);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

if(opt.resample)
    if(isfield(eeg_r_for_theta,'raw') && eeg_r_for_theta.raw.samplerate > 150)
        for i = fields(eeg_r_for_theta);
            eeg_r_for_theta.(i) = contresamp(eeg_r_for_theta.(i), ...
                'resample', 150/eeg_r_for_theta.(i).samplerate);
        end
    end
    if(eeg_r_for_theta.samplerate > 150)
        eeg_r_for_theta = contresamp(eeg_r_for_theta, ...
            'resample', 150/eeg_r_for_theta.samplerate);
    end
end

if(~isfield(eeg_r_for_theta,'theta'))
    eeg_r_for_theta = prep_eeg_for_regress(eeg_r_for_theta);
end

if(isempty(opt.eeg_r_for_delta))
    eeg_r_for_delta = eeg_r_for_theta;
end

if(~isfield(eeg_r_for_delta,'gamma'))
    eeg_r_for_delta = prep_eeg_for_regress(eeg_r_for_theta.raw, 'gamma',true,'gamma_win',[0.5 1 4 5]);
end

theta_power = gh_smooth_cont(cdat_power(eeg_r_for_theta.theta), opt.smooth_t);
delta_power = gh_smooth_cont(cdat_power(eeg_r_for_delta.gamma), opt.smooth_t);

% replace all denominator zeros with the next-smallest value
delta_power.data (delta_power.data == 0) = min( delta_power.data( ~(delta_power.data == 0) ) );


tdr = theta_power;
tdr.data = theta_power.data ./ delta_power.data;

if(opt.draw);
    figure;
    ax(1) = subplot(4,1,1);  
    gh_plot_cont(eeg_r_for_theta.raw);   ylabel('raw');
    ax(2) = subplot(4,1,2);    
    gh_plot_cont(theta_power); ylabel('theta power');
    ax(3) = subplot(4,1,3);
    gh_plot_cont(delta_power); ylabel('delta power');
    ax(4) = subplot(4,1,4);
    gh_plot_cont(tdr);         ylabel('theta delta ratio');
    linkaxes(ax,'x');
end
end

function new_cdat = cdat_power(cdat)
new_cdat = cdat;
new_cdat.data (isnan(new_cdat.data)) = 0;
new_cdat.data = ( new_cdat.data .^ 2) .^ (1/2);
end