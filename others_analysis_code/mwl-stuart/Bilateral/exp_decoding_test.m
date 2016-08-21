
clear;

e = exp_load_sleep('/data/spl11/day12', 1 7]);
ep = 'sleep';
% 
% e = exp_load_run('/data/spl11/day12');
% ep = 'run';

b = e.(ep).mu.bursts;

lIdx = strcmp( {e.(ep).cl.loc}, 'lCA1');
rIdx = strcmp( {e.(ep).cl.loc}, 'rCA1');

[eLeft, eRight] = deal(e);
eLeft.(ep).cl = eLeft.(ep).cl(lIdx);
eRight.(ep).cl = eRight.(ep).cl(rIdx);

clear r
r(1) = exp_reconstruct(eLeft, ep, 'tau', .02, 'directional', 0);
r(2) = exp_reconstruct(eRight, ep, 'tau', .02, 'directional', 0);

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Potential RUN Replay Events
% spl11-d10 replay events: NONE
% eventList = [41, 42, 59, 65, 97, 120]; %spl11-d11
% eventList = [31, 49, 54]; % spl11-d12
% eventList = [40,131,139]; % spl11-d13
% eventList = [124] %spl11-d14
% spl11-d15 replay events: NONE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Potential SLEEP Replay Events
eventList = [35,39,188,251,406,479, 512]; % spl11-d12-sleep
% spl11-d13 replay events: 
% spl11-d14 replay events:
% eventList = [4, 48, 80]; % spl11-d15
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear tb pb p1 p2 l;


tb = r(1).tbins;
pb = r(1).pbins;
p1 = r(1).pdf(:,:,1);
p2 = r(2).pdf(:,:,1);

close all;
figure('Position', [500 100 560 800], 'WindowStyle', 'docked');
ax(1) = axes('Position', [.05 .5 .9 .45]);
imagesc(tb, pb, 1 - repmat(p1, [1 1 3]), 'Parent', ax(1));
ax(2) = axes('Position', [.05 .02 .9 .45]);
imagesc(tb, pb, 1 - repmat(p2, [1 1 3]), 'Parent', ax(2));

l(1) = line([1 1 1 1 1 1], [1 1 1 1 1 1], 'color', 'r', 'parent', ax(1));
l(2) = line([1 1 1 1 1 1], [1 1 1 1 1 1], 'color', 'r', 'parent', ax(2));

for idx = 1:numel(eventList)
    i = eventList(idx);

% for i = 1:size(b, 1)
    x = [b(i,1), b(i, 1), nan, b(i,2), b(i,2)];
    y = max(pb) * [0 1 nan 1 0];
    
    title(ax(1), sprintf('%d', i), 'FontSize', 16);
    set(ax,'XLim', mean(b(i,:)) + [-.25 .25])
    set(l, 'XData', x, 'YData', y);
    
    pause;
    
end