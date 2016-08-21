d = dset_load_all('Bon', 4, 2);
d = dset_calc_ripple_params(d);

dOrig = d;

%%
clearvars -except dOrig;

r = dOrig.ripples;
mu = dOrig.mu;
e = dOrig.eeg(1);


eegTs = dset_calc_timestamps(e.starttime, numel(e.data), e.fs);
ripTs = eegTs(r.chPeakIdx{1});

[trip, sing] = filter_event_sets(ripTs, 3, [1, .250, .25]);

[mRate{1}, ~, ts] = meanTriggeredSignal(ripTs, mu.timestamps, mu.rate, [-.25 .5]);
[mRate{2}, ~, ts] = meanTriggeredSignal(ripTs(sing), mu.timestamps, mu.rate, [-.25 .5]);
[mRate{3}, ~, ts] = meanTriggeredSignal(ripTs(trip), mu.timestamps, mu.rate, [-.25 .5]);


close all;

figure; 

ax = axes('NextPlot', 'add');

line(ts, mRate{1}, 'color', 'k');
line(ts, mRate{2}, 'color', 'r');
line(ts, mRate{3}, 'color', 'b');


[~, pkIdx] = findpeaks(mRate{3});
pkTs = ts(pkIdx);
pkTs = pkTs (pkTs > -.1 & pkTs < .5);

dPkTs = diff(pkTs);


for i = 1:numel(pkTs)
    line( pkTs(i) * [1 1], max(mRate{1}) * [0 1], 'color', 'k');
    if i<numel(pkTs)
        text(pkTs(i) + .01, max(mRate{1}) * .9, sprintf('%3.3f', dPkTs(i)*1000));
    end
end
%%
subplot(212);

for i = 1:numel(trip)
    curTs = ripTs( trip(i) );
   for j = 1:numel(ripTs)
       if ripTs < (curTs - .2) | ripTs > (curTs + .5);
           continue;
       end
       
       line( ripTs(j) - curTs .* [1 1], i + [0, 1], 'color', 'k');
   end 
end

set(get(gcf,'Children'),'XLim', [-.2 .5]);


%% MULTI UNIT BURSTS
clear; close all;
eList = dset_list_epochs('sleep');

dPeaks = [];
rateAll = [];
for e = 1:size(eList,1)
    
    d = dset_load_all(eList{e,:});
    %%
    mu = d.mu;

    bLen = diff(mu.bursts, [], 2);

    q = 30 ./ numel(bLen) ;
    lenThold = quantile(bLen, 1 - q);
    
    lIdx = find( bLen > lenThold );


    figure('Position', [400 80 500 1000])
    ax = axes('Position', [.025 .01 .95 .95], 'NextPlot', 'add');
    title(dset_get_description_string(d));

    win = [-.25 .5];
    winIdx = mu.fs * win;
    winIdx = winIdx(1):winIdx(2);

    rate = zeros(numel(lIdx), numel(winIdx));

    e = d.eeg(1);
    eegTs = dset_calc_timestamps(e.starttime, numel(e.data), e.fs);
    
    maxY = 0;
    for i = 1:numel(lIdx);
        b = d.mu.bursts(lIdx(i),:);
        idx = find( mu.timestamps >= b(1) & mu.timestamps <= b(2) );

    %     [~, maxIdx] = max( mu.rate(idx) );
        [~, maxIdx] = findpeaks(mu.rate(idx)); maxIdx = maxIdx(1);

        idx = idx(maxIdx);

        rate(i,:) = mu.rate(winIdx + idx);
        x = [mu.timestamps(winIdx+idx) - mu.timestamps(idx)];
        y = [ mu.rate(winIdx + idx) ];
        x = (x(:))';
        y = (y(:))';
        patch( [x(1), x, x(end)], maxY + [0, y, 0], 'b');

        maxY = max(y)*1.2 + maxY;
        
        eIdx = eegTs >= b(1) + win(1) & eegTs <= b(2) - win(1);
        line(eegTs(eIdx) - mu.timestamps(idx), e.data(eIdx) + maxY - mean(y), 'color', 'r');
    end
    
    for i = 1:10
        line(.075 * (i-1) * [1 1], [0 maxY], 'color', 'k');
    end

