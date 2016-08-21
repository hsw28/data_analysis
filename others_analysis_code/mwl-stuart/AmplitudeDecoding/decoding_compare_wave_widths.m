
%% Load DATA
%exp = exp15;

clear vel pts pos vel_thold directory animal date r1 r2 et me e f x fl flu;
input = [];
output = [];

input.exp = exp;
input.ep = ep;

[directory date] = fileparts(exp.edir);
[directory animal] = fileparts(directory);

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
input.all_amps = load_tetrode_amps(exp,'run');
vel_thold = .15;
%% Amplitues --------------------------


input.pos = pos;
input.data{1} = select_amps_by_feature(input.all_amps, 'feature', 'amplitude', 'range', [125 Inf]);
input.method{1} = 'All Spikes';
input.data{2} = select_amps_by_feature(input.data{1}, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
input.method{2} = 'Wide Spikes';
input.data{3} = select_amps_by_feature(input.data{1}, 'feature', 'col', 'col_num', 8, 'range', [0 12]);
input.method{3} = 'Narrow Spikes';



%% Decode using both Limited Amplitude Ranges

et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];

input.t_range = r1;
input.d_range = r2;
%% Compute the Estimate

for i=1:numel(input.data)
    tic;
    [output.est{i} output.tbins output.pbins] = decode_amplitudes(input.data{i}, input.pos', input.t_range, input.d_range, 'wb', 0);
    output.elapsed_time(i) = toc;
    input.n_spike(i) = sum(cellfun(@numel,input.data{i}));
    toc;
end
%% PLOT the CDF Of the Estimate ERRORS
[output.me output.e output.f output.x] = plot_amp_decoding_estimate_errors(output.est,input.exp.(ep).pos, 'decode_range', input.d_range, 'legend', input.method);
set(gcf,'Name', [animal, ' : ', date, ' Waveform Width Filter']);

%% Save the Data


filename = ['Amp.Decoding.Spike.Width.', animal,'.',date,'.mat'];

save(filename, 'input', 'output');

clear vel pts pos vel_thold directory animal date r1 r2 et me e f x fl flu