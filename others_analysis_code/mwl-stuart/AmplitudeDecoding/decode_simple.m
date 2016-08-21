
%% Load DATA
exp = exp15;
ep = 'run';


et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];
r2 = [r2(1), r2(1)+1000];

t_range = r1;
d_range = r2;


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

vel_thold = .1;
%% Load the actual tetrode data
[amps_bkp] = load_tetrode_amps(exp,ep, 'threshold', 80);

%% decode

[amps ns] = select_amps_by_feature(amps, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
[amps ns] = select_amps_by_feature(amps, 'feature', 'amplitude', 'range', [150 Inf]);
%%
tic; 
e1 = decode_amplitudes(amps, pos', t_range, d_range);
toc;

tic; 
e2 = decode_amplitudes_par(amps, pos', t_range, d_range);
toc;

    
%%
pdf = plot_amp_est(est, tbins, pbins, exp.(ep).pos);
%% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)
[me e f x fl fu im] = plot_amp_decoding_estimate_errors(est,exp.(ep).pos, 'decode_range', d_range, 'legend', method, 'smooth', 1);

%% Box plot of the statistics
clear xs;

my_fn = @(x) nanmedian(abs(x));

fn = my_fn;
for i=1:numel(x)
    xs(:,i) = bootstrp(2000, fn, e{i}(im));
end

figure;
boxplot(xs, 'notch', 'on', 'labels', method);
grid on;
title(func2str(fn));   
mean_plot(xs, 'marker', 'o', 'labels', method)
    
    

