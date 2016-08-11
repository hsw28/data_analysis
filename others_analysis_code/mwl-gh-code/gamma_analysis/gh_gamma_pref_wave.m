function f = gh_gamma_pref_wave(eeg_r,rat_conv_table,varargin)

p = inputParser();
p.addParamValue('thetas',linspace(-pi,pi,40));
p.addParamValue('theta_ref_ind',2);
p.addParamValue('method','hist');
p.addParamValue('timewin',[]);
p.addParamValue('theta_range',[]);
p.addParamValue('gamma_level',[]);
p.parse(varargin{:});

f = figure;

if(~isempty(p.Results.timewin))
    eeg_r = contwin_r(eeg_r,p.Results.timewin);
end

n_trode = size(eeg_r.raw.data,2);

phases = eeg_r.phase.data(:,p.Results.theta_ref_ind);

if(~isempty(p.Results.theta_range))
    ok_ind = and(eeg_r.env.data(:,p.Results.theta_ref_ind) >= p.Results.theta_range(1),...
        eeg_r.env.data(:,p.Results.theta_ref_ind) <= p.Results.theta_range(2));
    %sum(ok_ind)
    phases = phases(ok_ind);
else
    ok_ind = 1:length(phases);
end


for n = 1:n_trode
    if(isempty(p.Results.gamma_level))
        envs = eeg_r.gammaenv.data(:,n);
    elseif(strcmp(p.Results.gamma_level,'low'))
        envs = eeg_r.low_gamma_env.data(:,n);
    elseif(strcmp(p.Results.gamma_level,'high'))
        envs = eeg_r.high_gamma_env.data(:,n);
    end
    if(~isempty(p.Results.theta_range))
        envs = envs(ok_ind);
    end
    rs = lfun_phase_pref(phases,envs,p.Results.thetas);
    trode_x = trode_conv(eeg_r.raw.chanlabels{n},'comp','brain_ml',rat_conv_table);
    trode_y = trode_conv(eeg_r.raw.chanlabels{n},'comp','brain_ap',rat_conv_table);
    if(strcmp(p.Results.method,'hist'))
        gh_add_polar((p.Results.thetas(1:end-1)+(1/2)*mean(diff(p.Results.thetas))),rs,'pos',[trode_x,trode_y],'max_r',0.1,'plot_circ_mean',true);
    elseif(strcmp(p.Results.method,'mean_resultant_vector'))
        mrv = lfun_add_mrv(phases,envs);
        plot(trode_x,trode_y,'o'); hold on
        plot(trode_x+[0, real(mrv)], trode_y+[0, imag(mrv)]);
    end
    hold on;
end

axis equal;
if(isempty(p.Results.theta_range))
    title(['gh gamma pref wave: timewin[', num2str(eeg_r.raw.tstart),',',num2str(eeg_r.raw.tend),...
        '], num points:',num2str(sum(ok_ind))]);
else
    title(['gh gamma pref wave: timewin[', num2str(eeg_r.raw.tstart),',',num2str(eeg_r.raw.tend),'], theta range:[',...
        num2str(p.Results.theta_range(1)),',',num2str(p.Results.theta_range(2)),'], num points:', num2str(sum(ok_ind))]);
        end

function rs = lfun_phase_pref(phases,envs,thetas)

rs = zeros(size(thetas)+[0 -1]);
for n = 1:numel(thetas)-1
    rs(n) = mean(envs(and(phases >= thetas(n), phases < thetas(n+1))));
end


function mrv = lfun_add_mrv(phases,envs)

real_part = sum(real(envs.*exp(i.*phases)))/numel(phases)*100;
im_part = sum(imag(envs.*sin(i.*phases)))/numel(phases)*100;
mrv = real_part + i*im_part;