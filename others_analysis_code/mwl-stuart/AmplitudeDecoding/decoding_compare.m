%% Variables
vel_thold = .1;

%% Load DATA
exp = exp10;
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
clear amps_th ns_th sqrt_amps amps_m ns method

th = [85, Inf];

[amps{1} ns{1}] = load_tetrode_amps(exp,ep);    
[amps{2} ns{2}] = select_amps_by_feature(amps{1}, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
[amps{3} ns{3}] = load_tetrode_amps(exp,ep,'scale_amplitudes', 1);
[amps{4} ns{4}] = select_amps_by_feature(amps{3}, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
method = {'All Data', 'Spikes >300 us Wide', 'Sqrt', 'Sqrt Wide' };





%% Decode using both Limited Amplitude Ranges

et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];

t_range = r1;
d_range = r2;

dt = .3;
clear est tbins pbins p;

k = [10 10 10 10; .5 .5 .5 .5];
for i=1:numel(amps)
    disp(i);
    if i<=2
        kw = k(1,:);
    elseif i<=4
        kw = k(2,:);
    end  
    tic;
    est{i} = decode_amplitudes(amps{i}, pos', t_range, d_range, 'dt', dt, 'amp_kw', kw);
    t(i) = toc;
end
t




%% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)
plot_amp_decoding_estimate_errors(est,exp.(ep).pos, 'decode_range', d_range, 'legend', method);