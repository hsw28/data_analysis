
%%


%%
clear b_win;
for i = 1:numel(eeg)

b_win{i} = find_rip_burst(eeg(i).data, eeg(ch).fs, eeg(ch).starttime);
end
burst_win = b_win;
tx_win = params.high_threshold_crossings;
mx_win = params.low_threshold_crossings;
%rip_data = filtfilt(params.filter,1,eeg.data);
p = 0;%params.high_threshold; 
m = 0;%params.low_threshold;


%%
 
nSamp = numel(eeg(1).data);
dt = 1.000 / eeg(1).fs;
st = eeg(1).starttime;
ts = st:dt:st + (nSamp-1)*dt;
%close all;
figure('Position', [0 750 1600 350]);axes('Color', 'k');

lCA1Idx = strcmp('left', {eeg.hemisphere}) & strcmp('CA1', {eeg.area});
lCA3Idx = strcmp('left', {eeg.hemisphere}) & strcmp('CA3', {eeg.area});
rCA1Idx = strcmp('right', {eeg.hemisphere}) & strcmp('CA1', {eeg.area});

colors = repmat('b', size(eeg));
colors(lCA1Idx) = 'g';
colors(lCA3Idx) = 'y';
colors(rCA1Idx) = 'r';


d = [];

for i = 1:numel(eeg)
    d(1:1396553,i) = eeg(i).data(1:1396553);
end


lb = line_browser(d, ts,  'axes', gca, 'color',colors, 'offset', 500); 
ind = diff(tx_win,1,2)>.015;

for chan = 1:numel(eeg)
    y = mean(eeg(chan).data) + 500*(chan-1) + 250;
    dy = 500;
    for burstNum = 1:size(b_win{chan},1)
       x = b_win{chan}(burstNum,1);
       dx = diff(b_win{chan}(burstNum,:));
       my_rectangle(x, y , dx, dy-dy*.1, '--','w', 2,gca);
    end    
end

pan xon;
zoom xon;
set(gca,'Position', [0, .07, 1, .93]);

%% Plot the EEG - Old Junk!
% close all;
% f1 = figure('Position', [0 300 1600 350]);
% 
% ind = diff(mx_win,1,2)>.02;
% for i=1:length(mx_win)
%     if ind(i)
%         l = my_rectangle(mx_win(i,1), -150, diff(mx_win(i,:)), 300, '--', 'k', gca);
%         set(l, 'LineWidth', 3);
%     end
% end
% 
% l(1) = line([eeg.ts(1) eeg.ts(end)], [m m],'Parent', gca );
% l(2) = line([eeg.ts(1) eeg.ts(end)], -1*[m m],'Parent', gca );
% set(l,'LineStyle', '--', 'Color', 'k', 'linewidth', 3)
% 
% ind = diff(tx_win,1,2)>.001;
% for i=1:length(tx_win)
%     if ind(i)
%         l =my_rectangle(tx_win(i,1), -100, diff(tx_win(i,:)), 200, '--', 'g', gca);
%         set(l, 'LineWidth',3);
%     end
% end
% 
% l(1) = line([eeg.ts(1) eeg.ts(end)], [p p],'Parent', gca );
% l(2) = line([eeg.ts(1) eeg.ts(end)], -1*[p p],'Parent', gca );
% set(l,'LineStyle', '--', 'Color', 'g', 'linewidth', 3)
% 
% 
% lb = line_browser(exp.(epoch_name).eeg(1).data, exp.(epoch_name).eeg_ts, gca); 
% % the ripple windows
% 
% set(lb, 'LineWidth', 2);
% 
% rip_d = rip_data;
% 
% 
% lb4 = line_browser(abs(hilbert(rip_d)), exp.(epoch_name).eeg_ts, gca); 
% set(lb4,'LineWidth', 4, 'color', 'c');
% 
% lb3 = line_browser(rip_d, exp.(epoch_name).eeg_ts, gca); 
% set(lb3,'LineWidth', 2, 'color', 'r');
% 
% 
% for i=1:length(burst_win)
%         l =my_rectangle(burst_win(i,1), -175, diff(burst_win(i,:)), 350, '--', 'r', gca);
%         set(l, 'LineWidth',3);
% end
% 
% 
% set(gca, 'Position', [0 .07 1 .93], 'XLim', [2867.1 2868.1]);
% 
% pan xon;
% zoom xon;

