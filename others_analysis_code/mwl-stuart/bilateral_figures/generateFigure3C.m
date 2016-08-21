function generateFigure3_2C

if ~exist('meanMuaSleep', 'var') || ~exist('meanMuaRun', 'var')
	looking_for_beta_load_data
end

[m, mIdxS] = max(meanMuaSleep);
[m, mIdxR] = max(meanMuaRun);

regIdx{1} = mIdxS:751;
regIdx{2} = mIdxS:751;

y{1} = meanMuaSleep(regIdx{1});
y{2} = meanMuaRun(regIdx{2});

for i = 1:numel(y)
    y{i};
     y{i} = y{i} - min(y{i}) + .000000001;
     y{i} = y{i} ./ max(y{i});
    x{i} = (1:numel(y{i}))-1;
    
    z{i} = log(y{i});
    b{i} = polyfit(x{i},z{i},1);
    
    close all
    
    yHat{i} = exp(x{i} * b{i}(1) + b{i}(2) );
%     if (i==1)
        yHat{i} = yHat{i} ./ max(yHat{i});
%      end

    yDiff{i} = y{i} - yHat{i};
    yDiff{i} = smoothn(yDiff{i}, 2);
    
    [~, peakIdx{i}] = findpeaks(yDiff{i});
    tmp = diff( peakIdx{i} / Fs ) .^ -1;
    freq2(i) = tmp(2);

end


figure;
subplot(211);
line(1000 * x{1} * Fs^-1, y{1}, 'Color', 'r', 'LineWidth', 2);
line(1000 * x{2} * Fs^-1, y{2}, 'Color', 'b', 'LineWidth', 2);

line(1000 * x{1} * Fs^-1, yHat{1}, 'Color', 'r', 'LineWidth', 1, 'linestyle', '--');
line(1000 * x{2} * Fs^-1, yHat{2}, 'Color', 'b', 'LineWidth', 1, 'linestyle', '--');
set(gca,'Xlim', [0 250]);

subplot(212);
line(1000 * x{1} * Fs^-1, yDiff{1}, 'Color', 'r', 'LineWidth', 2);
line(1000 * x{2} * Fs^-1, yDiff{2}, 'Color', 'b', 'LineWidth', 2);

for i = 1:2
    for j = 1:numel(peakIdx{i})
        line(1000 * x{i}(peakIdx{i}(j)) * Fs^-1, yDiff{i}(peakIdx{i}(j)), 'marker', '.', 'linestyle', 'none', 'Color', 'm', 'MarkerSize', 30);
    end
end
set(gca,'Xlim', [0 250]);%, 'YLim', [-.0605 .35]);
% 
% line(x{1}, yHat{1}, 'Color', 'r', 'LineWidth', 2, 'linestyle', '--');
% line(x{2}, yHat{2}, 'Color', 'b', 'LineWidth', 2, 'linestyle', '--');



%%
save_bilat_figure('figure3-2C', f);
end


