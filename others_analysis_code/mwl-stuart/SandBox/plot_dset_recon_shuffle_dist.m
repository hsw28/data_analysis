
function f = plot_dset_recon_shuffle(scores, shuffleScores, name)

[scores, bestIdx] = max(scores,[],2);
nScore = numel(scores);

data = [];

bins = 0:.02:.65;
for i = 1:nScore
    data(i,:) = histc(squeeze(shuffleScores(i,bestIdx(i), :)), bins);
end

data = smoothn(data, [0 1]);
data = normalize(data,2, 'area',1);


% calculate pValues pValue
pVal =[];
for i = 1:nScore
    pVal(i) = 1 - sum(scores(i) > shuffleScores(i,bestIdx(i), :)) / size(shuffleScores, 3);
end

perSig = sum(pVal <= .05) / nScore;


%% Sort results
sortByScore = 1;

if sortByScore==1
    [~, idx] = sort(scores);
else
    [~, idx] = sort(pVal);
end

scores = scores(idx);
pVal = pVal(idx);
data = data(idx,:);
sigIdx = pVal <= .05;
%scores = scores(idx);
%%

f = figure('Name', name);
a(1) = subplot(1,3,1:2);
imagesc(bins,  1:nScore, data);
for i = 1:nScore
    if sigIdx(i)
        c = 'w';
    else
        c = 'k';
    end
    line([scores(i) scores(i)], [i-.5 i+.5], 'color', c, 'linewidth',2);
end

colormap hsv;

set(gca,'YDir', 'normal');
title(name, 'FontSize', 14);

a(2) = subplot(133);
ytmp = 1:nScore;

pVal = pVal + .005;

semilogx(pVal*100, ytmp,'.'); hold on;
semilogx(pVal(sigIdx) * 100, ytmp(sigIdx), 'r.');
line( [5 5], get(gca,'YLim'));
set(gca,'Xlim', [.33 120]);

linkaxes(a, 'y');

title(sprintf('%%Sig: %1.4g', perSig*100), 'FontSize', 14);

fprintf('Mean pVal %1.4g perSig:%1.4g\n', mean(pVal), perSig);

end