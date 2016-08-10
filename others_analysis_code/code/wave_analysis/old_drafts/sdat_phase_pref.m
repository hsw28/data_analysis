function [f,mu_list,kappa_list,reg_stats,trodexy] = sdat_phase_pref(sdat,rat_conv_table,varargin)

p = inputParser();
p.addParamValue('draw',false);
p.addParamValue('timewin',[]);
p.parse(varargin{:});

%if(~isempty(p.Results.timewin))
%    sdat = sdatslice(sdat,'timewin',p.Results.timewin);
%end

nclust = numel(sdat.clust);
trodexy = mk_trodexy(sdat,rat_conv_table);

%bin_edges = [-pi:pi/10:pi];
if(p.Results.draw)
    f = figure;
else
    f=0;
end

mu_list = NaN.*zeros(nclust,1);
kappa_list = NaN.*zeros(nclust,1);

for n = 1:nclust
    %[counts] = histc(sdat_get(sdat,i,'theta_phase'),bin_edges);
    %the_comp_ind = find(strcmp(sdat.clust{i}.comp,rat_conv_table.data(1,:)));
    %this_x = rat_conv_table.data{6,the_comp_ind};
    %this_y = rat_conv_table.data{5,the_comp_ind};
    this_time = sdat.clust{n}.stimes;
    this_dat = sdat_get(sdat,n,'theta_phase');
    this_time = this_time(~isnan(this_dat));
    this_dat = this_dat(~isnan(this_dat));
    if(not(isempty(p.Results.timewin)))
        [tmp, logicals] = gh_times_in_timewins(this_time,p.Results.timewin);
        this_time(~logicals) = NaN;
        this_dat(~logicals) = NaN;
    end
    this_time = this_time(~isnan(this_time));
    this_dat = this_dat(~isnan(this_dat));
    if(not(isempty(this_dat)))
        [mu,kappa] = circ_vmpar(this_dat);
        mu_list(n) = mu;
    else
        mu = 0;
        kappa = -1; % kind of an error code for post_vm
    end
    
    this_x = trodexy(n,1);
    this_y = trodexy(n,2);
    %post_vm(mu,1./kappa,[this_x,this_y],'text',[sdat.clust{n}.comp,'  ', num2str(numel(this_dat))],'phase_data',this_dat);
    if(p.Results.draw)
        post_vm(mu,1./kappa,[this_x,this_y]);
        axis equal;
    end
    
%    if(not(isempty(counts)))
%        gh_add_polar(bin_edges,counts','max_r',0.25,'pos',[this_x,this_y],'plot_circ_hist',false,'circ_mean_has_magnitude',true);
%    end
end

x = [ones(nclust,1),trodexy(:,1),trodexy(:,2)];
y = mu_list;
ok_ind = ~(kappa_list == -1);
x = x(ok_ind,:);
y = y(ok_ind);

[b,bint,r,rint,stats] = regress(y,x);

dphase_by_dx = b(2);
dphase_by_dy = i*b(3);
increasing_phase_vec = dphase_by_dx + dphase_by_dy; % radians of oscillation per mm
reg_stats.wave_angle = angle(increasing_phase_vec);
reg_stats.lambda = 2*pi+abs(1/increasing_phase_vec);
reg_stats.r_squared = stats(1);