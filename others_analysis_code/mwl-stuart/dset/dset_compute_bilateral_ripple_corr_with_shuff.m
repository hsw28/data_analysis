function [run sleep] = dset_compute_bilateral_ripple_corr_with_shuff()

%% -- Are bilateral ripple frequencies correlated?
%% RUN

varStr = 'freqMean';

data = load('/data/franklab/bilateral/ripple_ananlysis_run.mat', 'run');
run = data.run;

frB = cell2mat( {run.(varStr).base} );
frC = cell2mat( {run.(varStr).cont} );

clear run;

badIdx = isnan(frB) | isnan(frC);

frB = frB(~badIdx);
frC = frC(~badIdx);


nShuf = 1000;
cReal = corr2(frB, frC);
cShuf = zeros(nShuf,1);
for i = 1:nShuf
    frS = randsample(frB, numel(frC));
    cShuf(i) = corr2(frB, frS);
end
[m s] = normfit(cShuf);

bins = -0.075:.0025:0.075;
area = numel(cShuf) * mean(diff(bins));
curve = area / (s * sqrt(2*pi)) * exp( -1 * (bins - m).^2 / (2*s^2) ); 

h = histc(cShuf, bins);

figure; axes();

bar(bins, h, 1)% [min(cShuf), max(cShuf)])
line(bins, curve, 'color', 'm', 'linewidth', 2, 'linestyle', '--');
set(gca,'Xlim', [ min(bins)-.01 cReal + .01]);

yLim = get( gca,'Ylim');
line([cReal, cReal], yLim, 'color', 'r', 'linewidth', 2);
set(gca,'YTick', []);

p1 = sum( cReal <= cShuf) / nShuf;
p2 =  1 - normcdf(cReal, m, s);

title(sprintf('Run p1:%1.4g      p2:%1.4g', p1, p2), 'fontsize', 14);


run.cReal = cReal;
run.cShuf = cShuf;
run.pMonteCarlo = p1;
run.pNormCdf = p2;

%% sleep
clearvars -except run varStr;

data = load('/data/franklab/bilateral/ripple_ananlysis_sleep.mat', 'sleep');
sleep = data.sleep;

frB = cell2mat( {sleep.(varStr).base} );
frC = cell2mat( {sleep.(varStr).cont} );

badIdx = isnan(frB) | isnan(frC);

frB = frB(~badIdx);
frC = frC(~badIdx);


nShuf = 1000;
cReal = corr2(frB, frC);
cShuf = zeros(nShuf,1);
for i = 1:nShuf
    frS = randsample(frB, numel(frC));
    cShuf(i) = corr2(frB, frS);
end
[m s] = normfit(cShuf);

bins = -0.075:.0025:0.075;
area = numel(cShuf) * mean(diff(bins));
curve = area / (s * sqrt(2*pi)) * exp( -1 * (bins - m).^2 / (2*s^2) ); 

h = histc(cShuf, bins);

figure; axes();

bar(bins, h, 1)% [min(cShuf), max(cShuf)])
line(bins, curve, 'color', 'm', 'linewidth', 2, 'linestyle', '--');
set(gca,'Xlim', [ min(bins)-.01 cReal + .01]);

yLim = get( gca,'Ylim');
line([cReal, cReal], yLim, 'color', 'r', 'linewidth', 2);
set(gca,'YTick', []);

p1 = sum( cReal <= cShuf) / nShuf;
p2 =  1 - normcdf(cReal, m, s);

title(sprintf('Sleep p1:%1.4g      p2:%1.4g', p1, p2), 'fontsize', 14);

sleep.cReal = cReal;
sleep.cShuf = cShuf;
sleep.pMonteCarlo = p1;
sleep.pNormCdf = p2;


end