
%% Load DATA
% input = [];
% output = [];
% 
% exp = j22;
% ep = 'amprun';
% 
% input.exp = exp;
% input. ep = ep;
% 
% saveData = 0;
% 
% [directory date] = fileparts(exp.edir);
% [directory animal] = fileparts(directory);
% 
% if isfield('position', exp.(ep))
%     pos = exp.(ep).position.lin_pos;
%     vel = exp.(ep).position.lin_vel;
%     pts = exp.(ep).position.timestamp;
% else
%     pos = exp.(ep).pos.lp;
%     vel = exp.(ep).pos.lv;
%     pts = exp.(ep).pos.ts;
% end
% 
% i = 1;
% while isnan(pos(1))
%     pos(1) = pos(i);
%     i = i+1;
% end
%     
% while any(isnan(pos))
%     pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
% end
% %% clear data;
% data.amps = load_exp_amplitudes(input.exp,input.ep, 'threshold');
% %data.amps = ampsE1;
% 
% %% Variables
% vel_thold = .15;
%%
 clear input
 exp_in = exp11;
 ep_in = 'run';
 input = setup_decoding_inputs(exp_in, ep_in);
 saveData = 200;
 input.t_range = exp_in.(ep_in).et;
 input.d_range = input.t_range;
%% Script Specific setup


input.data{1} = select_amps_by_feature(input.raw_amps,'feature', 'col', 'col_num', 8, 'range', input.param.spike_width);
input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', input.param.amp_thold);
input.method{1} = 'Reconstructed Position';


output = [];
matlabpool('open',7);
nShuffle = 0;
for i=1:nShuffle+1
    if i==1
        d = input.data{1};
    else
        d = shuffle_amps(input.data{1}, input.t_range);
    end
 
    tic;
    disp(['Decoding: ', num2str(i)]);
    [output.est{i} output.tbins output.pbins output.edges] =...
        decode_amplitudes_par(d, input.pos.lp', input.t_range, input.d_range, 'amp_kw',[30 30 30 30], 'dt', .010);
    output.elapsed_time(i) = toc;
    toc;
end
matlabpool close




%% Plot the example
plot_decoding_example(input,output);
