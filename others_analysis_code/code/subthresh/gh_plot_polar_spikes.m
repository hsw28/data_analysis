function [counts, bin_centers_rs, bin_centers_ang] = gh_plot_polar_spikes(rs,amps,varargin)

p = inputParser();

% we actually don't use these.  They're for gh_ploar_3d_hist.m
p.addParamValue('n_ang_bins',20);
p.addParamValue('ang_limits',[-1,1]);
p.addParamValue('n_rs_bins', 50);
p.addParamValue('rs_limits',[0, 3000]);
p.addParamValue('rs_smooth', 100);
p.parse(varargin{:});
opt = p.Results;

ang_bins = linspace(opt.ang_limits(1), opt.ang_limits(2), opt.n_ang_bins);
rs_bins =  linspace(opt.rs_limits(1),  opt.rs_limits(2),  opt.n_rs_bins);
[ ANG1,ANG2,ANG3] = ndgrid( ang_bins, ang_bins, ang_bins );

ANG1 = reshape(ANG1, 1, []);
ANG2 = reshape(ANG2, 1, []);
ANG3 = reshape(ANG3, 1, []);

%scatter3(ANG1,ANG2,ANG3,(30-15*sqrt(abs(ANG1).^2+abs(ANG2).^2+abs(ANG3).^2)), (30-8*(abs(ANG1)+abs(ANG2)+abs(ANG3))),'filled');

keep_log = rs > 650;
scatter3(amps(keep_log,1),amps(keep_log,2),amps(keep_log,3), rs(keep_log)./100-3, (rs(keep_log)./100-100).^0.5,'filled');

counts = 1; bin_centers_rs = 1; bin_centers_ang = 1;