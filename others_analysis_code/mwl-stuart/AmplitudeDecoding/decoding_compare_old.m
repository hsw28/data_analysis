%% Decoding Compare:
%% Variables
vel_thold = .1;


%% Load DATA
exp = exp15;
ep = 'run';

if isfield('position', exp.(ep))
    pos = exp.(ep).position.lin_pos;
    vel = exp.(ep).position.lin_vel;
    pts = exp.(ep).position.timestamp;
else
    pos = exp.(ep).pos.lp;
    vel = exp.(ep).pos.lv;
    pts = exp.(ep).pos.ts;
end

while any(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end

%% Amplitues --------------------------
[amps id] = load_tetrode_amps(exp,ep);
[sqrt_amps id] = load_tetrode_amps(exp,ep,'scale_amplitudes',1);
[amps_m{1} id] = load_tetrode_amps(exp,ep,'threshold', 80, 'max_thold', 150);
[amps_m{2} id] = load_tetrode_amps(exp,ep,'threshold', 80, 'max_thold', 140);
[amps_m{3} id] = load_tetrode_amps(exp,ep,'threshold', 80, 'max_thold', 130);
[amps_m{4} id] = load_tetrode_amps(exp,ep,'threshold', 80, 'max_thold', 120);
[amps_m{5} id] = load_tetrode_amps(exp,ep,'threshold', 80, 'max_thold', 110);
[amps_m{6} id] = load_tetrode_amps(exp,ep,'threshold', 80, 'max_thold', 100);
[amps_m{7} id] = load_tetrode_amps(exp,ep,'threshold', 80, 'max_thold', 90);
[amps_m{8} id] = load_tetrode_amps(exp,ep,'threshold', 73, 'max_thold', 90);
[amps_m{9} id] = load_tetrode_amps(exp,ep,'threshold', 73, 'max_thold', 85);

%% Clusters ---------------------------
if isfield(exp.(ep), 'clusters')
    spike_times = {exp.(ep).clusters.time};
else
    spike_times = {exp.(ep).cl.st};
end
cl = convert_cluster_format(spike_times, pos,  vel, pts);

%% Decode using both Limited Amplitude Ranges
%r1 = [2426 2931]
%r2 = [2942 3575];

%r3 = [2434 3478];
%r4 = [3496 3569];
%t_range = [2426 3455];
%d_range = [3500 3520];
et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];

t_range = r1;
d_range = r2;

