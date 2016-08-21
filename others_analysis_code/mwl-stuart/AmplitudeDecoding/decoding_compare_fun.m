exp = exp15;
%%
amps = load_tetrode_amps(exp,'run');
amps = select_amps_by_feature(amps, 'feature', 'col', 'col', 8, 'range', [12 40]);
%%
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
%a_bkp = load_tetrode_amps(exp,ep, 'threshold', 80);%
%cl_bkp = convert_cl_to_kde_format(exp15,'run_clustxy');

vel_thold = .1;


%% Decode using both Amplitudes and Clustered Data
ts = exp.(ep).et(1);
te = exp.(ep).et(2);

dt = .25;

st = ts+2*dt;
%te = ;

ct = st;
est_count = 0;
est = [];
total_dt = te-ts;
accum_dt = 0;
wb = my_waitbar(0);
    
disp('Starting the Decoding');
disp_now();
while ct<te
    t_range = [ts ct-dt];
    d_range = [ct ct+dt];
    est_count = est_count+1;
    warning off;
    e = decode_amplitudes(amps, pos', t_range, d_range, 'dt', dt);
    warning on;
    est(:,est_count) = e;
    ct = ct+dt;
    accum_dt = accum_dt + dt;
    wb = my_waitbar(accum_dt/total_dt, wb);
end
disp_now();
disp('Finished Decoding');

close wb;
    

%%
clear est tbins pbins p;

for i=1:numel(amps)
    tic;
    [est{i} tbins{i} pbins{i} ]= decode_amplitudes(amps{i}, pos', t_range, d_range);
    toc;
end
%est{end+1} = decode_clusters(amps{end},pos',t_range, d_range);

%% Compare the aveage CDF by number of electrodes used
% [me e f x fl fu im] = plot_amp_decoding_estimate_errors(est,exp.(ep).pos, 'decode_range', d_range, 'legend', method, 'smooth', 0, 'area',0);
% 
% val.edir =exp.edir;
% val.est = est;
% val.tbins = tbins;
% val.pbins = pbins;
% val.me = me;
% val.e = e;
% val.im = im;
% val.f = f; 
% val.x = x;
% % 
% for i=1:numel(fl)
%     fl{i}(1) = 0;
%     fl{i}(end) = 1;
% end
% %%
% meth = fliplr(unique(methods));
% meth_ave = {};
% x_ave = {};
% figure;
% axes(); 
% hold on;
% c = 'rkbgc';
% ne = cellfun(@numel,x);
% mne = ceil(mean(ne));
% for i=1:numel(x)
%     while ne(i)<=mne
%         [ne(i) ceil(mean(ne))];
%         
%         x{i}(end+1) = x{i}(end);
%         f{i}(end+1) = f{i}(end);
%         ne(i) = ne(i)+1;
%     end
% end
% 
% for m = 1:numel(meth)
%     ind = strcmp(methods, meth(m));
%     d = x(ind);
%     x_ave{m} = mean( cell2mat( x(ind) ),2 );
%     meth_ave{m} = meth{m};
%     me_ave{m} = mean(cell2mat(me(ind)));
%     plot(x_ave{m}, f{m}, c(m), 'linewidth',2);
%     
% end
% hold off;
% legend(meth_ave, 'Location', 'SouthEast');
% set(gca,'XTick', 0:.25:3.1);
% grid on;
% title('CDF of Decoding Errors');
% xlabel('meters');
% ylabel('% errors');
% for i=1:numel(meth)
%     p1 = [me_ave{i}, .05];
%     p2 = [me_ave{i}, 0];
%     arrow(p1, p2, 'length', 3, 'facecolor', c(i), 'edgecolor', c(i));
% end
% 
% %% Plot the 4 estimates with eachother
% 
% figure;
% xm = .5;
% dx = .45;
% ym = .5;
% dy = .45;
% 
% ax(1) = axes('Position', [.025+xm*0, .025+ym*1, dx, dy]);
% ax(2) = axes('Position', [.025+xm*1, .025+ym*1, dx, dy]);
% ax(3) = axes('Position', [.025+xm*0, .025+ym*0, dx, dy]);
% ax(4) = axes('Position', [.025+xm*1, .025+ym*0, dx, dy]);
% 
% e = est{1};
% i = ~logical(nansum(e));
% e(:,i) = 1/size(e,1);
% ec(:,:,1) = e;
% ec(:,:,2) = e;
% ec(:,:,3) = e;
% ec = 1-ec;
% imagesc(tbins,pbins,ec,'Parent',ax(1));
% title(ax(1), '4 Channels');
% 
% e = est{2};
% i = ~logical(nansum(e));
% e(:,i) = 1/size(e,1);
% ec(:,:,1) = e;
% ec(:,:,2) = e;
% ec(:,:,3) = e;
% ec = 1-ec;
% imagesc(tbins,pbins,ec,'Parent',ax(2));
% title(ax(2), '3 Channels');
% 
% e = est{7};
% i = ~logical(nansum(e));
% e(:,i) = 1/size(e,1);
% ec(:,:,1) = e;
% ec(:,:,2) = e;
% ec(:,:,3) = e;
% ec = 1-ec;
% imagesc(tbins,pbins,ec,'Parent',ax(3));
% title(ax(3), '2 Channels');
% 
% e = est{14};
% i = ~logical(nansum(e));
% e(:,i) = 1/size(e,1);
% ec(:,:,1) = e;
% ec(:,:,2) = e;
% ec(:,:,3) = e;
% ec = 1-ec;
% imagesc(tbins,pbins,ec,'Parent',ax(4));
% title(ax(4), '1 Channel');
% 
% linkaxes(ax,'x');
