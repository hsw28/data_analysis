function ax = dipsHistogram(muaRate,trode_groups,timewin,yl)

%f = figure('units','inches','position',[22 1 5.5 6],'menu','none');
%set(ghf,'Color',[1 1 1]);

muaRate = contwin(muaRate,timewin);

ts = linspace(0,0.5,200);
edges = bin_centers_to_edges(ts);

rscRate = eegByArea(muaRate,trode_groups,'RSC');
otherRate = eegByArea(muaRate,trode_groups,'CTX');

rscColor = [0 1 0];
otherColor = [1 0 1];

rscYs = myHist(rscRate,edges,timewin);
otherYs = myHist(otherRate,edges,timewin);
maxYs = max([max(rscYs), max(otherYs)]);
ax = plot(ts, rscYs ./ maxYs, '-', 'Color', rscColor, 'LineWidth', 3);
hold on;
plot(ts, otherYs ./ maxYs, '-', 'Color', otherColor, 'LineWidth', 3);

if(~isempty(yl))
    ylim(yl);
end

end


function [ys] = myHist(muaRate,edges,timewin)

[dips,~] = find_dips_frames(muaRate);
dipLens = cellfun(@(x) x(2) - x(1), dips);
ys = smooth(histc(dipLens,edges),10) ./ diff(timewin);
ys = ys(1:(end-1));
ys = ys .* 60; % Events per minute

end