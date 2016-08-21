
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
 exp_in = fab21;
 ep_in = 'amprun';
 input = setup_decoding_inputs(exp_in, ep_in);
 saveData = 200;
%% Script Specific setup

clear amps_f cl_f cl_anti_f resp_col; 

input.data{1} = select_amps_by_feature(input.raw_amps,'feature', 'col', 'col_num', 8, 'range', input.param.spike_width);
input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', input.param.amp_thold);
input.method{1} = 'Reconstructed Position';


%% Shuffle Spikes
% nShuffle = 500;
% for j=1:nShuffle
%     input.data{j+1} = shuffle_amps(input.data{1}, input.t_range);
%     input.method{2} = 'Shuffled Source Spike Amplitudes';
% end


%% COMPUTE THE ESTIAMTE
%clear est tbins pbins p;


%[est{i} tbins pbins] = decode_clusters(input{i}, pos', t_range, d_range,
%'wb', 1, 'dt',5);
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
        decode_amplitudes_par(d, input.pos.lp', input.t_range, input.d_range, 'amp_kw',[30 30 30 30]);
    output.elapsed_time(i) = toc;
    toc;
end
matlabpool close
input.nShuffle = nShuffle;



%% Time Bin in time
for j = 1:nShuffle
    idx = randsample(size(output.est{1},2), size(output.est{1},2));
    output.est{end+1} = output.est{1}(:,idx);
end
if nShuffle>1
    input.method{3} = 'Shuffled Time Bins';
end
%%
e = output.est{1};
eOut = e;
for j=1:input.nShuffle
    for n=1:size(e,2)
       eOut(:,n) = circshift(e(:,n), ceil(rand*size(e,1)));
    end
    output.est{end+1} = eOut;
end
if input.nShuffle>1
    input.method{4} = 'Shuffled Positions';
end


%% Compute Statistics
[output.stats.errors output.stats.me output.stats.me_dist] = calc_recon_errors(output.est, output.tbins, output.pbins, input.pos);
[output.stats.mi output.stats.mi_dist] = calc_recon_mi(output.est, output.tbins, output.pbins, input.pos);

%% Plot the example
plot_decoding_example(input,output);
%%
%%
% if nShuffle>1
% 
% miBins = 0:.005:3;
% h1 = histc(output.stats.mi(2:nShuffle+1),miBins);
% h1 = smoothn(h1,20);
% h1 = h1/sum(h1);
% 
% h2 = histc(output.stats.mi(nShuffle+2:end),miBins);
% h2 = smoothn(h2,20);
% h2 = h2/sum(h2);
% 
% figure; 
% line(repmat(output.stats.mi(1),1,2), [0 .1], 'color', 'r', 'linewidth', 2);
% line(miBins, h1, 'color', 'b', 'linewidth', 2);
% line(miBins, h2, 'color', 'k', 'lineWidth', 2);
% 
% ylabel('Relative Frequency', 'fontsize', 14);
% xlabel('Mutual Information', 'fontsize', 14);
% set(gca,'FontSize',14, 'YLim', [0 .03]);
% legend(input.method, 'Location', 'NorthWest');
% 
% 
% meBins = 0:.005:2;
% h1 = histc(output.stats.me(2:nShuffle+1), meBins);
% h1 = smoothn(h1,15);
% h1 = h1/sum(h1);
% 
% h2 = histc(output.stats.me(nShuffle+2:end), meBins);
% h2 = smoothn(h2,15);
% h2 = h2/sum(h2);
% 
% 
% %h1 = smoothn(h1,3);
% %h2 = smoothn(h2,3);
% %h3 = smoothn(h3,3);
% 
% figure; 
% line(repmat(output.stats.me(1),1,2), [0 .1], 'color', 'r', 'linewidth', 2);
% line(meBins, h1, 'color', 'b', 'linewidth', 2);
% line(meBins, h2, 'color', 'k', 'lineWidth', 2);
% ylabel('Relative Frequency', 'fontsize', 14);
% xlabel('Median Error', 'fontsize', 14);
% set(gca,'FontSize',14, 'YLim', [0 .03]);
% legend(input.method, 'location', 'NorthEast');
% 
% end

%% save the data
 if saveData == 1
    [directory date] = fileparts(input.exp.edir);
    [directory animal] = fileparts(directory);

    
    filename = ['/data/amplitude_decoding/Amp.Decoding.Example.With.Shuffles.New2.', animal,'.',date, '.mat'];

    save(filename, 'input', 'output');
 end

