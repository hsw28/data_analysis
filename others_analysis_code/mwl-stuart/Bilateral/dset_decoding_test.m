
clear;

ep = 'sleep';
d = dset_exp_load('/data/spl11/day11', ep);

b = d.mu.bursts;

lIdx = strcmp( {d.clusters.hemisphere},'left');
rIdx = strcmp( {d.clusters.hemisphere},'right');

clear r
r(1) = dset_reconstruct(d.clusters(lIdx), 'tau', .02, 'time_win', d.epochTime);
r(2) = dset_reconstruct(d.clusters(rIdx), 'tau', .02, 'time_win', d.epochTime);

fprintf('N Cells Left:%d Right:%d\n', nnz(lIdx), nnz(rIdx));
fprintf('N MUB:%d\n', size(b,1));
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eventList = [];

% RUN RUN RUN RUN RUN RUN RUN RUN RUN
%
% eventList = [59, 85,107,126]; % SPL11-DAY11
% eventList = [72, 94, 99];     % SPL11 DAY 12 <-- EXAMPLE
% eventList = [64,190, 203];    % SPL11 DAY 13 
% eventList = [150 ]            % SPL11 DAY14  <-- EXAMPLE
% eventList = [80, 113] % SPL11 DAY 16 <- Example good vs bad sampling

% SLEEP SLEEP SLEEP SLEEP SLEEP SLEEP
%
% eventList = [471, 525, 579,  826, 969, 1078]; % SPL11 DAY 11 A few good examples of replay spanning bursts
% eventList = [34, 38, 115, 188, 250];      %SPL11 DAY 12
% eventList = [4, 48, 275, 289];            % spl11-d15
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear tb pb p1 p2 l;


tb = r(1).tbins;
pb = r(1).pbins;
p1 = r(1).pdf(:,:,1);
p2 = r(2).pdf(:,:,1);

p1 = normc(p1);
p2 = normc(p2);

close all;
figure('Position', [500 100 560 800], 'WindowStyle', 'docked');
ax(1) = axes('Position', [.05 .5 .9 .45]);
imagesc(tb, pb, 1 - repmat(p1, [1 1 3]), 'Parent', ax(1));
ax(2) = axes('Position', [.05 .02 .9 .45]);
imagesc(tb, pb, 1 - repmat(p2, [1 1 3]), 'Parent', ax(2));

l(1) = line([1 1 1 1 1 1], [1 1 1 1 1 1], 'color', 'r', 'parent', ax(1));
l(2) = line([1 1 1 1 1 1], [1 1 1 1 1 1], 'color', 'r', 'parent', ax(2));

if isempty(eventList)
    eventList = 1:size(b,1);
end

for idx = 1:numel(eventList)
    i = eventList(idx);
    x = [b(i,1), b(i, 1), nan, b(i,2), b(i,2)];
    y = max(pb) * [0 1 nan 1 0];
    
    title(ax(1), sprintf('%d of %d', i, numel(eventList)), 'FontSize', 16);
    set(ax,'XLim', mean(b(i,:)) + [-.25 .25])
    set(l, 'XData', x, 'YData', y);
    
    if idx<numel(eventList)
        pause;
    end
    
end