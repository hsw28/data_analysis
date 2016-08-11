r_squared_cdat = imcont('timestamp',beta_data.timestamps','data',beta_data.r_squared');
%est_cdat = imcont('timestamp',beta_data.timestamps,'data',beta_data.est','chanlabels',{'freq','lambda','theta','phi','amp'});

thr = 0.6;
timewins = contbouts(r_squared_cdat,'datargunits','data','thresh',thr,'minevdur',0.25,'mindur',0.5,'window',0.1,'interp',true)

%thr = [2 10];
%timewins = contbouts(r_squared_cdat,'datargunits','data','thresh',thr,'thresh_fn',@gh_between,'minevdur',0.25,'mindur',0.25,'window',0.1,'interp',false)

total_time = sum(diff(timewins,[],2))

%timewins [];

[f, mu_list, trodexy] = sdat_phase_pref(mua_run,mnil_rat_conv_table,'timewin',timewins);
title('run')

X = [ones(size(trodexy,1),1), trodexy(:,1), trodexy(:,2)];
this_y = mu_list;
[b,bint,r,rint,stats] = regress(this_y,X); % try find b(1:3) so that y = b(0) + b(1)*x + b(2)*y
dphase_by_dx = b(2);
dphase_by_dy = i*b(3);
increasing_phase_vec = dphase_by_dx + dphase_by_dy; % radians of oscillation per mm
wave_angle = angle(increasing_phase_vec);
lambda = 2*pi+abs(1/increasing_phase_vec);

figure;
quiver(0,0,lambda*cos(wave_angle),lambda*sin(wave_angle),'LineWidth',4);
hold on;
%lambda = 15;
%wave_angle = -pi/2;
quiver(0,0,lambda*cos(wave_angle),lambda*sin(wave_angle),'LineWidth',4);
axis equal;