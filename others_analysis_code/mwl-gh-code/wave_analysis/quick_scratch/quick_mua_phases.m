function f = quick_mua_phases(mua,eeg_r,rat_conv_table,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('ref_ind',1);
p.addParamValue('theta_thresh',0.1);
p.addParamValue('t_max_wd_range',[-30 50]);
p.parse(varargin{:});
opt = p.Results();

n_mua = mua.nclust;
%mean_env = zeros(1,n_mua);
%for n = 1:n_mua
%    mean_env(n) = mean(eeg_r.env.data(:,n));
%end
%[~,max_ind] = max(mean_env);

%if(isempty(opt.ref_ind))
%    ref_ind = max_ind;
%else
ref_ind = opt.ref_ind;
%end

ok_bool = eeg_r.env.data(:,ref_ind) > opt.theta_thresh;

ref_phase = eeg_r.phase.data(ok_bool,ref_ind);
sum(ok_bool)

comp_label_ind  = strcmp(rat_conv_table.label,'comp');
ap_ind = strcmp(rat_conv_table.label,'brain_ap');
ml_ind = strcmp(rat_conv_table.label,'brain_ml');

if(~isempty(opt.timewin))
    mua = sdatslice(mua,'timewin',opt.timewin);
end

for n = 1:n_mua
    comp_ind = strcmp(mua.clust{n}.comp, rat_conv_table.data(comp_label_ind,:));
    t_max_wd_ind = strcmp('t_maxwd', mua.clust{n}.featurenames);
    ok_bool = (min(opt.t_max_wd_range) <= mua.clust{n}.data(:,t_max_wd_ind)) & ...
        (max(opt.t_max_wd_range) >= mua.clust{n}.data(:,t_max_wd_ind));
    phase_ind = strcmp('theta_phase',mua.clust{n}.featurenames);
    this_phase = mua.clust{n}.data(ok_bool,phase_ind);
    thetas = linspace(-pi,pi,20);
    t_centers = (thetas(1:end-1) + thetas(2:end))/2;
    counts = histc(this_phase,thetas);
    this_x = rat_conv_table.data{ ml_ind, comp_ind };
    this_y = rat_conv_table.data{ ap_ind, comp_ind };
    gh_add_polar(t_centers, counts(1:end-1)','pos',[this_x,this_y], 'max_r', 0.1, 'plot_circ_mean',true);
end
axis equal;