dt = .3;
clear est tbins pbins p;
tic;
[est{1} tbins{1} pbins{1} p{1}] = decode_amplitudes(amps, pos', t_range, d_range, 'dt', dt);
[est{2} tbins{2} pbins{2} p{2}] = decode_amplitudes(sqrt_amps, pos', t_range, d_range, 'dt', dt, 'amp_kw', sqrt([10 10 10 10]));
[est{3} tbins{3} pbins{3} p{3}] = decode_amplitudes(amps_m{1}, pos', t_range, d_range, 'dt', dt);
[est{4} tbins{4} pbins{4} p{4}] = decode_amplitudes(amps_m{2}, pos', t_range, d_range, 'dt', dt);
[est{5} tbins{5} pbins{5} p{5}] = decode_amplitudes(amps_m{3}, pos', t_range, d_range, 'dt', dt);
[est{6} tbins{6} pbins{6} p{6}] = decode_amplitudes(amps_m{4}, pos', t_range, d_range, 'dt', dt);
[est{7} tbins{7} pbins{7} p{7}] = decode_amplitudes(amps_m{5}, pos', t_range, d_range, 'dt', dt);
[est{8} tbins{8} pbins{8} p{8}] = decode_amplitudes(amps_m{6}, pos', t_range, d_range, 'dt', dt);
[est{9} tbins{9} pbins{9} p{9}] = decode_amplitudes(amps_m{7}, pos', t_range, d_range, 'dt', dt);
[est{10} tbins{10} pbins{9} p{10}] = decode_amplitudes(amps_m{8}, pos', t_range, d_range, 'dt', dt));
t = toc;
disp(['Decoded: ', num2str(diff(r2)), ' seconds of data ', num2str(numel(est)), ' times in ', num2str(t), ' seconds']);
methods = {'Ampl', 'SQRT(Amp)', 'Thold:80-150uV', 'Thold:80-140uV', ...
    'Thold:80-130uV', 'Thold:80-120uV', 'Thold:80-110uV', 'Thold:80-100uV',...
    'Thold:80-90uV'};
%% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)
clear sm_est m max_ind estimated_pos ismoving e1 f1 f1m x1 x1m tbins interp_pos f x;

tbins = d_range(1):dt:d_range(2)-dt;
interp_pos = interp1(pts, pos, tbins);


for i=1:numel(est);
    
    sm_est{i} = smoothn(est{i},3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    [m max_ind] = max(sm_est{i});   
    pbins = 0:.1:3.1 %p{i}.stimulus_grid{1};
    
    estimated_pos{i} = pbins(max_ind);

    ismoving = logical(interp1(pts, abs(vel)>=vel_thold, tbins, 'nearest'));

    e1 = abs(estimated_pos{i}-interp_pos);


    [f{i} x{i}] = ecdf(e1(ismoving));
end
%%
c= 'rkbgmcyrkbgmcy';
s = {'-', '--'};
figure;
for i=1:numel(f)
    line(x{i},f{i}, 'color',c(i), 'LineWidth', 2, 'LineStyle', s{(i>numel(c))+1});
end
for i=1:numel(f)
    p1 = [median(x{i}), .05];
    p2 = [median(x{i}), 0];
    arrow(p1, p2, 'length', 3, 'facecolor', c(i), 'edgecolor', c(i));
end
legend(methods(3:end));
set(gca,'XTick', 0:.25:3.1);
grid on;
title('CDF of Decoding Errors');
xlabel('meters');
ylabel('% errors');
%% Decode using both SQRT Amplitude
%r1 = [2426 2931]
%r2 = [2942 3575];

%r3 = [2434 3478];
%r4 = [3496 3569];
%t_range = [2426 3455];
%d_range = [3500 3520];
et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];

t_range = r1;
d_range = r2;

dt = .3;
clear est tbins pbins p;
[sqrt_amps id] = load_tetrode_amps(exp,ep,'scale_amplitudes',1);
tic;
param = [2 4 6 8 10 14 18 25 1 .75 .5];

for i=1:numel(param)
    disp(['Computing Estimate: ', num2str(i)]);
    [est_p{i} tbins_p{i} pbins_p{i}, p_p{i}] = decode_amplitudes(sqrt_amps, pos', t_range, d_range, 'dt', dt, ...
        'amp_kw', sqrt([param(i) param(i) param(i) param(i)]));
    methods{i} = num2str(param(i));
end
t = toc;
disp(['Decoded: ', num2str(diff(r2)), ' seconds of data ', num2str(numel(est_p)), ' times in ', num2str(t), ' seconds']);
%methods = {'Ampl', 'SQRT(Amp)', 'Thold:80-150uV', 'Thold:80-140uV', ...
%    'Thold:80-130uV', 'Thold:80-120uV', 'Thold:80-110uV', 'Thold:80-100uV',...
%    'Thold:80-90uV'};
%% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)
clear sm_est m max_ind estimated_pos ismoving e1 f1 f1m x1 x1m tbins interp_pos f x;

tbins = d_range(1):dt:d_range(2)-dt;
interp_pos = interp1(pts, pos, tbins);

for i=1:numel(est_p);
    
    sm_est{i} = smoothn(est_p{i},3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    [m max_ind] = max(sm_est{i});   
    pbins = p_p{i}.stimulus_grid{1};
    
    estimated_pos{i} = pbins(max_ind);

    ismoving = logical(interp1(pts, abs(vel)>=vel_thold, tbins, 'nearest'));

    e1 = abs(estimated_pos{i}-interp_pos);


    [f{i} x{i}] = ecdf(e1(ismoving));
end

c= 'rkbgmcyrkbgmcy';
s = {'-', '--'};
figure;
for i=1:numel(f)
    line(x{i},f{i}, 'color',c(i), 'LineWidth', 2, 'LineStyle', s{(i>numel(unique(c)))+1});
end
for i=1:numel(f)
    p1 = [median(x{i}), .05];
    p2 = [median(x{i}), 0];
    arrow(p1, p2, 'length', 3, 'facecolor', c(i), 'edgecolor', c(i));
end
legend(methods);
set(gca,'XTick', 0:.25:3.1);
grid on;
title('CDF of Decoding Errors');
xlabel('meters');
ylabel('% errors');

%% Old comparison
smest1 = smoothn(est1,3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
[m i1] = max(smest1);
smest2 = smoothn(est2,3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
[m i2] = max(smest2);
smest3 = smoothn(est3,3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
[m i3] = max(smest3);

tbins = d_range(1):.3:d_range(2)-.3;
pp1 = interp1(pts, pos, tbins);
pp2 = interp1(pts, pos, tbins2);
pp3 = interp1(pts, pos, tbins3);

ep1 = pbins1(i1);
ep2 = pbins(i2);
ep3 = pbins(i3);


ismoving1 = logical(interp1(pts, abs(vel)>=vel_thold, tbins, 'nearest'));
ismoving2 = logical(interp1(pts, abs(vel)>=vel_thold, tbins2, 'nearest'));
ismoving3 = logical(interp1(pts, abs(vel)>=vel_thold, tbins3, 'nearest'));

e1 = abs(ep1-pp1);
e2 = abs(ep2-pp2);
e3 = abs(ep3-pp3);


[f1 x1] = ecdf(e1);
[f1m x1m] = ecdf(e1(ismoving1));
[f2 x2] = ecdf(e2);
[f2m x2m] = ecdf(e2(ismoving2));
[f3 x3] = ecdf(e3);
[f3m x3m] = ecdf(e3(ismoving1));


figure;
line(x1,f1, 'color','r', 'LineStyle', '--', 'LineWidth', 2);
line(x1m,f1m,'color', 'r', 'LineWidth', 2);
line(x2,f2, 'color','k', 'LineStyle', '--', 'LineWidth', 2);
line(x2m,f2m,'color', 'k', 'LineWidth', 2);
line(x3,f3, 'color','b', 'LineStyle', '--', 'LineWidth', 2);
line(x3m,f3m,'color', 'b', 'LineWidth', 2);

line(median(x1m), 1, 'color', 'r', 'marker', '*', 'MarkerSize',4);
line(mean(x2m), 1, 'color', 'k', 'marker', '*', 'MarkerSize',4);
line(mean(x3m), 1, 'color', 'b', 'marker', '*', 'MarkerSize',4);
legend({'Amp', 'Amp Run', 'Clust', 'Clust Run', 'Had', 'Had Run'});
%legend({'KDE Amplitude', 'Clustered', 'KDE Hadamard'});
title('SPL07D12: Compared CDF Decoding Errors');
xlabel('meters');
ylabel('% errors');

%% Compute Estimate Try Different Parameters
t_range = r3;
d_range = r4;

param1 = [1 5 10 15 20 25 30 35 40 45 50];
clear est_p1;
disp('Varying amp kernel width: short');
for i = 1:numel(param1)
    disp([num2str(i), '  of ', num2str(numel(param1))]);
    [est_p1(:,:,i), tbins, pbins] = decode_amplitudes(amps, pos', t_range, d_range, 'amp_kw', repmat(param1(i),1,4));
end

param2 = [.01 .02 .05 .075 .1 .15 .2 .25 .4 .5];
clear est_p2;
disp('Varying dt: short');
for i = 1:numel(param2)
    disp([num2str(i), '  of ', num2str(numel(param2))]);
    [est_p2{i}, tbins_v{i}, pbins] = decode_amplitudes(amps, pos', t_range, d_range, 'dt', param2(i));
end

param3 = [.01 .05 .1 .15 .2];
clear est_p3
disp('Varying pos kernel width: short');
for i = 1:numel(param3)
    disp([num2str(i), '  of ', num2str(numel(param3))]);
    [est_p3(:,:,i), tbins, pbins] = decode_amplitudes(amps, pos', t_range, d_range, 'pos_kw', param3(i));
end


t_range = r1;
d_range = r2;

param1 = [1 5 10 15 20 25 30 35 40 45 50];
clear est_p1l;
disp('Varying amp kernel width: long');
for i = 1:numel(param1)
    disp([num2str(i), '  of ', num2str(numel(param1))]);
    [est_p1l(:,:,i), tbins, pbins] = decode_amplitudes(amps, pos', t_range, d_range, 'amp_kw', repmat(param1(i),1,4));
end

param2 = [.01 .02 .05 .075 .1 .15 .2 .25 .4 .5];
clear est_p2l;
disp('Varying dt: long');
for i = 1:numel(param2)
    disp([num2str(i), '  of ', num2str(numel(param2))]);
    [est_p2l{i}, tbins_vl{i}, pbins] = decode_amplitudes(amps, pos', t_range, d_range, 'dt', param2(i));
end

param3 = [.01 .05 .1 .15 .2];
clear est_p3l
disp('Varying pos kernel width: long');
for i = 1:numel(param3)
    disp([num2str(i), '  of ', num2str(numel(param3))]);
    [est_p3l(:,:,i), tbins, pbins] = decode_amplitudes(amps, pos', t_range, d_range, 'pos_kw', param3(i));
end
%% Compute Errors -Resp Kernel Width
figure;
ax = axes();
c = ('rgbmkrgbmkcrgbmk')';
s = {'--'; '-'};% '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.'};
clear f x leg;
for i=1:size(est_p1l,3)
    e = est_p1l(:,:,i);
    e = smoothn(e, 'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    n_t = size(e,2);
    dt = abs(diff(d_range))/n_t;
    tbins = d_range(1):dt:d_range(2)-dt;
    [m ind] = max(e);
    p = interp1(pts, pos, tbins(1:end-1));
    p_est = pbins(ind);
    ismoving = logical(interp1(pts, abs(vel)>=vel_thold, tbins(1:end-1), 'nearest'));
    er(i,:) = abs(p_est(ismoving) - p(ismoving));
    [a b] = ecdf(er(i,:));
    f{i} = a;
    x{i} = b;
    
    
    line(b,a, 'Parent', ax, 'Color', c(i), 'LineStyle', s{mod(i,2)+1}, 'LineWidth', 3);
    leg{i} = num2str(param1(i));
end
legend(leg);
title('CDF of Errors, Varied Resp Kernel Width');
%% Compute Errors -Recond DT
figure;
ax = axes();
c = ('rgbmkrgbmkcrgbmk')';
s = {'--'; '-'};% '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.'};
clear f x leg er;
for i=1:numel(est_p2l)
    e = est_p2l{i};
    e = smoothn(e, 'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    n_t = size(e,2);
    dt = abs(diff(d_range))/n_t;
    tbins = d_range(1):dt:d_range(2)-dt;
    [m ind] = max(e);
    p = interp1(pts, pos, tbins(1:end-1));
    p_est = pbins(ind);
    ismoving = logical(interp1(pts, abs(vel)>=vel_thold, tbins(1:end-1), 'nearest'));
    er{i} = abs(p_est(ismoving) - p(ismoving));
    [a b] = ecdf(er{i});
    f{i} = a;
    x{i} = b;
    
    
    line(b,a, 'Parent', ax, 'Color', c(i), 'LineStyle', s{mod(i,2)+1}, 'LineWidth', 3);
    leg{i} = num2str(param2(i));
end
legend(leg);
title('CDF of Errors, Varied decode dt');
%% Compute Errors - Stim Kernel Width
figure;
ax = axes();
c = ('rgbmkrgbmkcrgbmk')';
s = {'--'; '-'};% '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.'};
clear f x leg er;
for i=1:size(est_p3l,3)
    e = est_p3l(:,:,i);
    e = smoothn(e, 'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    n_t = size(e,2);
    dt = abs(diff(d_range))/n_t;
    tbins = d_range(1):dt:d_range(2)-dt;
    [m ind] = max(e);
    p = interp1(pts, pos, tbins(1:end-1));
    p_est = pbins(ind);
    ismoving = logical(interp1(pts, abs(vel)>=vel_thold, tbins(1:end-1), 'nearest'));
    er(i,:) = abs(p_est(ismoving) - p(ismoving));
    [a b] = ecdf(er(i,:));
    f{i} = a;
    x{i} = b;
    
    
    line(b,a, 'Parent', ax, 'Color', c(i), 'LineStyle', s{mod(i,2)+1}, 'LineWidth', 3);
    leg{i} = num2str(param3(i));
end
legend(leg);
title('CDF of Errors, Varied Stim Kernel Width');
%% Compute Estimates using different Thresholds
t_range = r1;
d_range = r2;

param_th = [75:10:150];

clear est_th;
disp('Varying amp threshold');

for i = 1:numel(param_th)
    amps_v = load_tetrode_amps(exp,ep, 'threshold', param_th(i));
    disp([num2str(i), '  of ', num2str(numel(param_th))]);
    [est_th(:,:,i), tbins, pbins] = decode_amplitudes(amps_v, pos', t_range, d_range);
end

%% Plot Errors for varying thresholds
%figure;

c = ('rgbmkrgbmkcrgbmk')';
s = {'--'; '-'};% '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.'};
clear f x leg er;
subplot(5,1,1:3)
for i=1:size(est_th,3)
    e = est_th(:,:,i);
    e = smoothn(e, 'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    n_t = size(e,2);
    dt = abs(diff(d_range))/n_t;
    tbins = d_range(1):dt:d_range(2)-dt;
    [m ind] = max(e);
    p = interp1(pts, pos, tbins(1:end-1));
    p_est = pbins(ind);
    ismoving = logical(interp1(pts, abs(vel)>=vel_thold, tbins(1:end-1), 'nearest'));
    er(i,:) = abs(p_est(ismoving) - p(ismoving));
    [a b] = ecdf(er(i,:));
    f{i} = a;
    x{i} = b;
    
    
    line(b,a, 'Color', c(i), 'LineStyle', s{mod(i,2)+1}, 'LineWidth', 3);
    leg{i} = num2str(param_th(i));
end
legend(leg);
title('CDF of Errors, Varied Spike Thresholds');
subplot(5,1,4:5);
plot(mean(er,2)); set(gca,'XTickLabel', param_th); xlabel('Threshold'); ylabel('Mean Error'); 


%% Compute Estimates using different Hadamard
clear est_h;
disp('Varying Hadamard RKW');

amps_h = load_tetrode_amps(exp,ep,'hadamard',1);
param_rkw = [1 3 7 10 15 20 25 30 35];
for i = 1:numel(param_rkw)
    disp([num2str(i), '  of ', num2str(numel(param_rkw))]);
    [est_h(:,:,i), tbins, pbins pdec] = decode_amplitudes(amps_h, pos', t_range, d_range, 'amp_kw', repmat(param_rkw(i),1,4));
end


%% Plot Errors for Hadamard
figure;

c = ('rgbmkrgbmkcrgbmk')';
s = {'--'; '-'};% '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.';'--'; '-'; '-.'};
clear f x leg er;
subplot(5,1,1:3)
for i=1:size(est_h,3)
    e = est_h(:,:,i);
    e = smoothn(e, 'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    n_t = size(e,2);
    dt = abs(diff(d_range))/n_t;
    tbins = d_range(1):dt:d_range(2)-dt;
    [m ind] = max(e);
    p = interp1(pts, pos, tbins(1:end-1));
    p_est = pbins(ind);
    ismoving = logical(interp1(pts, abs(vel)>=vel_thold, tbins(1:end-1), 'nearest'));
    er(i,:) = abs(p_est(ismoving) - p(ismoving));
    [a b] = ecdf(er(i,:));
    f{i} = a;
    x{i} = b;
    
    
    line(b,a, 'Color', c(i), 'LineStyle', s{mod(i,2)+1}, 'LineWidth', 3);
    leg{i} = num2str(param_rkw(i));
end
legend(leg);
title('CDF of Errors, Varied Resp Kernel Width (Hadamard)');
subplot(5,1,4:5);
plot(mean(er,2)); set(gca,'XTickLabel', param_rkw); xlabel('Response Kernel Width'); ylabel('Mean Error'); 



    


