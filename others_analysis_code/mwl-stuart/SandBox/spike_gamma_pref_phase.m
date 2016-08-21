%dat.saline = s10d06.saline;
%data.midazolam = s10d07.midazolam;
data = nephron12;
%data = citrus;
name = ['Nephron12 eegch:', num2str(eeg_ch)];
epochs = {'saline', 'midazolam'};


phase_bins = -pi:pi/8:pi;

gamma_bins = 0:50;

eeg_ch = 8;
%name = ['citrus6,7 eegch:' num2str(eeg_ch)];

%% Filter for gamma
clear  g_out t_out
for i=1:2
    ep = data.(epochs{i});
   
    raw = ep.eeg(eeg_ch).data;
    ts = ep.eeg_ts;
    fs = ep.eeg(eeg_ch).fs;
   
    gf = getfilter(fs,'gamma', 'win');
    tf = getfilter(fs,'theta', 'win');

    gamma = filtfilt(gf,1,raw);
    theta = filtfilt(tf,1,raw);

    %genv = abs(hilbert(gamma));
    %tenv = abs(hilbert(theta));

    gphase = angle(hilbert(gamma));
    tphase = angle(hilbert(theta));


    g_out{i} = gphase(:);
    t_out{i} = tphase(:);
end


%%  setup the data
clear vel vel_i m_out v_out binned b_out phases gb_out tb_out
for i=1:2
    disp(epochs{i})
        
    ep = data.(epochs{i});
   
    ts = ep.eeg_ts;

    pos = ep.position.lin_pos;
    vel = ep.position.lin_vel;
    pts = ep.position.timestamp;
 
    v = abs(vel);

    
    cells = ep.clusters;
    for c = 1:numel(cells)
        warning off;
        spike_vel = interp1(pts, vel, cells(c).time, 'nearest');
        warning on;
        spike_vel(isnan(spike_vel)) = 0;
        ind = spike_vel>.1;
        if(sum(ind)>50)
            times = cells(c).time(ind);
            
            phases = interp1(ts, g_out{i}, times, 'nearest');
            disp([num2str(c), ' ', num2str(sum(isnan(phases)))]);
            
            phases = phase(~isnan(phase));
            g_phases{c} = phases;
            
            h = histc(g_phases{c}, phase_bins);
            g_binned(c,:) = h/sum(h);

            
            phases = interp1(ts, t_out{i}, times, 'nearest');
            phases = phase(~isnan(phase));
            t_phases{c} = phases;
        
            h = histc(t_phases{c}, phase_bins);
            t_binned(c,:) = h/sum(h);
        end
    end
    gb_out{i} = g_binned;
    tb_out{i} = t_binned;
    
    
end
%%
% %%  Error Bar Plot
% clear m se;
% for e = 1:numel(g_out)
%     for i=1:length(vel_i)
%         ind = v_out{e}{i};
%         ind(isnan(ind))=0;
%         ind = find(ind);
%         
%         n_samp = 5000;
%         if numel(ind)>n_samp
%             ind = randsample(numel(ind), n_samp);
%         end
%         
%         
%         m(e,i) = mean(g_out{e}(ind));
%         s(e,i) = std(g_out{e}(ind));
%         se(e,i) = s(e,i)./sqrt(numel(ind));
%     end
% end
% 
% figure('name', name); 
% 
% xpos = [1:size(m,2)];
% 
% errorbar(xpos' ,m(1,:)',  3*se(1,:)', 3*se(1,:)', 'k*');
% hold on;
% errorbar(xpos' ,m(2,:)',  3*se(2,:)', 3*se(2,:)', 'r*');
% ylabel('Mean Gamma Envelope');
% legend('Saline', 'Midazolam', 'location', 'northwest');
% 
% tics = [1 2 3:3:15]
% 
% labels = {'<5', '>10', '10', '20', '30', '40', '50'};
% set(gca, 'xtick', tics, 'xticklabel', labels);
% xlabel('Running Speed cm/sec')
% 
% %%  Area Plot
% 
% clear x;
% 
% figure('name', name);
% gca;
% hold on;
% 
% xpos = [1:size(m,2)];
% x = [xpos];% xpos];
% plot(x, m(1,:), 'k', 'linewidth', 3);
% plot(x, m(1,:), 'r', 'linewidth', 3);
% 
% 
% yu = [m(1,:)+3*se(1,:)];
% yd = [m(1,:)-3*se(1,:)];%, m(1,:) - 3*se(1,:)) ];
% 
% c1 = [200 200 200]/256;
% c2 = [180 180 180]/256;
% p = patch([x,fliplr(x)],[yu,fliplr(yd)], 'b');
% set(p, 'edgecolor', c1, 'facecolor', c1 );
% plot(x, m(1,:), 'k', 'linewidth', 3);
% 
% yu = [m(2,:)+3*se(2,:)];
% yd = [m(2,:)-3*se(2,:)];%, m(1,:) - 3*se(1,:)) ];
% [ignore ind] = sort(x);
% 
% p = patch([x,fliplr(x)],[yu,fliplr(yd)] ,'b');
% set(p,'edgecolor', c2, 'facecolor', c2 );
% plot(x, m(2,:), 'r', 'linewidth', 3);
% 
% ylabel('Mean Gamma Envelope');
% legend('Saline', 'Midazolam', 'location', 'northwest');
% 
% 
% tics = [1 2 3:3:15]
% 
% labels = {'<5', '>10', '10', '20', '30', '40', '50'};
% set(gca, 'xtick', tics, 'xticklabel', labels);
% xlabel('Running Speed cm/sec')
% 







































