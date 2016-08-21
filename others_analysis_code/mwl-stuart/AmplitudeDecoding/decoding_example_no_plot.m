
%% Load DATA
input = [];
output = [];

exp = exp15;
ep = 'amprun';

input.exp = exp;
input. ep = ep;


[directory date] = fileparts(exp.edir);
[directory animal] = fileparts(directory);

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
%% clear data;
data.amps = load_tetrode_amps(input.exp,input.ep, 'threshold');

%% Variables
vel_thold = .15;
%%
clear amps_f cl_f cl_anti_f resp_col; 

method = [];
input.exp = exp;
input.ep = ep;
input.data{1} = select_amps_by_feature(data.amps,'feature', 'col', 'col_num', 8, 'range', [12 40]);
input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', [125 Inf]);
input.method{1} = 'Reconstructed Position';

input.pos = pos;


%% Decode using both Amplitudes and Clustered Data

et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et), et(2)];

input.t_range = r1;
input.d_range = r2;

%% Shuffle Spikes



%% COMPUTE THE ESTIAMTE
%clear est tbins pbins p;


%[est{i} tbins pbins] = decode_clusters(input{i}, pos', t_range, d_range,
%'wb', 1, 'dt',5);
output = [];
matlabpool open 8

tic;
disp(['Decoding: ', num2str(1)]);
[output.est{1} output.tbins output.pbins output.edges] = decode_amplitudes_par(input.data{1}, input.pos', input.t_range, input.d_range);
toc;

nShuffle = 500;
for j=1:nShuffle
tic;
    disp(['Decoding: ', num2str(j+1)]);
    shuffled_amps = shuffle_amps(input.data{1}, r1);
    [output.est{j+1} output.tbins output.pbins output.edges] = decode_amplitudes_par(shuffled_amps, input.pos',...
	 input.t_range, input.d_range);
    toc;
end
matlabpool close
dt = mean(diff(output.tbins));



%% shuffle position estimates in time
for j = 1:nShuffle
    idx = randsample(size(output.est{1},2), size(output.est{1},2));
    output.est{end+1} = output.est{1}(:,idx);
end
input.method{3} = 'Shuffled Position Estimate';


%% Compute Statistics
nboot = 0;
[output.stats.errors output.stats.me output.stats.me_dist] = calc_recon_errors(output.est, output.tbins, output.pbins, input.exp.(ep).pos, 'n_boot', nboot);
[output.stats.mi output.stats.mi_dist] = calc_recon_mi(output.est, output.tbins, output.pbins, input.exp.(ep).pos, 'n_boot',nboot);

%% Plot the example
%plot_decoding_example(input,output, nShuffle, 'time_range', [4723.4 4803]);
%%
%%
miBins = 0:.25:3;
h1 = histc(output.stats.mi(2:nShuffles+1),miBins);
h2 = histc(output.stats.mi(nShuffles+2:end),miBins);

%figure; 
%plot(miBins, h1, 'b', miBins,h2, 'k', 'lineWidth', 2);

%% PDF of errors
h1 = histc(output.stats.errors{1}, bins);
h2 = histc(output.stats.errors{2}, bins);
h3 = histc(output.stats.errors{3}, bins);


%h1 = smoothn(h1,3);
%h2 = smoothn(h2,3);
%h3 = smoothn(h3,3);

%figure; 
%plot(bins,h1, bins, h2, bins, h3);

%% save the data

[directory date] = fileparts(exp.edir);
[directory animal] = fileparts(directory);

filename = ['Amp.Decoding.Example.With.Shuffles.', animal,'.',date, '.mat'];

save(filename, 'input', 'output');

