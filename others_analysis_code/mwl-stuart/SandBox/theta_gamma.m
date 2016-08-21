%data.saline = s10d06.saline;
%data.midazolam = s10d07.midazolam;
%data = nephron;
data = citrus;
epochs = {'saline', 'midazolam'};


phase_bins = -pi:pi/16:pi;
gamma_bins = 0:50;

eeg_ch = 8;
name = ['citrus6,7 eegch:' num2str(eeg_ch)];
%%
for i=1:2
    ep = data.(epochs{i});
   
    raw = ep.eeg(eeg_ch).data;
    ts = ep.eeg_ts;
    fs = ep.eeg(eeg_ch).fs;

    pos = ep.position.lin_pos;
    vel = ep.position.lin_vel;
    pts = ep.position.timestamp;

    vel_i = interp1(pts, vel, ts, 'nearest');
    moving = abs(vel_i)>=.1;
    

    gf = getfilter(fs,'gamma', 'win');
    tf = getfilter(fs,'theta', 'win');

    gamma = filtfilt(gf,1,raw);
    theta = filtfilt(tf,1,raw);

    genv = abs(hilbert(gamma));
    tenv = abs(hilbert(theta));

    gphase = angle(hilbert(gamma));
    tphase = angle(hilbert(theta));

%%
    t_out{i} = tphase(:);
    g_out{i} = genv(:);
    m_out{i} = moving(:);

end
%%
% 
% figure('Name', name); 
% subplot(211);
% plot(tphase+pi, genv, '.');
% subplot(212);
% plot(tphase(moving)+pi, genv(moving), '.');
% 
% %%
% t_ind = tphase<0;
% tphase2 = tphase;
% tphase2(t_ind) = tphase2(t_ind)+2*pi;
% 
% 
% figure('Name', name); 
% subplot(211);
% plot(tphase2+pi, genv, '.');
% subplot(212);
% plot(tphase2(moving)+pi, genv(moving), '.');

%% Regression Images (not super useful)

figure('Name', name);
for i=1:2
    subplot(3,2,1+(i-1));
    img = scatter_image(t_out{i}, g_out{i}, phase_bins, gamma_bins);
    imagesc(phase_bins, gamma_bins, img);
    set(gca, 'YDir', 'normal');
    set(gca,'YLim', [min(gamma_bins) max(gamma_bins)]);
    set(gca, 'XLim', [-pi, pi]);
    set(gca,'XTick',-pi:pi/2:pi)
    set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'})
    title([epochs{i}, ' all data']);

    subplot(3,2,3+(i-1));
    img = scatter_image(t_out{i}(m_out{i}), g_out{i}(m_out{i}), phase_bins, gamma_bins);
    imagesc(phase_bins, gamma_bins, img);
    set(gca, 'YDir', 'normal');
    set(gca,'YLim', [min(gamma_bins) max(gamma_bins)]);
    set(gca, 'XLim', [-pi, pi]);
    set(gca,'XTick',-pi:pi/2:pi)
    set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'})
    title([epochs{i}, ' running']);

    subplot(3,2,5+(i-1));
    img = scatter_image(t_out{i}(~m_out{i}), g_out{i}(~m_out{i}), phase_bins, gamma_bins);
    imagesc(phase_bins, gamma_bins, img);
    set(gca, 'YDir', 'normal');
    set(gca,'YLim', [min(gamma_bins) max(gamma_bins)]);
    set(gca, 'XLim', [-pi, pi]);
    set(gca,'XTick',-pi:pi/2:pi)
    set(gca,'XTickLabel',{'-pi','-pi/2','0','pi/2','pi'})
    title([epochs{i}, ' stopped']);

  
end
%% Do Regression
%http://www.mathworks.com/matlabcentral/newsreader/view_original/340804
%    x = [cos(t(ind)), sin(t(ind)), ones(size(t(ind)))]\s(ind);
%    regress(s, [cos(t), sin(t), ones(size(t)) ] );
disp('doing the regression');
in = -pi:pi/36:pi;
id = {'con-all', 'con-run', 'con-stop'; 'mid-all', 'mid-run', 'mid-stop'};

for i=1:2
    
    t = t_out{i};
    s = g_out{i};
    
    n_samp = 100000;
    ai = randsample(numel(t), n_samp);
    mi = randsample(find(m_out{i}), n_samp);
    si = randsample(find(~m_out{i}),n_samp);
    
    [b{i,1} bint{i,1} r{i,1} rint{i,1} stats{i,1}] =...
        regress(s(ai), [cos(t(ai)), sin(t(ai)), ones(size(t(ai))) ] );
    
    [b{i,2} bint{i,2} r{i,2} rint{i,2} stats{i,2}] =...
        regress(s(mi), [cos(t(mi)), sin(t(mi)), ones(size(t(mi))) ] );
    
    [b{i,3} bint{i,3} r{i,3} rint{i,3} stats{i,3}] =...
        regress(s(si), [cos(t(si)), sin(t(si)), ones(size(t(si))) ] );
    
    for j=1:3
        out{i,j} = b{j}(1) * cos(in) + b{j}(2)*sin(in) + b{j}(3);
    end
        
end
disp('done');
%% Plot Regression

figure('Name', name);
gca; 
hold on;
style = {'--', '-'};
col = ['r', 'k']
for j=1:3
    subplot(3,1,j);
    hold on;
    for i=1:2
       coef = b{i,j};
       err = bint{i,j};
       
       out = coef(1) * cos(in) + coef(2) * sin(in) + coef(3);
       outu = err(1,1) * cos(in) + err(2,1) * sin(in) + err(3,1);
       outd = err(1,2) * cos(in) + err(2,2) * sin(in) + err(3,2);
       
       plot(in, out, col(i), in, outu, col(i), in , outd, col(i));
       
       
        
        
    end
end


legend('Saline', 'midazolam', 'location', 'southwest');

%% Plot Normalized Regression

figure('Name', name);
gca; 
hold on;

sp = s2{1};
ind = randsample(numel(sp), 25000);
sp = sp-min(sp);
sp = sp/max(sp);
plot(t_out{1}(ind), sp(ind), '.k');


sp = s2{2};
ind = randsample(numel(sp), 25000);
sp = sp-min(sp);
sp = sp/max(sp);
plot(t_out{2}(ind), sp(ind), '.r');
hold off;
legend('Saline', 'midazolam', 'location', 'southwest');



%% Messing around with regression  to get some stats!

[b bint r rint stats ] = regress(s,[cos(t), sin(t), ones(size(t))]);

in = -pi:pi/36:pi;
out = b(1) * cos(in) + b(2)*sin(in) + b(3);

%plot(in,out, 'k', 'lineWidth', 6); hold on;
%plot(t, s2{2}, 'r.', 'MarkerSize', 1);

%% Using the cirstats toolbox

[rho pval ] = circ_corrcl(t_out{2}, g_out{2}); 





