

epochs = {'control', 'midazolam'};
%% - Load data
d.Run = exp_xcorr(exp, 'use_frames', 0, 'lags', -.200:.001:.200);
d.Ripples = exp_xcorr(exp, 'use_frames', 1, 'lags', -.0125:.001:.0125);


[en et ] =load_epochs(ses);
t_run_con = diff(et(find(ismember(en, epochs{1})),:));
t_run_mid = diff(et(find(ismember(en, epochs{2})),:));
d.Run.control.c = (d.Run.control.c)./t_run_con;
d.Run.midazolam.c = (d.Run.midazolam.c)./t_run_mid;

n_rip_con = size(exp.(epochs{1}).frame_times, 1);
n_rip_mid = size(exp.(epochs{2}).frame_times, 1);
d.Ripples.control.c = (d.Ripples.control.c)./n_rip_con;
d.Ripples.midazolam.c = (d.Ripples.midazolam.c)./n_rip_mid;

%% Plot Firing correlations

figure; 
subplot(221); plot(d.Run.midazolam.c'); title('Run Midazolam');
subplot(222); plot(d.Run.control.c'); title('Run Control');
subplot(223); plot(d.Ripples.midazolam.c'); title('ripple Midazolam');
subplot(224); plot(d.Ripples.midazolam.c'); title('ripple control');

%% - Plot Distributions - Spatial Correlation
figure; x = 0; y =0;
for i = {'Run', 'Ripples'}
    a=i{1};
    for j={'midazolam', 'control'}
        b=j{1};
        y = y+1;
        subplot(2,2,y);
        plot(d.(a).(b).fd1, sum(d.(a).(b).c,2), '.' ,...
             d.(a).(b).fd2, sum(d.(a).(b).c,2), 'r.', 'MarkerSize', 10);
         
        xlabel('Rate Map Spatial Correlation');
        ylabel('sum(PSTH)');
        title([b, ' ', a]);
    end
end

%% - Plot Distributions - Center of Mass 
figure; x = 0; y =0; clear ax;
for i = {'Run', 'Ripples'}
    a=i{1};
    for j={'midazolam', 'control'}
        b=j{1};
        y = y+1;
        subplot(2,2,y);
        plot(d.(a).(b).com_d1, sum(d.(a).(b).c,2), '.' ,...
             d.(a).(b).com_d2, sum(d.(a).(b).c,2), 'r.', 'MarkerSize', 10);
         
        xlabel('Distance in Rate map C.O.M.');
        ylabel('sum(PSTH)');
        title([b, ' ', a]);
        ax(y) = gca;
    end
end
set(ax(1), 'Units', 'Normalized', 'Position', [.05, .55, .4, .40]);
set(ax(2), 'Units', 'Normalized', 'Position', [.05,  .05, .4, .40]);
set(ax(3), 'Units', 'Normalized', 'Position', [.55, .55, .4, .40]);
set(ax(4), 'Units', 'Normalized', 'Position', [.55, .05, .4, .40]); 



%% - 5 point plots, based on Center of mass
figure; y=0; classes = []; clear ax;
for i = {'Run', 'Ripples'}
    time=i{1};
    for j={'midazolam', 'control'}
        y = y+1;
        ep=j{1};
        classes = nan(length(d.(time).(ep).com_d1),1);
        if strcmp(ep, 'control')
            thold1 = 4;
            thold2 = 7;
        else
            thold1 = 10;
            thold2 = 20;
        end
        ind1 = abs(d.(time).(ep).com_d1)<=thold1;
        ind2 = abs(d.(time).(ep).com_d1)>thold1 & abs(d.(time).(ep).com_d1)<=thold2;
        ind3 = abs(d.(time).(ep).com_d1)>thold2;
        classes(ind1) =1;
        classes(ind2) =0;
        classes(ind3) =-1;
        subplot(2,2,y);
        boxplot(sum(d.(time).(ep).c,2), classes, 'Notch', 'on');
        ax(y) = gca;
        title([ep, ' ', time, ' 0 distal 1 near PF, XCORR']);
    end
end
set(ax(1), 'Units', 'Normalized', 'Position', [.05, .55, .4, .40]);
set(ax(2), 'Units', 'Normalized', 'Position', [.05,  .05, .4, .40]);
set(ax(3), 'Units', 'Normalized', 'Position', [.55, .55, .4, .40]);
set(ax(4), 'Units', 'Normalized', 'Position', [.55, .05, .4, .40]); 




%% - Plot Distributions 2
figure; 
thold = 2;

subplot(221);  plot(sum(d.Run.control.c')); title('Run Control');
a1 = gca();
subplot(222);  plot(sum(d.Ripples.control.c')); title('Ripples Control');
a2 = gca();
subplot(223);  plot(sum(d.Run.midazolam.c')); title('Run Midazolam');
a3 = gca();
subplot(224);  plot(sum(d.Ripples.midazolam.c')); title('Ripples Midazolam');
a4 = gca();

m1 = mean(sum(d.Run.control.c'));
s1 = std(sum(d.Run.control.c'));
line([0 size(sum(d.Run.control.c'),2)], [m1+thold*s1 m1+thold*s1], 'Parent', a1 );

m2 = mean(sum(d.Ripples.control.c'));
s2 = std(sum(d.Ripples.control.c'));
line([0 size(sum(d.Ripples.control.c'),2)], [m2+thold*s2 m2+thold*s2], 'Parent', a2 );

m3 = mean(sum(d.Run.midazolam.c'));
s3 = std(sum(d.Run.midazolam.c'));
line([0 size(sum(d.Run.midazolam.c'),2)], [m3+thold*s3 m3+thold*s3], 'Parent', a3 );

m4 = mean(sum(d.Ripples.midazolam.c'));
s4 = std(sum(d.Ripples.midazolam.c'));
line([0 size(sum(d.Ripples.midazolam.c'),2)], [m4+thold*s4 m4+thold*s4], 'Parent', a4 );

%% - 5 Point Summary plots

runc_ind = find(sum(d.Run.control.c')>m1+thold*s1);
ripc_ind = find(sum(d.Ripples.control.c')>m2+thold*s2);
runm_ind = find(sum(d.Run.midazolam.c')>m3+thold*s3);
ripm_ind = find(sum(d.Ripples.midazolam.c')>m4+thold*s4);

temp = sum(d.Run.control.c');
run_c = temp(runc_ind);
temp = sum(d.Ripples.control.c');
rip_c = temp(ripc_ind);

temp = sum(d.Run.midazolam.c');
run_m = temp(runm_ind);
temp = sum(d.Ripples.midazolam.c');
rip_m = temp(ripm_ind);

figure;
subplot(211);
plot(repmat(1, size(run_c)), run_c,'.',...
     repmat(2, size(run_m)), run_m, '.');
 set(gca, 'XLim', [.5 2.5]); title('Run');
 
subplot(212);
plot(repmat(1, size(rip_c)), rip_c,'.',...
     repmat(2, size(rip_m)), rip_m, '.');
 set(gca, 'XLim', [.5 2.5]); title('Ripple');
 
 
 
%% - compute Boot Strap
bs_run_m = bootstrp(1000, @mean, d.Run.midazolam.c);
bs_run_c = bootstrp(1000, @mean, d.Run.control.c);
bs_rip_m = bootstrp(1000, @mean, d.Ripples.midazolam.c);
bs_rip_c = bootstrp(1000, @mean, d.Ripples.control.c);

%% Plot boot straps
figure; 
subplot(221);
plot(mean(bs_run_m),'k'); hold on;
plot(mean(bs_run_m)+2*std(bs_run_m), 'r');
plot(mean(bs_run_m)-2*std(bs_run_m), 'r');
title('Run Midazolam');

subplot(222);
plot(mean(bs_run_c),'k'); hold on;
plot(mean(bs_run_c)+2*std(bs_run_c), 'r');
plot(mean(bs_run_c)-2*std(bs_run_c), 'r');
title('Run Control');


subplot(223);
plot(mean(bs_rip_m),'k'); hold on;
plot(mean(bs_rip_m)+2*std(bs_rip_m), 'r');
plot(mean(bs_rip_m)-2*std(bs_rip_m), 'r');
title('Ripple Midazolam');


subplot(224);
plot(mean(bs_rip_c),'k'); hold on;
plot(mean(bs_rip_c)+2*std(bs_rip_c), 'r');
plot(mean(bs_rip_c)-2*std(bs_rip_c), 'r');
title('Ripple Control');



