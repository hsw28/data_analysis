
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
m = mean(shuffleScores, 3);
s = std(shuffleScores,[], 3);

idx = sub2ind(size(m), (1:size(m,1)), bestIdx');

z = (scores' - m(idx)) ./ s(idx);
% 
% for i = 1:nScore
%     scores(i) = scores(i)-m(i, bestIdx(i));
%     z(i) = score(i) / s(i, bestIdx(i));
% end

%% Sort results
sortByScore = 1;

if sortByScore==1
    [~, idx] = sort(scores);
else
    [~, idx] = sort(z);
end

scores = scores(idx);
z = z(idx);
data = data(idx,:);
sigIdx = 1 - normcdf(z) <= .05;
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


plot(z, ytmp,'.'); hold on;
plot(z(sigIdx), ytmp(sigIdx), 'r.');
set(a(2),'Xlim', [-3 4]);


linkaxes(a, 'y');


end