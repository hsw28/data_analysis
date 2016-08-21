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
clear amps_th ns_th sqrt_amps amps_m ns method


amps_d = amps;

for i=1:numel(amps_d)
    amps_d{i}(:,6) = (amps_d{i}(:,6) .* sign(amps_d{i}(:,7))) + 3.1;
end

pos_d = (pos .* sign(vel)) + 3.1;



%% Decode using both Limited Amplitude Ranges

et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];

t_range = r1;
d_range = r2;

dt = .3;
%clear est tbins pbins p;

k = [10 10 10 10; .5 .5 .5 .5];
tic;
[est_d  tb pb p]= decode_amplitudes(amps_d, pos_d', t_range, d_range);
toc;






%% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)
plot_amp_decoding_estimate_errors(est,exp.(ep).pos, 'decode_range', d_range, 'legend', method);