%     set(gca,'YLim', [0 maxY], 'XLim', win);
% 
%     ts = winIdx / mu.fs;
%     mRate = mean( rate );
%     mRate = smoothn( mRate, 2);
%     
%     rateAll = [rateAll; rate];
% 
%     figure('Position', [900 550 775 240] + 3 * [30 5 0 0]);
%     plot( ts, mRate);
%     title(dset_get_description_string(d));
% 
%     [~, pkIdx] = findpeaks( mRate );
%     pkTs = ts(pkIdx);
% 
% 
%     for i = 1:numel(pkTs)
% 
%         if pkTs(i) < -.06 || pkTs(i) > lenThold;
%             continue;
%         end
% 
%         line( pkTs(i) * [1 1], [0 max( mRate) ], 'color', 'r', 'linestyle', '--');
% 
%         if pkTs(i+1) < lenThold;
%             dPK = pkTs(i+1) - pkTs(i);
%             
%             t = text( mean( pkTs([i, i+1])) , max( mRate ) * .75, sprintf('%2.2f', 1000 * dPK ));
%             set(t,'HorizontalAlignment', 'center');
%             dPeaks = [dPeaks; dPK];
%         end
%         
%         line(lenThold * [1 1], [0 max( mRate) ], 'color', 'k'); 
%         
%     end
%     
%     set(gca,'XLim', [-.25 .5]);
%     drawnow;
end

%%
figure;
subplot(211);
hist( dPeaks * 1000, 0:5:130);
title('Distribution of MUB Inter Peak Intervals');


subplot(212);
ksdensity(dPeaks * 1000);

linkaxes( get(gcf,'Children'), 'x');
%%
figure; 
plot(ts * 1000, mean( rateAll) );
set(gca,'Xlim', [-125 250 ]);
title('Mean MUB Triggered MU Rate');


%%
clear;
eList = dset_list_epochs('sleep');
nE = size(eList,1);

mEnvAll = nan(nE, 751);
mEnvTri = nan(nE, 751);

win = [-.15 .35];
ripTholdWin = [1 .25 .25];

for i = 1:nE;
    
    d = dset_load_all( eList{i,:} );
    d = dset_calc_ripple_params(d);
    e = d.eeg(1);
    r = d.ripples;
   

    env = abs(hilbert(e.rippleband));
    eegTs = dset_calc_timestamps(e.starttime, numel(e.data), e.fs);

    ripTs = eegTs(r.chPeakIdx{1});
    tIdx = filter_event_sets(ripTs, 3, ripTholdWin);

    [mEnvAll(i,:), ~, ts] = meanTriggeredSignal(ripTs, eegTs, env, win);
    [mEnvTri(i,:), ~, ~ ] = meanTriggeredSignal(ripTs(tIdx), eegTs, env, win);

end
%%
close all
plot(ts, mEnvAll); hold on;
plot(ts, mEnvTri, 'r')
set(gca,'XLim', win);
%%

mEnvAll = normalize(mEnvAll')';
mEnvTri = normalize(mEnvTri')';

mAll = nanmean(mEnvAll)
mTri = nanmean(mEnvTri);

mAll = smoothn(mAll, 12, 'correct', 1);
mTri = smoothn(mTri, 12, 'correct', 1);

close all;
figure;

ax = axes;

line(ts, mAll, 'color', 'b');
line(ts, mTri, 'color', 'r');

[~, pkIdx] = findpeaks(mTri);
pkTs = ts(pkIdx);
pkTs = pkTs(pkTs > -0.005);

dPk = diff(pkTs);
nPk = numel(pkTs);

for i = 1:nPk
    line(pkTs(i)  * [1 1], [0 max(mAll)], 'color', [.7 .7 .7], 'linestyle', '--');
    if i>1
        t = text( mean(pkTs([i, i-1])), max(mAll)*.75, sprintf('%2.2f', dPk(i-1)*1000));
        set(t,'HorizontalAlignment', 'center');
    end
end



%%
dPK_ALL = [];
for j = 1:10
    if j==5
        continue;
    end
mAll = mEnvAll(j,:);
mTri = mEnvTri(j,:);

mAll = smoothn(mAll, 12, 'correct', 1);
mTri = smoothn(mTri, 12, 'correct', 1);

figure;

ax = axes;

line(ts, mAll, 'color', 'b');
line(ts, mTri, 'color', 'r');

[~, pkIdx] = findpeaks(mTri);
pkTs = ts(pkIdx);
pkTs = pkTs( pkTs >= -.005 & pkTs < .3);


dPk = diff(pkTs);
nPk = numel(pkTs);

for i = 1:nPk
    line(pkTs(i)  * [1 1], [0 max(mAll)], 'color', [.7 .7 .7], 'linestyle', '--');
    if i>1
        t = text( mean(pkTs([i, i-1])), max(mAll)*.75, sprintf('%2.2f', dPk(i-1)*1000));
        set(t,'HorizontalAlignment', 'center');
    end
end

dPK_ALL = [dPK_ALL; dPk(:)];


end

%%
set(gca,'XLim', [-.1 .3]);
set(gca,'

%%


d = dset_load_all('spl11',11,'sleep');
%%
d = dset_calc_ripple_params(d);
%%
















