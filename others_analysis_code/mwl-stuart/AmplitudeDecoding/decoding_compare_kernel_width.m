%%
%% OLD OLD OLD
%% OLD OLD OLD
%% OLD OLD OLD
%% OLD OLD OLD
%%
%% Variables
vel_thold = .15;

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

i = 1;
while isnan(pos(1))
    pos(1) = pos(i);
    i = i+1;
end

while any(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end

%% Load Data Amplitues --------------------------
clear amps_sqr amps_sqr sqrt_amps amps_m ns method
amps = load_tetrode_amps(exp15,'run');
amps = select_amps_by_feature(amps,'feature','col','col_num',8,'range',[12 40]);

kw = [1 3 5 10 15 20 25 35 50];


%% Decode using both Limited Amplitude Ranges

et = exp15.run.et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];

t_range = r1;
d_range = r2;
%%


tic;
for i=1:numel(kw)
    disp(['Decoding: ', num2str(i), ' of: ' , num2str(numel(kw)), ' estimates']);
    [est{i} tbins pbins] = decode_amplitudes_par(amps{1}, pos', t_range, d_range,...
        'amp_kw', repmat(kw(i),1,4), 'wb',1,'wb_color', 'y');
    method{i} = ['', num2str(kw(i)), ' uV'];
end
t = toc;

disp(['Decoded: ', num2str(diff(d_range)), ' seconds of data ', num2str(numel(est)), ' times in ', num2str(t), ' seconds']);

%%
plot_amp_decoding_estimate_errors(est,exp.(ep).pos, 'decode_range', d_range, 'legend', method);