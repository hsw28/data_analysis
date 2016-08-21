function [me e f x fl fu ismoving] =  plot_amp_decoding_estimate_errors_old(est, pos, varargin)
args.decode_range = [nan nan];
args.n_spike = {};
args.dt = .25;
args.dp = .1;
args.legend = {};
args.vel_thold = .15;
args.plot_ks = 0;
args.smooth = 0;
args.area = 0;
args.line_width =3;
args.font_size = 16;
args.shuffle = 0;
args.num_shuf = 250;
args.plot_shuffle_cdf = 0;

args = parseArgsLite(varargin,args);

tbins = args.decode_range(1)+args.dt:args.dt:args.decode_range(2);

size(tbins);
warning off;
interp_pos = interp1(pos.ts, pos.lp, tbins);
warning on;
sm_est = {};
if ~iscell(est)
    est = {est};
end

for i=1:numel(est); 
    sm_est{i} = est{i};
    if args.smooth
        disp('Smoothing');
        sm_est{i} = smoothn(est{i},3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
    end
    [m max_ind] = max(sm_est{i}); 
    pbins = min(pos.lp):args.dp:max(pos.lp);
    
    est_pos{i} = pbins(max_ind);

    ismoving = interp1(pos.ts, abs(pos.lv)>=args.vel_thold, tbins, 'nearest');
    ismoving(isnan(ismoving))=0;
    ismoving = logical(ismoving);
    
    
    err = (est_pos{i}-interp_pos);
    e{i} = err;
    %ecdf(a,abs(e{i}(ismoving)), 'bounds','on');
    [f{i} x{i} fl{i} fu{i}] = ecdf(abs(e{i}(ismoving)));
    
    if args.shuffle==1
        for shuf_n = 1:args.num_shuf
            shuff_ind = randsample(numel(est_pos{i}),numel(est_pos{i}));
            est_pos_shuf{i} = est_pos{i}(shuff_ind);
            err_shuf = (est_pos_shuf{i}-interp_pos);
            [f_shuf{i}{shuf_n}, x_shuf{i}{shuf_n} ] = ecdf(abs(err_shuf(ismoving)));
            me_shuff{i}(shuf_n) = nanmedian(abs(err_shuf(ismoving)));
        end
    end
    me{i} = nanmedian(abs(e{i}(ismoving)));
    
end
for i=1:numel(fl)
    fl{i}(1) = 0;
    fu{i}(1) = 0;
    fl{i}(end) = 1;
    fu{i}(end) = 1;
end

c= 'rkbgmrkbgmrkbgm';
s = {'--', '-', '-.'};
%% 
% if ~isempty(args.n_spike);
%     
%     figure('Position',[430 250 560 850]); 
%     if numel(args.n_spike)>1
%         
%         subplot(10,1,7:8);
%         line(1:numel(args.n_spike), cell2mat(args.n_spike), 'marker', '*');
%         set(gca,'XTick', [], 'xlim', [1 numel(args.n_spike)]);
%         ylabel('Number of Spikes');
%         subplot(10,1,9:10);
%         set(gca, 'Position', [.1300 .1212 .7750 .1330]);
%     else
%         subplot(9,1,6:9);
%         set(gca, 'Position', [.1232 .1259 .7818 .2976]);
%     end
%     line(1:numel(me), cell2mat(me), 'marker', '*');
%     set(gca,'XTick', 1:numel(me), 'xlim', [1 numel(me)]);
%     xticklabel_rotate([], 90, args.legend);
%     ylabel('Median Error');
% 
% 
%     subplot(9,1,1:5);
% else
    figure('Position', [155 177 1334 875]);
% end
%%

if args.shuffle==1
   for i=1:numel(f)
       if args.plot_shuffle_cdf==1
           for shuff_n=1:args.num_shuf
                line(x_shuf{i}{shuff_n}, f_shuf{i}{shuff_n}, 'color', c(i), 'HandleVisibility', 'off');
           end
       end
       bins = 0:.025:3;
       h = histc(me_shuff{i},bins);
       h = h/sum(h) - .01;
       line(bins,h,'Color', c(i), 'linewidth', 3);
   end
end
for i=1:numel(f)   
        line(x{i},f{i}, 'color',c(i), 'LineWidth', args.line_width, 'LineStyle', s{mod(i-1,3)+1});
end
            
% 
% for i=1:numel(f)
%     p1 = [me{i}, .05];
%     p2 = [me{i}, 0];
%     arrow(p1, p2, 'length', 15, 'width',3,'facecolor', c(i), 'edgecolor', c(i));
% end

if ~isempty(args.legend)
    legend(args.legend, 'Location', 'SouthEast');
end

if args.area
   for i=1:numel(f)
         xd = [x{i}; flipud(x{i})];
         yd = [fu{i}; flipud(fl{i})];
         p = patch(xd,yd,c(i));
         set(p,'EdgeColor', c(i));
%        line(x{i},fu{i}, 'color',c(i), 'LineWidth', 2, 'LineStyle', s{1});
%        line(x{i},fl{i}, 'color',c(i), 'LineWidth', 2, 'LineStyle', s{1});
    end     
end
set(gca,'XTick', 0:.25:3.1, 'YLim', [0 1], 'FontSize', args.font_size);
grid on;
title('CDF of Decoding Errors', 'fontsize',args.font_size);
xlabel('meters', 'fontsize', args.font_size);
ylabel('% errors', 'fontsize', args.font_size);


end