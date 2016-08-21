%dat.saline = s10d06.saline;
%data.midazolam = s10d07.midazolam;
%data = nephron;
data = citrus;
name = ['Citrus06 eegch:', num2str(eeg_ch)];
epochs = {'saline', 'midazolam'};


phase_bins = -pi:pi/16:pi;
gamma_bins = 0:50;

eeg_ch = 8;
%name = ['citrus6,7 eegch:' num2str(eeg_ch)];
%%  setup the data
clear vel vel_i  m_out v_out;
for i=1:2
    ep = data.(epochs{i});
   
    raw = ep.eeg(eeg_ch).data;
    ts = ep.eeg_ts;
    fs = ep.eeg(eeg_ch).fs;

    pos = ep.position.lin_pos;
    vel = ep.position.lin_vel;
    pts = ep.position.timestamp;
 
    v = abs(vel);
    clear vel;
    speeds = .1:.025:.5;
    ds = .1;
    
%     vector = [speeds', speeds'+ds];
%     
%     vel(1,:) = v<=.05;
%     vel_i{1} = interp1(pts, vel(1,:), ts, 'nearest');
%     
%     vel(2,:) = v>=.1;
%     vel_i{2} = interp1(pts, vel(2,:), ts, 'nearest');
%     
%     for j=3:size(vector,1)+2
%         disp([vector(j-2,1) vector(j-2,2)])
%         vel(j,:) = v>=vector(j-2,1) & v<vector(j-2,2);
%         vel_i{j} = interp1(pts, vel(j,:), ts, 'nearest');
%     end
    
    
    vel(1,:) = v<=.20 & v>.10;
    vel_i{1} = interp1(pts, vel(1,:), ts, 'nearest');
    
    vel(2,:) = v<=.30 & v>.20;
    vel_i{2} = interp1(pts, vel(2,:), ts, 'nearest');
    
    vel(3,:) = v<=.40 & v>.30;
    vel_i{3} = interp1(pts, vel(3,:), ts, 'nearest');
    
    vel(4,:) = v<=.50 & v>.40;
    vel_i{4} = interp1(pts, vel(4,:), ts, 'nearest');
    
    vel(5,:) = v>=.1;
    vel_i{5} = interp1(pts, vel(5,:), ts, 'nearest');
    
    vel(6,:) = v<=.05;
    vel_i{6} = interp1(pts, vel(6,:), ts, 'nearest');
    m_out{i} = moving(:);
    v_out{i} = vel_i;
end
%%
clear t_out g_out;
for i=1:2
    
    ep = data.(epochs{i});
    gf = getfilter(fs,'gamma', 'win');
   % tf = getfilter(fs,'theta', 'win');

    gamma = filtfilt(gf,1,raw);
    %theta = filtfilt(tf,1,raw);

    genv = abs(hilbert(gamma));
    %tenv = abs(hilbert(theta));

    %gphase = angle(hilbert(gamma));
    %tphase = angle(hilbert(theta));


    t_out{i} = tphase(:);
    g_out{i} = genv(:);
   
    
end


%%
clear m se;
for e = 1:numel(g_out)
    for i=1:length(vel_i)
        ind = v_out{e}{i};
        ind(isnan(ind))=0;
        ind = find(ind);
        
        n_samp = 5000;
        if numel(ind)>n_samp
            ind = randsample(numel(ind), n_samp);
        end
        
        
        m(e,i) = mean(g_out{e}(ind));
        s(e,i) = std(g_out{e}(ind));
        se(e,i) = s(e,i)./sqrt(numel(ind));
    end
end

figure('name', name); 

xpos =  [1:size(m,2)];

errorbar(xpos' ,m(1,:)',  3*se(1,:)', 3*se(1,:)', 'k*');
hold on;
errorbar(xpos' ,m(2,:)',  3*se(2,:)', 3*se(2,:)', 'r*');
ylabel('Mean Gamma Envelope');
legend('Saline', 'Midazolam');
%set(gca, 'XTick', -1:.1:.4);
%set(gca, 'XTickLabel', {'.2<V<.3' , '.3<V<.4' , '.4<V<.5','All Run', 'Stopped', '.1<V<.2'});
%%


figure;
gca;
hold on;

x = [xpos];% xpos];
yu = [m(1,:)+3*se(1,:)];
yd = [m(1,:)-3*se(1,:)];%, m(1,:) - 3*se(1,:)) ];
[ignore ind] = sort(x);

area([x(ind),x(fliplr(ind))],[yu(ind),yd(fliplr(ind));] , 'edgecolor', 'k', 'facecolor', 'k' );
plot(x(ind), m(1,ind), 'r', 'linewidth', 3);

yu = [m(2,:)+3*se(2,:)];
yd = [m(2,:)-3*se(2,:)];%, m(1,:) - 3*se(1,:)) ];
[ignore ind] = sort(x);

area([x(ind),x(fliplr(ind))],[yu(ind),yd(fliplr(ind));] , 'edgecolor', 'r', 'facecolor', 'r' );
plot(x(ind), m(2,ind), 'k', 'linewidth', 3);


ylabel('Mean Gamma Envelope');
legend('Saline', 'Midazolam');
set(gca, 'XTick', -1:.1:.4);
set(gca, 'XTickLabel', {'.2<V<.3' , '.3<V<.4' , '.4<V<.5','All Run', 'Stopped', '.1<V<.2'});












































