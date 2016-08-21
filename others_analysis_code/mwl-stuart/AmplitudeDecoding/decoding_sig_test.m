
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
 input = setup_decoding_inputs(exp_in, ep_in);
 saveData = 1;
 nShuffle = 250;
%% Script Specific setup

clear amps_f cl_f cl_anti_f resp_col; 

input.data{1} = select_amps_by_feature(input.raw_amps,'feature', 'col', 'col_num', 8, 'range', input.param.spike_width);
input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', input.param.amp_thold);
input.method{1} = 'Decoded Position';


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
for i=1:nShuffle+1
    if i==1
        d = input.data{1};
    else
        input.method{2} = 'Spike Amplitude Shuffle';
        d = shuffle_amps(input.data{1}, input.t_range);
    end
 
    tic;
    disp(['Decoding: ', num2str(i)]);
    [output.est{i} output.tbins output.pbins output.edges] =...
        decode_amplitudes_par(d, input.pos.lp', input.t_range, input.d_range, 'amp_kw',[30 30 30 30]);
    output.elapsed_time(i) = toc;
    toc;
end
input.nShuffle = nShuffle;



%% Time Bin in time
if nShuffle>1
    input.method{3} = 'Time Bin Shuffle';
    [~,~,~,~,~,~,isMoving] = calc_recon_errors(output.est(1), output.tbins, output.pbins, input.pos);
    
    estTemp = output.est{1}(:, isMoving);
    szTemp = size(estTemp,2);
    for j = 1:nShuffle
        
        idx = randsample(szTemp, szTemp);
        estTemp = estTemp(:,idx);
        
        output.est{end+1} = output.est{1};
        output.est{end}(:,isMoving) = estTemp;
    end


end
%%

if input.nShuffle>1
    input.method{4} = 'Position Shuffle';
    
    e = output.est{1};
    
    for j=1:input.nShuffle
        eOut = e;
        for n=1:size(e,2)
           eOut(:,n) = circshift(e(:,n), ceil(rand*size(e,1)));
        end
        output.est{end+1} = eOut;
    end

end


%% Compute Statistics
[output.stats.errors output.stats.me output.stats.me_dist] = calc_recon_errors(output.est, output.tbins, output.pbins, input.pos);
[output.stats.mi output.stats.mi_dist] = calc_recon_mi(output.est, output.tbins, output.pbins, input.pos);

%% save the data
 if saveData == 1
    [directory date] = fileparts(input.exp.edir);
    [directory animal] = fileparts(directory);

    filename = ['/data/amplitude_decoding/Amp.Decoding.Sig.Test.', animal,'.',date, '.mat'];

    save(filename, 'input', 'output');
 end

