function f = arte_time_plots()

slowPath = '~/Documents/RetroProject/thesis/rawFigs/laptopRunTS.mat';
fastPath = '~/Documents/RetroProject/thesis/rawFigs/decoding.mat';

load(slowPath);
ts0 = tsGoal(ts);
subplot(2,1,1);
plotOS(ts0, ts - ts0);
ylim([0,1]);

load(fastPath);
ts0 = tsGoal(ts);
subplot(2,1,2);
plotOS(ts0, ts - ts0);
ylim([0,0.12]);
end

% Downsample for smaller svg
% Meh, nevermind
function plotOS(xs,ys)
    p = 5;  % 5 percent
    w = 200;
    keep = rand(size(xs)) <= p/100;  % keep p % of the points
    keep(1:w) = 1;                   % also keep the first
    keep((end-w):end) = 1;            % and last w points
    plot(xs(keep),ys(keep));
end

function ts0 = tsGoal(ts)

   ts0 = [4492:0.02:8000]; % Very caillou/112812 specific
   ts0 = ts0(1:numel(ts));

end