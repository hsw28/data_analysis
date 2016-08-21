clear;
%%
tmp = dset_load_all('Bon', 4, 2);
[tmp, peakIdx] = dset_get_ripple_events(tmp);
tmpData = dset_compute_ripple_params(tmp);


winIdx = round([-.2 .2] * tmp.eeg(1).fs);
window = winIdx(1):winIdx(2);

nSamp = numel(tmp.eeg(1).data);

dt = tmp.eeg(1).fs;
st = tmp.eeg(1).starttime;
ts = st + (0:(nSamp-1))*dt;

ripTs = tmp.ripples.peakTs;
ripPeakIdx = interp1(ts, 1:nSamp, ripTs);

ripWin = bsxfun(@plus, ripPeakIdx, window);

tmpWaves1 = tmp.eeg(1).data(ripWin);
tmpWaves2 = tmp.eeg(3).data(ripWin);

%%
xTs = window ./tmp.eeg(1).fs;

close all;
figure;
axes();
line(xTs, mean(tmpWaves1), 'Color', 'r','LineWidth', 3);
line(xTs, mean(tmpData.raw{1}), 'Color', 'k' );

line(xTs, mean(tmpWaves2), 'Color', 'g', 'LineWidth', 3);
line(xTs, mean(tmpData.raw{3}), 'Color', 'c');

%%


%% 
clear idx x y;
figure; axes;

for j = 10:100
    color = 'rg';

    idx{1} = tmpData.window(j,:);
    idx{2} = ripWin(j,:);


    for i = 1:2
        y = tmp.eeg(1).data(idx{i}) + i * 20;
        x = ts(idx{i}) ;
        line(x,y, 'LineWidth', 2, 'Color', color(i));
    end
    pause;
    
    delete(get(gca,'Children'));
    
end
