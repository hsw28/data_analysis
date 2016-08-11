function fig = disp_reg_stats(beta_data,sdat_r,varargin)

p=inputParser();
p.addParamValue('pos_info',[]);
p.addParamValue('timewin',[]);
p.parse(varargin{:});

if(~isempty(p.Results.timewin))
    good_beta_log = and(beta_data.timestamps >= p.Results.timewin(1), beta_data.timestamps <= p.Results.timewin(2));
    ts_raw = conttimestamp(sdat_r.raw);
    good_raw_log = and(ts_raw >= p.Results.timewin(1), ts_raw <= p.Results.timewin(2));
    if(~isempty(p.Results.pos_info))
        ts = conttimestamp(p.Results.pos_info.lin_vel_cdat);
        good_pos_log = and(ts >= p.Results.timewin(1), ts<= p.Results.timewin(2));
    end
else
    disp('in first else')
    good_beta_log = logical(ones(size(beta_data.timestamps)));
    good_raw_log = logical(ones(size(conttimestamp(sdat_r.raw))));
    if(~isempty(p.Results.pos_info))
        ts = conttimestamp(p.Results.pos_info.lin_vel_cdat);
        good_pos_log = logical(ones(size(ts)));
    end
end

% beta_data.est = [ freq; wavelength; waveangle; phaseoffset; amp ]

n_plots = 7;

k = 1;

ax(k) = subplot(n_plots,1,k);
ts = conttimestamp(sdat_r.raw);
plot(ts(good_raw_log),sdat_r.raw.data(good_raw_log)); k = k + 1;

ax(k) = subplot(n_plots,1,k);
plot(beta_data.timestamps(good_beta_log),beta_data.est(1,good_beta_log)); k = k + 1;
ylabel('freq');

ax(k) = subplot(n_plots,1,k);
plot(beta_data.timestamps(good_beta_log),beta_data.est(2,good_beta_log),'.'); k = k + 1;
ylim([-0.01, 25])
ylabel('lambda');

%ax(k) = subplot(n_plots,1,k);
%scale = 0.001;
%offset = 20;
%t = beta_data.timestamps;
%lambda = beta_data.est(2,:);
%theta = beta_data.est(3,:);
%mag = min([zeros(size(t)), offset-lambda]).*scale;
%u = mag.*cos(theta);
%v = mag.*sin(theta);
%quiver(t,zeros(size(t)),u.*scale,v.*scale,0.001); k = k + 1;

ax(k) = subplot(n_plots,1,k);
plot(beta_data.timestamps(good_beta_log),beta_data.est(3,good_beta_log),'.');
hold on; plot(beta_data.timestamps(good_beta_log),beta_data.est(3,good_beta_log)-2*pi,'.'); k = k + 1;
ylim([-pi-0.1, pi+0.1]);
set(gca,'YTick',[-pi, 0, pi]);
set(gca,'YTickLabel',{'-pi','0', 'pi'});
ylabel('direction');

ax(k) = subplot(n_plots,1,k);
%plot(beta_data.timestamps,beta_data.est(4,:)); k = k + 1;
if(~isempty(p.Results.pos_info))
    ts = conttimestamp(p.Results.pos_info.lin_vel_cdat);
    plot(ts(good_pos_log),p.Results.pos_info.lin_vel_cdat.data(good_pos_log)); k = k + 1;
    hold on;
    plot(conttimestamp(p.Results.pos_info.lin_vel_cdat),zeros(size(p.Results.pos_info.lin_vel_cdat.data)));
else
    plot(beta_data.timestamps,zeros(size(beta_data.timestamps))); k = k + 1;
end

ax(k) = subplot(n_plots,1,k);
plot(beta_data.timestamps(good_beta_log),beta_data.est(5,good_beta_log)); k = k + 1;
ylabel('A(mv)');

ax(k) = subplot(n_plots,1,k);
plot(beta_data.timestamps(good_beta_log),beta_data.r_squared(good_beta_log)); k = k + 1;
ylabel('r_2');


linkaxes(ax,'x');