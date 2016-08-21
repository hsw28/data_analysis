function [e data] = generateFigure3_helper(e)
open_pool;
%% Load Data for the figure
% dset = dset_load_all('spl11', 'day15', 'run');
nargin
if ~exist('e', 'var') && nargin==0 
    e = exp_load('/data/spl11/day15', 'epochs', 'run', 'data_types', {'clusters', 'pos'});
    e = process_loaded_exp2(e);
end

runRecon = exp_reconstruct(e,'run', 'structures', {'lCA1', 'rCA1'});
%%


pdf1 = max(runRecon(1).pdf,[],3);
pdf2 = max(runRecon(2).pdf,[],3);

[pdf1Run, pdf2Run, isMovingBins] = fig3_compute_run_pdf(runRecon, e.run.pos);
pdf1Run = max(pdf1Run,[],3);
pdf2Run = max(pdf2Run,[],3);
nBinsMoving = sum(isMovingBins);

%% Compute the Column by Column correlation
smPdf1 = smoothn(pdf1Run, [3 0], 'correct', 1);
smPdf2 = smoothn(pdf2Run, [3 0], 'correct', 1);
colCorr = corr_col(smPdf1, smPdf2);

%% Compute the distances between the modes of the columns
[~, idx1] =  max( max(pdf1Run,[],3) );
[~, idx2] =  max( max(pdf2Run,[],3) );

binDist = abs(idx1 - idx2);
confMat = confmat(idx1, idx2);
confMat = normalize(confMat);

% colCorr = compute_recon_corr(pdf1Run, pdf2Run);
nShuffle = 250;

medDist = median(binDist);
medCorr = nanmedian(colCorr);

medDistShuff = zeros(nShuffle,1);
medCorrShuff = zeros(nShuffle,1);

colCorrShuff = [];
binDistShuff = [];

for iShuffle = 1:nShuffle
    
    shuffIdx = randsample( nBinsMoving, nBinsMoving, 1);
    binDistShuff = [binDistShuff, abs( idx1 - idx2(shuffIdx) )];
    colCorrShuff = [colCorrShuff, corr_col( pdf1Run, pdf2Run(:, shuffIdx) )];
    
    medDistShuff(iShuffle) = median(binDistShuff);
    medCorrShuff(iShuffle) = nanmedian( colCorrShuff);

end    
    



%% Draw the figure

