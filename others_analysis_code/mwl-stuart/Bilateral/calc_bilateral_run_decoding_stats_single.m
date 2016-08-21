function [precision, precShuf, medCorr, medCorrShuf, stats] = calc_bilateral_run_decoding_stats_single(d, varargin)
%%
% d = e11;
% d = dset;

% d = dset_exp_load('/data/spl11/day11', 'run');
args.N_SHUF = 250;
args.PLOT = 1;
args.REPORT = 1;

stats.N_SHUF = args.N_SHUF;
%args.DSET = isfield(d, 'clusters');

%%args = parseArgs(varargin, args);

% Get the two position PDFS with stopping periods removed

lIdx = strcmp( {d.clusters.hemisphere}, 'left');
rIdx = strcmp( {d.clusters.hemisphere}, 'right');

r(1) = dset_reconstruct(d.clusters(lIdx), 'time_win', d.epochTime, 'tau', .25, 'trajectory_type', 'simple');
r(2) = dset_reconstruct(d.clusters(rIdx), 'time_win', d.epochTime, 'tau', .25, 'trajectory_type', 'simple');

velThold = 15;
runVel = interp1(d.position.ts, abs(d.position.smooth_vel), r(1).tbins);

results.description = dset_get_description_string(d);
%%
if isfield(d.description, 'isexp') && d.description.isexp==1
    dPBin = .1;
else
    dPBin = .05;
end

isRunning = abs(runVel) > velThold;

didSpikeIdx = sum(r(1).spike_counts) & sum(r(2).spike_counts);
validIdx = isRunning & didSpikeIdx';

p1 =  sum(r(1).pdf(:, validIdx, :), 3);
p2 =  sum(r(2).pdf(:, validIdx, :), 3);

nPbin = max(size(p1, 1), size(p2,1));
    
nTbin = size(p1,2);
    
% img = [normc(p1); normc(p2)];
img = [normalize(p1); normalize(p2)];


if args.PLOT
    f1 = figure('Position', [200 600 1000 400]); 
    imagesc(1 - repmat(img, [1 1 3]) );
    line([ 0 size(img,2)], [32.5 32.5], 'color', 'k', 'linewidth', 2);
  
     figName = sprintf('fig3-run-%s-%d-%d', d.description.animal, d.description.day, d.description.epoch);
     save_bilat_figure(figName,f1, 1); 
end


N = round( .3 / dPBin );

pSm1 = smoothn(p1, [N/2, 0]);
pSm2 = smoothn(p2, [N/2, 0]);

%% Compute the Confusion Matrix, and its precision to within 30cm

[~, idx1] = max(pSm1);
[~, idx2] = max(pSm2);

cMat = confusionmat(idx1, idx2, 'order', 1:nPbin);

tmp = ones( nPbin );
ind =  triu( tmp, -N) & tril( tmp, N ) ;

precision = sum(cMat(ind)) / nTbin ;

pShuf = nan(args.N_SHUF, 1);
for i = 1:args.N_SHUF
    
    idxShuf = randsample(idx2, nTbin, 1);
    cTmp = confusionmat(idx1, idxShuf, 'order', 1:nPbin);
    pShuf(i) = sum(cTmp(ind)) /nTbin;
end

precShuf = mean(pShuf);
stats.precShuf = pShuf;
prec_pVal= sum( precision < pShuf ) / args.N_SHUF;

if args.REPORT == 1
    fprintf('Confusion Matrix Precision: %3.4f\tMC-pValue: %1.4f\n', precision, prec_pVal);
end

if args.PLOT == 1
   
    f2 = figure('Position', [510 130 200 800]);
    
    img1 = 1 - repmat( normalize(cMat), [1 1 3] );
    img2 = 1 - repmat( normalize(cTmp), [1 1 3] );
    
    
        
    [F, X, U] = ksdensity(pShuf, 'Width', .02);
    
    subplot(311);
    imagesc( img1 ); 
    title('Confusion Matrix');
    
    subplot(312);
    imagesc( img2 );
    title('Shuffled Conf Matrix');
    
    subplot(313);
    line(X, F, 'color', 'b');
    line(precision * [1, 1], max(F) * [0 1.1], 'color', 'r');
    set(gca, 'XLim', [0 1]);
    title('Precision vs Null Dist');
    
    figName = sprintf('fig3-confmat-%s-%d-%d', d.description.animal, d.description.day, d.description.epoch);
    save_bilat_figure(figName,f2, 1); 
    
end
    
results.confusionMat.acc = precision;
results.confusionMat.pVal = prec_pVal; 


%% Compute the distribution of correlations vs Null distributions

cReal = corr_col(pSm1, pSm2);

[cShufTime, cShufShift] = deal( nan(args.N_SHUF, numel(cReal)) );

nShift = randi(nTbin,1, args.N_SHUF);

for i = 1:args.N_SHUF
    
    randIdx = randsample(nTbin, nTbin);
    cShufTime(i,:) = corr_col(pSm1, pSm2(:, randIdx) );
    cShufShift(i,:) = corr_col(pSm1, circshift(pSm2, [0, nShift(i) ] ) );
    
end

[~, pValTime] = kstest2(cReal, cShufTime(:), .05, 'smaller');
[~, pValShift] = kstest2(cReal, cShufShift(:), .05, 'smaller');

if args.PLOT == 1

    ksArgs = { -1:.025:1, 'support', [-1.01 1.01]};
    [F1, X, u] = ksdensity( cReal, ksArgs{:} );
    [F2, X] = ksdensity( cShufTime(:), ksArgs{:} , 'width', u);
    [F3, X] = ksdensity( cShufShift(:), ksArgs{:}, 'width', u );
    
    f3 = figure;
    ax = axes();

    line(X, F1, 'Color', 'b');
    line(X, F2, 'Color', 'r');
    line(X, F3, 'Color', 'g');

    legend({'Real', 'Shuffled Tbins', 'Shifted Tbins'});
    set(ax, 'XLim', [-1 1]);
    
    figName = sprintf('fig3-colcorr-%s-%d-%d', d.description.animal, d.description.day, d.description.epoch);
    save_bilat_figure(figName,f3, 1); 
   
end

if args.REPORT == 1
    fprintf('Col Correlation pV TB-Swap: %1.4g\tPDF-Shift: %1.4g\n', pValTime, pValShift);    
end

medCorr = median(cReal);
medCorrShuf = median(cShufShift(:));

stats.tbSwapCorr = cShufTime;
stats.tbShiftCorr = cShufShift;

stats.tbSwapPVal = pValTime;
stats.pdfShiftPVal = pValShift;


stats.corrRangeReal = cReal;
stats.corrRangeShift = cShufShift(:);
stats.corrRangeSwap = cShufTime(:);


%%

end