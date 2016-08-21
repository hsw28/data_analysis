function [xcRateSleep, lags] = generateFigure3_xCorr
%%
clear;
eListSleep = dset_list_epochs('sleep');
eListRun = dset_list_epochs('run');
N = size(eListSleep,1);

win = .25;
maxLag = round( win * 200 );
nLag = maxLag*2 + 1;
lags = -maxLag:maxLag;

ts = lags / 200;

[sAll, sLong, sShort] = deal( nan(N, nLag) );
[rAll, rLong, rShort] = deal( nan(N, nLag) );


parfor i = 1:N
%%    
    d = dset_load_all(eListSleep{i,:});

    burstLen = diff(d.mu.bursts, [], 2);
    tHold = quantile(burstLen, .5);
    sBurstIdx = burstLen < tHold;
    lBurstIdx = burstLen > tHold; 
    
    idxAll = seg2binary(d.mu.bursts, d.mu.timestamps);
    idxLong = seg2binary(d.mu.bursts(lBurstIdx,:), d.mu.timestamps);
    idxShort = seg2binary(d.mu.bursts(sBurstIdx,:), d.mu.timestamps);

    sAll(i,:) = xcorr(d.mu.rateL(:) .* idxAll(:), d.mu.rateR(:) .* idxAll(:), maxLag, 'coeff');
    sLong(i,:) = xcorr(d.mu.rateL(:) .* idxLong(:), d.mu.rateR(:) .* idxLong(:), maxLag, 'coeff');
    sShort(i,:) = xcorr(d.mu.rateL(:) .* idxShort(:), d.mu.rateR(:) .* idxShort(:), maxLag, 'coeff');

    
    d = dset_load_all(eListRun{i,:});

    burstLen = diff(d.mu.bursts, [], 2);
    tHold = quantile(burstLen, .5);
    sBurstIdx = burstLen < tHold;
    lBurstIdx = burstLen > tHold; 
    
    idxAll = seg2binary(d.mu.bursts, d.mu.timestamps);
    idxLong = seg2binary(d.mu.bursts(lBurstIdx,:), d.mu.timestamps);
    idxShort = seg2binary(d.mu.bursts(sBurstIdx,:), d.mu.timestamps);

    rAll(i,:) = xcorr(d.mu.rateL(:) .* idxAll(:), d.mu.rateR(:) .* idxAll(:), maxLag, 'coeff');
    rLong(i,:) = xcorr(d.mu.rateL(:) .* idxLong(:), d.mu.rateR(:) .* idxLong(:), maxLag, 'coeff');
    rShort(i,:) = xcorr(d.mu.rateL(:) .* idxShort(:), d.mu.rateR(:) .* idxShort(:), maxLag, 'coeff');
    
end


%%
close all;
f = figure; 
axes('NextPlot', 'add');
line(ts, mean(sAll), 'color', 'r');
line(ts, mean(rAll), 'color', 'b');

set(gca,'XLim', win * [-1 1]);

figName = 'Fig3_Bilateral_muRateXcorr_duringMUB';
save_bilat_figure(figName, f);

%%
figure('Position', get(gcf, 'position') + [50 100 0 0 ]); 
axes('NextPlot', 'add');
line(ts, mean(sAll), 'color', 'k');
line(ts, mean(sShort), 'color', 'r');
line(ts, mean(sLong), 'color', 'b');



%%
close all;
imagesc(sLong);

%%

plot(sLong(10,:))
%%


all = cell(10,1);
short = cell(10,1);
long = cell(10,1);
parfor j = 1:10
    
    d = dset_load_all(eListSleep{j,:});

    burstLen = diff(d.mu.bursts, [], 2);
    thH = quantile(burstLen, .95);
    thS = quantile(burstLen, .25);
    nBurst = numel(burstLen);
    sBurstIdx =  burstLen < thS ; 
    lBurstIdx =  burstLen > thH ;

    %%
    a = nan(nBurst, nLag);
    for i = 1:nBurst

        idx = seg2binary(d.mu.bursts(i,:), d.mu.timestamps);
        tmpxc = xcorr( d.mu.rateL(:) .* idx(:), d.mu.rateR(:)  .* idx(:) , maxLag, 'coeff');
        a(i,:) = tmpxc;

    end
    %%

    s = a(sBurstIdx,:);
    l = a(lBurstIdx,:);
    
    all{j} = a;
    short{j} = s;
    long{j} = l;
end

figure;
%%

A = cell2mat(all);
S = cell2mat(short);
L = cell2mat(long);

 figure();
 axes('NextPlot', 'add');
line(ts, mean(A), 'color', 'k');
line(ts, mean(S), 'color', 'r');
line(ts, mean(L), 'color', 'b');

    
    
%%
figure;
    

%%
end

