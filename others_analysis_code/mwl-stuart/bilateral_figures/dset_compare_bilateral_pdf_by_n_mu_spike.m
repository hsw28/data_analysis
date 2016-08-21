function [corrHigh,  corrLow,  stats] = dset_compare_bilateral_pdf_by_n_mu_spike(d, r1, r2, PLOT)
r = r1;
r(2) = r2;
%%

if nargin==2
    PLOT = 0;
end

nTs = numel(d.mu.timestamps);
burstIdx = interp1(d.mu.timestamps, 1:nTs, d.mu.bursts, 'nearest');
nBurst = size(d.mu.bursts,1);

bRateL = nan(nBurst,1);
bRateR = nan(nBurst,1);

burstLen = diff( d.mu.bursts, [], 2);
for i = 1:nBurst
    bRateL(i) = mean( d.mu.rateL( burstIdx(i,1):burstIdx(i,2) ) );
    bRateR(i) = mean( d.mu.rateR( burstIdx(i,1):burstIdx(i,2) ) );
end

% bRateL = bRateL(i) ./ burstLen;
% bRateR = bRateR(i) ./ burstLen;


if isfield(d.description, 'isexp')
    dPBin = .1;
else
    dPBin = .05;
end

p1 = r(1).pdf;
p2 = r(2).pdf;

N = round( .3 / dPBin );

pSm1 = smoothn(p1, [N/2, 0]);
pSm2 = smoothn(p2, [N/2, 0]);

colCorr = corr_col(pSm1, pSm2);

spikeIdx1 = sum( r(1).spike_counts )' > 0;
spikeIdx2 = sum( r(2).spike_counts )' > 0;

eventCorr = nan(nBurst, 1);

for i = 1:nBurst
    
    validIdx = r(1).tbins >= d.mu.bursts(i,1) & r(1).tbins <= d.mu.bursts(i,2);
    validIdx = validIdx & spikeIdx1 & spikeIdx2;

    eventCorr(i) = mean( colCorr(validIdx) );  
    
end

badIdx = isnan(eventCorr) | isnan(bRateL);

bRateL = bRateL(~badIdx);
bRateR = bRateR(~badIdx);
eventCorr = eventCorr(~badIdx)';

if isempty(bRateL)  || isempty(bRateR) || isempty(eventCorr)
    error('N or C is empty');
end
%%

tholdL = quantile(bRateL, .5);
tholdR = quantile(bRateR, .5);

idxLow  = bRateL < tholdL & bRateR < tholdR;
idxHigh = bRateL > tholdL & bRateR > tholdR;
% idxHigh = n > quantile(n, .75);

corrLow = mean( eventCorr( idxLow) );
corrHigh = mean( eventCorr( idxHigh ) );

% [r_sq, pval] = corr(n,c);

% stats.correlation = r_sq;
% stats.correlation_pval = pval;
stats.colCorr = eventCorr;
stats.burstRate = {bRateL, bRateR};
stats.burstCorr = corr(bRateL, bRateR);
% stats.plot_m = x;
% stats.plot_e= e;
% stats.quantiles = q;



%%

% 
% idx = zeros * n;
% 
% [x, e] = deal( nan(10, 1) );
% q = quantile(n, 0:.1:1);
% qIdx = {};
% for i = 1:10
% %     idx(n > quantile(n, i/10) & n<quantile(n, (i+1)/10) ) = i;
% 
%     idx = n > q(i) & n < q(i+1) ;
%     x(i) = mean( c(idx) );
%     e(i) = 1.96 * std( c(idx) ) / sqrt( nnz(idx) );
%     qIdx{i} = idx;
%     
% end
% 
% 
% pMat = nan(10, 10);
% for i = 1:10
%     for j = 1:10
%         [~, pMat(i,j)] = ttest2(c(qIdx{i}), c(qIdx{j}));
%     end
% end
% 
% if PLOT
%     ax = [];
%     f1 = figure; 
%     ax(1) = axes;
%     [p, l] = error_area_plot(10:10:100, x, e, 'parent', ax);
%     hold on; errorbar(10:10:100, x, e);
%     set(ax, 'XTick', 10:10:100, 'XLim', [9 101]);
%     set(p, 'FaceColor', [.5 .5 .5]);
%     set(l, 'marker', '+');
% 
%     title('Event corr by pop activity');
%     xlabel('Quantile MU Rate');
%     ylabel('Event Corr');
% 
%     if ~isempty(mfilename) % true if run as function
%         figName = sprintf('fig5-bilatCorr-MuSpike-%s-%d-%d', d.description.animal, d.description.day, d.description.epoch);
%         save_bilat_figure(figName,f1, 1); 
%     end
% 
% end

















