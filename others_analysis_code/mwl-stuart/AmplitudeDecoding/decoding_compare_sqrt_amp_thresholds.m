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
clear amps_sqr amps_sqr sqrt_amps amps_m ns method

th = [85, Inf;...
     85, 200;...
     85, 150;...
     85, 130;...
     85, 110;...
     85, 90; ...
     70, 80; ...
     70, 75; ...
     110, Inf;...
     130, Inf;...
     150, Inf;...
     170, Inf;...     
     190, Inf;...
     220, Inf;
     ];
for i=1:size(th,1);
   % [amps_sqr{i} ns_sqr{i}] = load_tetrode_amps(exp,ep,'threshold',th(i,1), 'max_thold', th(i,2), 'scale_amplitudes', 1);
    method_th{i} = [num2str(th(i,1)), ' : ', num2str(th(i,2)), '  uV'];
end



%% Decode using both Limited Amplitude Ranges

et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];

t_range = r1;
d_range = r2;

dt = .3;
clear est_sqr tbins pbins p;

tic;
for i=1:numel(amps_sqr)
    est_sqr{i} = decode_amplitudes(amps_sqr{i}, pos', t_range, d_range, 'dt', dt, 'resp_kw', [1 1 1 1]);
end
t = toc;

disp(['Decoded: ', num2str(diff(r2)), ' seconds of data ', num2str(numel(est_sqr)), ' times in ', num2str(t), ' seconds']);

%% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)
clear sm_est m max_ind estimated_pos ismoving e1 f1 f1m x1 x1m tbins interp_pos f x;

tbins = d_range(1):dt:d_range(2)-dt;
interp_pos = interp1(pts, pos, tbins);

for i=1:numel(est_sqr);
    
    sm_est{i} = smoothn(est_sqr{i},3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    [m max_ind] = max(sm_est{i});   
    pbins = 0:.1:3.1;
    
    estimated_pos{i} = pbins(max_ind);

    ismoving = logical(interp1(pts, abs(vel)>=vel_thold, tbins, 'nearest'));

    e1 = abs(estimated_pos{i}-interp_pos);


    [f{i} x{i}] = ecdf(e1(ismoving));
end

c= 'rkbgmcyrkbgmcyrkbgmcy';
s = {'--', '-', '-.'};
figure;
for i=1:numel(f)
    line(x{i},f{i}, 'color',c(i), 'LineWidth', 2, 'LineStyle', s{ceil(i/7)});
end
for i=1:numel(f)
    me_sqrt{i} = median(x{i});
end
legend(method);
for i=1:numel(f)
    p1 = [me_th{i}, .05];
    p2 = [me_th{i}, 0];
    arrow(p1, p2, 'length', 3, 'facecolor', c(i), 'edgecolor', c(i));
end
set(gca,'XTick', 0:.25:3.1);
grid on;
title('CDF of Decoding Errors');
xlabel('meters');
ylabel('% errors');