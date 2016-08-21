
eegWin = round( [-.5 1] * eegFs );
eegWin = eegWin(1):eegWin(2);

tmpTrip = tripSindleIdx;
tmpSolo = soloSpindleIdx;

tmpTrip = tmpTrip( tmpTrip > 250 );
tmpSolo = tmpSolo( tmpSolo> 250);

eegTripSamp = bsxfun(@plus, tripSpindleIdx, eegWin);
eegSoloSamp = bsxfun(@plus, tmpSolo, eegWin);


spinBandTrip = isSpindlePow(eegTripSamp);
spinBandSolo = isSpindlePow(eegSoloSamp);

figure;
axes('NextPlot', 'add');

plot(eegWin * 1000/eegFs, smoothn( mean(spinBandTrip), 3 ), 'r')
plot(eegWin * 1000/eegFs, smoothn( mean(spinBandSolo), 3 ), 'g')
%%
figure;
subplot(211);
imagesc(spinBandTrip);
subplot(212);
imagesc(spinBandSolo);
%%
figure;
line_browser(muRate', muTs);

shortIdx = find(burstLen < .1);
longIdx = find(burstLen > .3);

x1 = [];
y1 = [];
for i = 1:numel(shortIdx)
    
    b = muBursts(shortIdx(i),:);
    idx = muTs>b(1) & muTs<b(2);
    x1 = [x1, nan,  muTs(idx)];
    y1 = [y1, nan,  muRate(idx)];
      
end

x2 = [];
y2 = [];

for i = 1:numel(longIdx)
    
    b = muBursts(longIdx(i),:);
    idx = muTs>b(1) & muTs<b(2);
    x2 = [x2, nan,  muTs(idx)];
    y2 = [y2, nan,  muRate(idx)];
      
end


line(x1,y1,'color','r', 'linewidth', 2);
line(x2,y2,'color','g', 'linewidth', 2);
