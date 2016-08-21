
%% Load DATA
clearvars -except exps exp_in ep_in d
input = setup_decoding_inputs(exp_in, ep_in);

[directory date] = fileparts(input.exp.edir);
[~, animal] = fileparts(directory);

saveData = 1;
%% Script Specific Setup
input.data{1} = select_amps_by_feature(input.raw_amps, 'feature', 'col', 'col_num', 8, 'range', [12 40]);
input = rmfield(input, 'raw_amps');
input.param.amp_th = [...
      75, Inf;...
      100, Inf;...
      125, Inf;...
      150, Inf;...
      175, Inf;...
      200, Inf;...
      225, Inf;...
      250, Inf;...
      300, Inf;...
      350, Inf;...
      400, Inf;...
      450, Inf;...
      500, Inf;...
      550, Inf;...
      600, Inf;...
      650, Inf;...
      700, Inf;...
     ]; 

input.method = {};
for i=1:size(input.param.amp_th,1);
    input.method{i} = num2str(input.param.amp_th(i,1));
end


%% Compute the Estimate
output = [];
matlabpool('open', 8)
for i=1:size(input.param.amp_th,1);
    tic;
    disp(['Decoding: ', input.method{i}]);
    amps = select_amps_by_feature(input.data{1}, 'feature', 'amplitude', 'range', input.param.amp_th(i,:));
    [output.est{i} output.tbins output.pbins] = ...
        decode_amplitudes_par(amps, input.pos.lp', input.t_range, input.d_range,...
        'amp_kw', [30 30 30 30]);  
    output.elapsed_time(i) = toc;
    toc;
end
matlabpool close
%% Compute Statistics
nboot = 0;
[output.stats.errors output.stats.me output.stats.me_dist] =...
    calc_recon_errors(output.est, output.tbins, output.pbins, input.pos, 'n_boot', nboot);
[output.stats.mi output.stats.mi_var] =...
    calc_recon_mi(output.est, output.tbins, output.pbins, input.pos, 'n_boot',nboot);



%% PLOT the CDF Of the Estimate ERRORS
%[output.me output.e output.f output.x] = plot_amp_decoding_estimate_errors(output.est,input.exp.(ep).pos, 'decode_range', input.d_range, 'legend', input.method);
%set(gcf,'Name', [animal, ':', date]);
% plot_amp_decoding_estimate_errors(input, output);
% set(gcf,'Name', [animal, ':', date, ' Amplitude vs Cell Identify']);

%% Mutual Information Plot
% figure;
% title('Mutual Information by Kernel Size');
% barerrorbar(1:numel(input.method), output.stats.mi, 2*sqrt(output.stats.mi_var),...
%     {'facecolor', 'red'}, {'color', 'k', 'LineWidth', 2, 'linestyle', 'none'});
% set(gca,'XLim', [0 numel(input.method)+1],'XTick', 1:numel(input.method), 'XTickLabel', input.method, 'fontsize',16, 'YLim', [0 3.25], 'linewidth',2);
% ylabel('Mutual Information (bits)','fontsize', 16);
% xlabel('Spike Threshold uV','fontsize', 16)


%% Save the Data


filename = ['Amp.Decoding.Volt.Thold.', animal,'.',date, '.mat'];

save(filename, 'input', 'output');

clear vel pts pos vel_thold directory animal date r1 r2 et me e f x fl flu
% for i=1:numel(fl)
%     fl{i}(1) = 0;
%     fl{i}(end) = 1;
% end
%% PLOT THE ESTIMATE
% 
% pos_i = interp1(pts,pos,tbins_th);
% nEst = numel(est_th);
% dp = .1;
% est_pos = {};
% for i=1:nEst    
%     [m max_ind] = max(est_th{i}); 
%     pbins = min(pos):dp:max(pos);
%     est_pos{i} = pbins(max_ind);
% end
% 
% 
% 
% figure;
% xm = .05;
% dx = .9;
% ym = .075;
% dy = (1/nEst) - .01;%.24;
% ax = [];
% 
% for i=1:nEst
%     ax(i) = axes('Position', [xm ym+dy * (nEst-i)+.005, dx,dy-.02]);
%     
% end
% % 
% % ax(4) = axes('Position', [xm, .025+ym*0, dx, dy]);
% % ax(3) = axes('Position', [xm, .025+ym*1, dx, dy]);
% % ax(2) = axes('Position', [xm, .025+ym*2, dx, dy]);
% % ax(1) = axes('Position', [xm, .025+ym*3, dx, dy]);
% 
% ismoving = logical(abs(interp1(pts, vel, tbins_th))>=vel_thold);
% t = {'amplitude', 'clusters'};
% for i=1:nEst
%     p(:,:,1) = est_th{i};
%     p(:,:,2) = p(:,:,1);
%     p(:,:,3) = p(:,:,1);
%     p(isnan(p))=0;
%     p = 1-p;
% 
%     imagesc(tbins_th, pbins_th, p,'Parent', ax(i));
%     line(pts,pos,'color','r','linewidth',2, 'Parent', ax(i));
% end
% set(ax(1:end-1),'Xtick', []);
% set(ax,'YDir', 'Normal');
% %set(get(gcf,'Children'),'FontSize',20);
% 
% linkaxes;
% %% Compare Estimates and Plot Errors (Clustered vs Non-Clustered)
