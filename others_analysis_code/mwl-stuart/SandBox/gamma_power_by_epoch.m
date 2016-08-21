%dat.saline = s10d06.saline;
%data.midazolam = s10d07.midazolam;
data = citrus;
%data = citrus;
name = ['Citrus06/07 eegch:', num2str(eeg_ch)];
epochs = {'saline', 'midazolam'};


phase_bins = -pi:pi/16:pi;
gamma_bins = 0:50;

eeg_ch = 8;
%name = ['citrus6,7 eegch:' num2str(eeg_ch)];

%% Filter for gamma
clear t_out g_out
for i=1:2
    ep = data.(epochs{i});
   
    raw = ep.eeg(eeg_ch).data;
    ts = ep.eeg_ts;
    fs = ep.eeg(eeg_ch).fs;
   
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


%%  setup the data
clear vel vel_i m_out v_out;
for i=1:2
    disp(epochs{i})
        
    ep = data.(epochs{i});
   
    ts = ep.eeg_ts;

    pos = ep.position.lin_pos;
    vel = ep.position.lin_vel;
    pts = ep.position.timestamp;
 
    v = abs(vel);
    clear vel;
    
    %speed = [.1 .2; .2 .3; .3 .4; .4 .5; .1 2; -1 .05];
    ds = .025;
    speed = [.1:ds:.4]';
    speed = [speed, speed+.1];
    speed = [-1, .05; .1 2; speed ];
    
    for j = 1:size(speed,1)
        vel(j,:) = v>=speed(j,1) & v<speed(j,2);
        vel_i{j} = interp1(pts, vel(j,:), ts, 'nearest');
    end
    %{
    vel(1,:) =  v>=speed(1,1) & v<speed(1,2);
    vel_i{1} = interp1(pts, vel(1,:), ts, 'nearest');
    
    vel(2,:) =  v>=speed(2,1) & v<speed(2,2);
    vel_i{2} = interp1(pts, vel(2,:), ts, 'nearest');

    vel(3,:) =  v>=speed(3,1) & v<speed(3,2);
    vel_i{3} = interp1(pts, vel(3,:), ts, 'nearest');

    vel(4,:) = v>=speed(4,1) & v<speed(4,2);
    vel_i{4} = interp1(pts, vel(4,:), ts, 'nearest');

    vel(5,:) =  v>=speed(5,1) & v<speed(5,2);
    vel_i{5} = interp1(pts, vel(5,:), ts, 'nearest');

    vel(6,:) =  v>=speed(6,1) & v<speed(6,2);
    vel_i{6} = interp1(pts, vel(6,:), ts, 'nearest');
    %}
        
    m_out{i} = moving(:);
    v_out{i} = vel_i;
    
end

%%  Error Bar Plot
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

xpos = [1:size(m,2)];

errorbar(xpos' ,m(1,:)',  3*se(1,:)', 3*se(1,:)', 'k*');
hold on;
errorbar(xpos' ,m(2,:)',  3*se(2,:)', 3*se(2,:)', 'r*');
ylabel('Mean Gamma Envelope');
legend('Saline', 'Midazolam', 'location', 'northwest');

tics = [1 2 3:3:15]

labels = {'<5', '>10', '10', '20', '30', '40', '50'};
set(gca, 'xtick', tics, 'xticklabel', labels);
xlabel('Running Speed cm/sec')

%%  Area Plot

clear x;

figure('name', name);
gca;
hold on;

xpos = [1:size(m,2)];
x = [xpos];% xpos];
plot(x, m(1,:), 'k', 'linewidth', 3);
plot(x, m(1,:), 'r', 'linewidth', 3);


yu = [m(1,:)+3*se(1,:)];
yd = [m(1,:)-3*se(1,:)];%, m(1,:) - 3*se(1,:)) ];

c1 = [200 200 200]/256;
c2 = [180 180 180]/256;
p = patch([x,fliplr(x)],[yu,fliplr(yd)], 'b');
set(p, 'edgecolor', c1, 'facecolor', c1 );
plot(x, m(1,:), 'k', 'linewidth', 3);

yu = [m(2,:)+3*se(2,:)];
yd = [m(2,:)-3*se(2,:)];%, m(1,:) - 3*se(1,:)) ];
[ignore ind] = sort(x);

p = patch([x,fliplr(x)],[yu,fliplr(yd)] ,'b');
set(p,'edgecolor', c2, 'facecolor', c2 );
plot(x, m(2,:), 'r', 'linewidth', 3);

ylabel('Mean Gamma Envelope');
legend('Saline', 'Midazolam', 'location', 'northwest');


tics = [1 2 3:3:15]

labels = {'<5', '>10', '10', '20', '30', '40', '50'};
set(gca, 'xtick', tics, 'xticklabel', labels);
xlabel('Running Speed cm/sec')








































