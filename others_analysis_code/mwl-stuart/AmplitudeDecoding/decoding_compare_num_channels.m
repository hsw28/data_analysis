
%% Load DATA
clear output
clear ep_in;
ep_in  = 'amprun';
input = setup_decoding_inputs(exp_in, ep_in);

[directory date] = fileparts(input.exp.edir);
[directory animal] = fileparts(directory);

saveData = 1;


%% Script Specific Setup

input.data{1} = select_amps_by_feature(input.raw_amps,'feature', 'col', 'col_num', 8, 'range', [12 40]);
input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', [125 Inf]);
input = rmfield(input,'raw_amps');

input.param.cols = [...
    1 1 1 1; ...
    1 1 1 0; ...
    1 1 0 0; ...
    1 0 0 0];

resp_col = [ 1 1 1 1; 0 0 0 0];

input.param.cols = logical(input.param.cols);

input.method = {'4 Chan Amp', '4 Chan MUA',...
                '3 Chan Amp', '3 Chan MUA',...
                '2 Chan Amp', '2 Chan MUA',...
                '1 Chan Amp', '1 Chan MUA'};%,'XY-Clust'};


%% COMPUTE THE ESTIAMTE
clear output;
count = 1;
for i=1:size(input.param.cols,1)
    for k = 1:2
        disp(' - - - ');
        dataIn = input.data{1};
        for j = 1:numel(dataIn)
           tmp =  dataIn{j}(:,1:4);
           tmp(:,~input.param.cols(i,:)) = 0;
           dataIn{j}(:,1:4) = tmp;
        end
        respCol = input.param.cols(i,:) & resp_col(k,:);
        disp(['Using Cols', mat2str(respCol)]);
        if (i~=5)
            dataIn = select_amps_by_feature(dataIn, 'feature',  'amplitude', 'range', [125 Inf]);
        end
        input.dataCh{i} = dataIn;
        tic;
        disp(['Decoding: ', input.method{count}]);
        [output.est{count} output.tbins output.pbins output.edges] =...
            decode_amplitudes_par(dataIn, input.pos.lp', input.t_range, input.d_range,...
            'resp_col', respCol);    
        output.elapsed_time(count) = toc;
        toc;
        count = count+1;
    end
end
%% Compute the statistics

[output.stats.errors output.stats.me output.stats.me_dist] = calc_recon_errors(output.est, output.tbins, output.pbins, input.pos);
[output.stats.mi output.stats.mi_var] = calc_recon_mi(output.est, output.tbins, output.pbins, input.pos);



%% save the data

if saveData ==1
    
    curDir = pwd;
    
    cd ('/data/amplitude_decoding');
    filename = ['Amp.Decoding.Channel.Number.Multi.MUA', animal,'.',date, '.mat'];
    save(filename, 'input', 'output');
    disp([filename, ' saved!']);
    cd(curDir);
    clear curDir;
end
