clear;
%% -- SIMPLE -- Compute the correlation between line slopes or angles
eRun = dset_list_epochs('run');

lSlp = [];
rSlp = [];

doRun = 0;
isRun = 0;

smoothPdf = 1;
for i = 1:size(eRun,1)
        
    d = dset_load_all(eRun{i,1}, eRun{i,2}, eRun{i,3});
    lIdx = strcmp({d.clusters.hemisphere}, 'left');
    rIdx = strcmp({d.clusters.hemisphere}, 'right');
    
    [s.L r.L] = dset_calc_replay_stats(d, lIdx, [], [], smoothPdf);
    [s.R r.R] = dset_calc_replay_stats(d, rIdx, [], [], smoothPdf);
    
    [maxL mIdxL] = max(s.L.score2, [], 2);
    [maxR mIdxR] = max(s.R.score2, [], 2);
    
    idx = mIdxL;
    idx(maxR > maxL) = mIdxR(maxR > maxL);
    
    ind = sub2ind(size(s.L.score2), 1:size(s.L.score2,1), idx');

    lSlp = [lSlp, s.L.slope(ind)];
    rSlp = [rSlp, s.R.slope(ind)];
    
end
%%
nanIdx = isnan(lSlp) | isnan(rSlp);
lSlp = lSlp(~nanIdx);
rSlp = rSlp(~nanIdx);

%%

lVar = atan(lSlp);
rVar = atan(rSlp);

cReal = corr(lVar(:), rVar(:));
%%
nShuffle = 1000;
cShuff = zeros(nShuffle, 1);
for i = 1:nShuffle
    shuff = randsample(lVar, numel(lVar), true);
    cShuff(i) = corr(lVar', shuff');
end
%%
plot_shuffles(cShuff, cReal);
%% -- COMPLEX -- Compute the correlation between line slopes but using a matrix of positions
clear;
%%
smoothPdf = 1;
eRun = dset_list_epochs('run');

matL = {};
matR = {};
cReal = [];

%% Load the data
% compute the left and right replay stats

d = dset_load_all(eRun{i,1}, eRun{i,2}, eRun{i,3});
lIdx = strcmp({d.clusters.hemisphere}, 'left');
rIdx = strcmp({d.clusters.hemisphere}, 'right');

[s.L r.L] = dset_calc_replay_stats(d, lIdx, [], [], smoothPdf);
[s.R r.R] = dset_calc_replay_stats(d, rIdx, [], [], smoothPdf);

[maxL mIdxL] = max(s.L.score2, [], 2);
[maxR mIdxR] = max(s.R.score2, [], 2);
maxIdx = mIdxL;
maxIdx(maxR > maxL) = mIdxR(maxR > maxL);

%% Create the line-matricies using the already computed line statistics

for j = 1:size(d.mu.bursts, 1)

    tempIdx = r.L.tbins >= d.mu.bursts(j,1) & r.L.tbins <= d.mu.bursts(j,2);
    r.L.replayIdx = r.L.replayIdx | tempIdx;
    tIdx = maxIdx(j);

    [~, matL{j}] = compute_line_score(r.L.tbins(tempIdx), r.L.pbins{tIdx}, r.L.pdf{tIdx}(:,tempIdx), s.L.slope(j, tIdx), s.L.intercept(j, tIdx), smoothPdf);
    [~, matR{j}] = compute_line_score(r.L.tbins(tempIdx), r.L.pbins{tIdx}, r.L.pdf{tIdx}(:,tempIdx), s.R.slope(j, tIdx), s.R.intercept(j, tIdx), smoothPdf);        
end

%% - Compute the correlation between Left and Right line-matrices
% take each line matrix and resize it to 50x75 (this standardizes track 
% length and burst duration). Then stack the matrices one on top of another
% finally compute the 2d correlation between left and right matrices

nShuffle = 250;
newSize = [50 75];

left = [];
right = [];

for j = 1:size(matL, 2)
    if any( isnan(matL{j})) | any( isnan(matR{j}))
        continue;
    end
    left = [left, imresize(matL{j}, newSize, 'nearest')];
    right= [right, imresize(matR{j}, newSize, 'nearest')];
end
cReal = corr2(left, right);

%% Compute the shuffled line-image correaltions
% randomly resample from the left hand matrices, compute the stacked matrix
% and correlation 250 times, use this shuffle as null distribution

nShuffle = 250;
shuf = [];
wb = my_waitbar(0);
cShuf = [];

for n = 1:nShuffle
    shuf = nan(size(left));
    matS = randsample(matL, numel(matL), 1);

    curIdx = 1;
    for j = 1:size(matL, 2)
        if any( isnan(matL{j})) | any( isnan(matR{j}))
            continue;
        end

        while any(isnan(matS{j}))
            tmp = randsample(matL, 1);
            matS{j} = tmp{1};
        end

        shuf( :, curIdx:curIdx+newSize(2)-1 ) = imresize(matS{j}, newSize, 'nearest');
        curIdx = curIdx + newSize(2);
    end

    cShuf(n) = corr2(left, shuf);
    wb = my_waitbar(n/nShuffle, wb);
end
%% Plot the distribution of shuffle correaltions compared to the actual bilat comparison
plot_shuffles(cShuf, cReal);

%%

for j = 1:size(matL, 2)
    if any( isnan(matL{j})) | any( isnan(matR{j}))
        cReal(j) = nan;
        continue;
    end
    cReal(j) = corr2(matL{j}, matR{j});
end
%%


















