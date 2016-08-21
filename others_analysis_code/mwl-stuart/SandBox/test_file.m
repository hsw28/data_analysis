
%%
eeg = gh.control.eeg(1);
eeg.ts = gh.control.eeg_ts;


[burst_win params] = find_rip_burst(eeg.data, eeg.ts, eeg.fs);
tx_win = params.crossings_high;
mx_win = params.crossings_low;
rip_data = filtfilt(params.filter,1,eeg.data);
p = params.high_threshold; 
m = params.low_threshold;


%%


close all;
figure('Position', [0 750 1600 350]);
lb = line_browser(gh.control.eeg(1).data, gh.control.eeg_ts, gca); 
lb2 =line_browser(ones(size(win2(:,1))),win2(:,1), gca);
set(lb2,'LineStyle', 'none', 'Marker', '.', 'Color', 'r', 'MarkerSize', 5);
ind = diff(tx_win,1,2)>.015;
for i=1:length(tx_win)
    if ind(i)
        my_rectangle(tx_win(i,1), -150, diff(tx_win(i,:)), 300, '-', 'g', gca);
    end
end
ind = diff(mx_win,1,2)>.025;
for i=1:length(mx_win)
    if ind(i)
        my_rectangle(mx_win(i,1), -200, diff(mx_win(i,:)), 400, '-', 'k', gca);
    end
end
pan xon;
zoom xon;
set(gca,'Position', [0, .07, 1, .93]);

%% Plot the EEG
close all;
f1 = figure('Position', [0 300 1600 350]);

ind = diff(mx_win,1,2)>.02;
for i=1:length(mx_win)
    if ind(i)
        l = my_rectangle(mx_win(i,1), -150, diff(mx_win(i,:)), 300, '--', 'k', gca);
        set(l, 'LineWidth', 3);
    end
end

l(1) = line([eeg.ts(1) eeg.ts(end)], [m m],'Parent', gca );
l(2) = line([eeg.ts(1) eeg.ts(end)], -1*[m m],'Parent', gca );
set(l,'LineStyle', '--', 'Color', 'k', 'linewidth', 3)

ind = diff(tx_win,1,2)>.001;
for i=1:length(tx_win)
    if ind(i)
        l =my_rectangle(tx_win(i,1), -100, diff(tx_win(i,:)), 200, '--', 'g', gca);
        set(l, 'LineWidth',3);
    end
end

l(1) = line([eeg.ts(1) eeg.ts(end)], [p p],'Parent', gca );
l(2) = line([eeg.ts(1) eeg.ts(end)], -1*[p p],'Parent', gca );
set(l,'LineStyle', '--', 'Color', 'g', 'linewidth', 3)


lb = line_browser(gh.control.eeg(1).data, gh.control.eeg_ts, gca); 
% the ripple windows

set(lb, 'LineWidth', 2);

rip_d = rip_data;


lb4 = line_browser(abs(hilbert(rip_d)), gh.control.eeg_ts, gca); 
set(lb4,'LineWidth', 4, 'color', 'c');

lb3 = line_browser(rip_d, gh.control.eeg_ts, gca); 
set(lb3,'LineWidth', 2, 'color', 'r');


for i=1:length(burst_win)
        l =my_rectangle(burst_win(i,1), -175, diff(burst_win(i,:)), 350, '--', 'r', gca);
        set(l, 'LineWidth',3);
end


set(gca, 'Position', [0 .07 1 .93], 'XLim', [2867.1 2868.1]);

pan xon;
zoom xon;

