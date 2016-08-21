
%% Load DATA

input = setup_decoding_inputs(exp_in, ep_in);

[directory date] = fileparts(input.exp.edir);
[directory animal] = fileparts(directory);

saveData = 1;

%% Scripts Specific setup
clear data;
% clustered spike organized by tetrode
data.cl = load_clustered_amplitudes(input.exp,input.ep);
data.cl = select_amps_by_feature(data.cl,'feature', 'col', 'col_num', 8, 'range', [12 40]);
data.cl = select_amps_by_feature(data.cl, 'feature', 'amplitude', 'range', [125 Inf]);

% clustered spike organized by cluster
data.cl_c = convert_cl_to_kde_format(input.exp,input.ep);
data.cl_c = select_amps_by_feature(data.cl_c,'feature', 'col', 'col_num', 8, 'range', [12 40]);
data.cl_c = select_amps_by_feature(data.cl_c, 'feature', 'amplitude', 'range', [125 Inf]);

data.cl_anti = load_clustered_amplitudes(input.exp,input.ep,'anti',1);


input.data{1} = select_amps_by_feature(input.raw_amps,'feature', 'col', 'col_num', 8, 'range', [12 40]);
input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', [125 Inf]);
input.method{1} = 'All Spikes';
input.resp_col{1} = [1 2 3 4];

input.data{2} = data.cl;
input.method{2} = 'Clustered Spikes';
input.resp_col{2} = [1 2 3 4];

input.data{3} = select_amps_by_feature(data.cl_anti, 'feature', 'col', 'col_num', 8, 'range', [8 40]);
input.data{3} = select_amps_by_feature(input.data{3}, 'feature', 'amplitude', 'range', [150 Inf]);
input.method{3} = 'Anti-Clustered Spikes';
input.resp_col{3} = [1 2 3 4];

input.data{4} = data.cl_c;
input.method{4} = 'Cell Identity + Amplitude';
input.resp_col{4} = [1 2 3 4];

input.data{5} = data.cl_c;
input.method{5} = 'Cell Identity';
input.resp_col{5} = [];

input.data{6} = input.data{1};
input.method{6} = 'No Amplitude';
input.resp_col{6} = [];


input = rmfield(input, 'raw_amps');

clear data;




%% COMPUTE THE ESTIAMTE
clear output;
for i=1:numel(input.data)
    tic;
    disp(['Decoding: ', input.method{i}]);
    [output.est{i} output.tbins output.pbins output.edges] =...
        decode_amplitudes_par(input.data{i}, input.pos.lp', input.t_range, input.d_range,...
        'resp_col', input.resp_col{i});    
    output.elapsed_time(i) = toc;
    toc;
end


%% Compute Statistics
nboot = 0;
[output.stats.errors output.stats.me output.stats.me_dist] = calc_recon_errors(output.est, output.tbins, output.pbins, input.pos, 'n_boot', nboot);
[output.stats.mi output.stats.mi_var] = calc_recon_mi(output.est, output.tbins, output.pbins, input.pos, 'n_boot',nboot);

%% Compare the aveage CDF by number of electrodes used
% 
% plot_amp_decoding_estimate_errors(input, output);
% set(gcf,'Name', [animal, ':', date, ' Amplitude vs Cell Identify']);
% for i=1:numel(fl)
%     fl{i}(1) = 0;
%     fl{i}(end) = 1;
% end
%%
% 
% bs_me_m = cellfun(@mean, output.stats.me_dist);
% bs_me_s = cellfun(@std, output.stats.me_dist) ./ sqrt(cellfun(@numel, output.stats.me_dist));
% 
% 
% figure('name', input.exp.edir);
% 
% title('Mutual Information by Kernel Size');
% barerrorbar(1:numel(input.method), output.stats.mi, 2*sqrt(output.stats.mi_var),...
%     {'facecolor', 'red'}, {'color', 'k', 'LineWidth', 2, 'linestyle', 'none'});
% set(gca,'XTick', 1:numel(input.method), 'XTickLabel', input.method, 'fontsize',16, 'YLim', [0 3.25], 'linewidth',2);
% ylabel('Mutual Information (bits)','fontsize', 16);
% xlabel('Kernel Size uV','fontsize', 16)


%% save the data

if saveData ==1
    
    curDir = pwd;
    
    cd ('/data/amplitude_decoding');
    filename = ['Amp.Decoding.Amplitude.vs.Clusters.ClFiltered.', animal,'.',date, '.mat'];
    save(filename, 'input', 'output');
    
    cd(curDir);
    clear curDir;
end
% for j=1:numel(input)
%     [est{3+j}] = decode_amplitudes(input{j}, pos', t_range, d_range, 'wb', 1, 'ignore_amplitudes', ig_amp(j));
% end
% 
% for i=3:4
%     tic;
%     [est{i} tbins pbins] = decode_clusters(input{i}, pos', t_range, d_range, 'wb', 1);
%     toc;
% end
%est{end+1} = decode_clusters(amps{end},pos',t_range, d_range);
