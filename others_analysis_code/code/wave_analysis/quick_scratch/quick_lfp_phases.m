function f = quick_lfp_phases(eeg_r,rat_conv_table,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('ref_ind',[]);
p.addParamValue('theta_thresh',0.1);
p.parse(varargin{:});
opt = p.Results();

n_chans = size(eeg_r.raw.data,2);
mean_env = zeros(1,n_chans);
for n = 1:n_chans
    mean_env(n) = mean(eeg_r.env.data(:,n));
end
[~,max_ind] = max(mean_env);

if(isempty(opt.ref_ind))
    ref_ind = max_ind;
else
    ref_ind = opt.ref_ind;
end

ok_bool = eeg_r.env.data(:,ref_ind) > opt.theta_thresh;

ref_phase = eeg_r.phase.data(ok_bool,ref_ind);
sum(ok_bool)

comp_label_ind  = strcmp(rat_conv_table.label,'comp');
ap_ind = strcmp(rat_conv_table.label,'brain_ap');
ml_ind = strcmp(rat_conv_table.label,'brain_ml');

for n = 1:n_chans
    comp_ind = strcmp(eeg_r.raw.chanlabels(n), rat_conv_table.data(comp_label_ind,:));
    this_phase = eeg_r.phase.data(ok_bool,n);
    this_diff = mod(gh_circular_subtract(this_phase,ref_phase),2*pi);
    thetas = linspace(0,2*pi,50);
    t_centers = (thetas(1:end-1) + thetas(2:end))/2;
    counts = histc(this_diff,thetas);
    this_x = rat_conv_table.data{ ap_ind, comp_ind };
    this_y = rat_conv_table.data{ ml_ind, comp_ind };
    gh_add_polar(t_centers, counts(1:end-1)','pos',[this_x,this_y], 'max_r', 0.1, 'plot_circ_mean',false);
end