
%% Load DATA
input = setup_decoding_inputs(exp_in, ep_in);

[directory date] = fileparts(input.exp.edir);
[directory animal] = fileparts(directory);

saveData = 1;
%% Script Specific Setup

input.data{1} = select_amps_by_feature(input.raw_amps,'feature', 'col', 'col_num', 8, 'range', [12 40]);
input.data{1} = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', input.param.amp_thold);
input.param.amp_kw = [5 7.5 10 20 30 40 50 100 150 300 ];
input.param.pos_kw = [.0025 .005 .01 .025 .05 .075 .1 .125 .15 .25];
% input.param.amp_kw = [2.5 30];
% input.param.pos_kw = [.005  .1];
input = rmfield(input, 'raw_amps');



%% COMPUTE THE ESTIAMTE

nAmpK = numel(input.param.amp_kw);
nPosK = numel(input.param.pos_kw);

for a = 1:nAmpK
    for p=1:nPosK
        n = (a-1)*nAmpK + p;
        ampK = input.param.amp_kw(a);
        posK = input.param.pos_kw(p);
        
        disp(['Decoding :', num2str(n), ' of:' num2str(nAmpK*nPosK), ' AmpK:', num2str(ampK), ' PosK:', num2str(posK)]);
        tic;
        [output.est{n} output.tbins output.pbins output.edges] = ...
            decode_amplitudes_par(input.data{1}, input.pos.lp', input.t_range, input.d_range, ...
        'amp_kw', repmat(ampK,1,4), ...
        'pos_kw', posK);
        output.elapsed_time(n) = toc;  
        toc;
  
        input.method{n} = ['AmpKW:', num2str(ampK), ' PosKW:', num2str(posK)];
    end
end

%% Compute Statistics
nboot = 0;
[output.stats.errors output.stats.me output.stats.me_dist] =...
    calc_recon_errors(output.est, output.tbins, output.pbins, input.pos, 'n_boot', nboot);
[output.stats.mi output.stats.mi_var] =...
    calc_recon_mi(output.est, output.tbins, output.pbins, input.pos, 'n_boot',nboot);


%% Compare the aveage CDF by number of electrodes used
% 
% plot_amp_decoding_estimate_errors(input, output);
% set(gcf,'Name', [animal, ':', date, ' Amplitude vs Cell Identify']);
% for i=1:numel(fl)
%     fl{i}(1) = 0;
%     fl{i}(end) = 1;
% end



%% Plot the Stats


bs_me_m = cellfun(@mean, output.stats.me_dist);
bs_me_s = cellfun(@std, output.stats.me_dist) ./ sqrt(cellfun(@numel, output.stats.me_dist));

% figure;
% 
% title('Mutual Information by Kernel Size');
% barerrorbar(1:numel(input.method), output.stats.mi, 2*sqrt(output.stats.mi_var),...
%     {'facecolor', 'red'}, {'color', 'k', 'LineWidth', 2, 'linestyle', 'none'});
% set(gca,'XTick', 1:numel(input.param.amp_kw), 'XTickLabel', input.method, 'fontsize',8, 'YLim', [0 3.25], 'linewidth',2);
% 
% ylabel('Mutual Information (bits)','fontsize', 16);
% xlabel('Kernel Size uV','fontsize', 16)




%% save the data

if saveData == 1
    curDir = pwd;
    cd ('/data/amplitude_decoding');
    
    filename = ['Amp.Decoding.Amp.and.Pos.KW.', animal,'.',date, '.mat'];

    save(filename, 'input', 'output');
    
    cd(curDir)
    clear curDir
end