if exist('f', 'var'), delete( f( ishandle(f) ) ); end
if exist('ax', 'var'), delete( ax( ishandle(ax) ) ); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      A - Bilateral Reconstruction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlim = [119 432];
close all; nAx = 0;  f = figure('Position',  [190 75 550 675]);
colormap( 1 - repmat(linspace(0, 1, 20)', [1,3]) );


nAx = nAx+1; ax(nAx) = axes('Position', [.051 .7875 .9182 .1991]);
imagesc( pdf1Run(:, xlim(1):xlim(2)), 'Parent', ax(nAx))
%%fig3_example_run_recon( pdf1Run, pdf2Run,[] , ax(1))

nAx = nAx+1; ax(nAx) = axes('Position', [.051 .5845 .9182 .1991]);
imagesc( pdf2Run(:, xlim(1):xlim(2)), 'Parent', ax(nAx))

set(ax(1:nAx), 'XTick', [], 'YDir', 'normal');
%set(ax(1));
%title('Reconstruction of Run Segments');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      B - Single Lap Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xlim = [4473.6 4482.9];
idx = runRecon(1).tbins >= xlim(1) & runRecon(1).tbins <= xlim(2);
nAx = nAx+1; ax(nAx) = axes('Position', [.071 .285 .18 .2660]);
imagesc(runRecon(1).tbins(idx), [], pdf1(:, idx), 'Parent', ax(nAx));

nAx = nAx+1; ax(nAx) = axes('Position', [.255 .285 .18 .2660]);
imagesc(runRecon(1).tbins(idx), [], pdf2(:, idx), 'Parent', ax(nAx));

set( ax([nAx-1, nAx]),'Xlim', [4473.6 4482.9], 'Ydir', 'normal');
set(ax(nAx), 'Ytick', []);
title('Example Lap', 'Position', [4478.5-5 32 0]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Confusion Matrix  & color bar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nAx = nAx+1;  ax(nAx) = axes('Position', [.53 .285 .3309 .2660]);
imagesc((1:31)/10, (1:31)/10, confMat, 'Parent', ax(nAx));
set(ax(nAx), 'Ydir', 'normal');
title('Confusion Matrix','Position', [1.6 3.1 1.01]);

nAx = nAx+1;  ax(nAx) = axes('Position', [.8768 .285 .03 .2660]);
scaleImg = 1 - repmat(linspace(0, 1, 20)', [1,1,3]);
image(1, linspace(0,1,20), scaleImg, 'Parent', ax(nAx));
set(ax(nAx), 'YDir', 'normal', 'yaxislocation', 'right', 'XTick', [], 'XLim', [.5 1.5]);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       C - Distribution of Column Correlations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(nAx) = axes('Position', [.071 .05 .3663 .15]);
bins = -1:.025:1;
[occCorr, cent] = hist(colCorr, bins); 
[occShuf, cent] = hist(colCorrShuff, bins);


occCorr = occCorr./sum(occCorr);
occShuf = occShuf./sum(occShuf);

occCorrSm = smoothn(occCorr, 2, 'correct', 1);
occShufSm = smoothn(occShuf, 2, 'correct', 1);

occCorr = occCorr./sum(occCorr);
occShuf = occShuf./sum(occShuf);

patch([cent 1], [occCorrSm 0], 1, 'FaceColor', 'r',  'Parent', ax(nAx));hold on;
patch([cent 1], [occShufSm 0], 1, 'FaceColor', 'g',  'Parent', ax(nAx)); 

% line(cent, occCorr, 'Color', 'r', 'LineWidth', 2, 'Parent', ax(nAx));
% line(cent, occShuf,'Color', 'g',  'LineWidth', 2, 'Parent', ax(nAx));

set(ax(nAx),'XLim', [-1 1.025], 'XTick', [-1:.5:1], 'YLim', [0 .30]);
title('PDF Correlation', 'Position', [0 .3 1]); 

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %       D - Distance between the modes of the two pdfs
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ax(nAx) = axes('Position', [.5185 .2511 .3663 .15]);
% [occ, cent] = hist(binDist, 0:31);
% occ = occ./sum(occ);
% bar(cent/10,occ, 1,'Parent', ax(5)); 
% set(ax(5), 'XLim', [-.1 3]);
% title('\Delta pos of Pdf mode', 'Position', [1.5 1 1]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       E - Example shuffle of correlations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% ax(nAx) = axes('Position', [.0766 .0641 .3663 .1305]); % axes 6 is up in the recon
% bins = -3:.1:1;
% [occ, cent] = hist(colCorrShuff, bins);
% occ = occ./sum(occ);
% bar(cent, occ, 1,'Parent', ax(7));
% set(ax(nAx),'XLim', [-1.05 1.1], 'XTick', [-1:.5:1]);
% title('Shuff PDF Correlation', 'Position', [0 1 1]); 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %       F - Shuffle of distances
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ax(8) = axes('Position', [.5185 .0641 .3663 .1305]); % axes 6 is up in the recon
% 
% [occ, cent] = hist(binDistShuff, 0:31); 
% occ = occ./sum(occ);
% bar(cent/10,occ, 1,'Parent', ax(8));
% set(ax(8), 'XLim', [-.1 3]);
% title('\Delta pos of Shuff Pdf mode', 'Position', [1.5 .1 1]);

%% Save the Figure
save_bilat_figure('figure3', f);


%%end
end


