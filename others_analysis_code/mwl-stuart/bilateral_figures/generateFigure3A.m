function generateFigure3_2A
open_pool;
%% SHOW THE RAW RIPPLES AND MUA

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Prepare the data for plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
%%%%% SLEEP %%%%%
dSleep = dset_load_all('spl11', 'day14', 'sleep2');
eeg = dSleep.eeg; 
clear dSleep;

mu = load_exp_mu('/data/spl11/day14', 'sleep2');
c = dset_exp_load_clusters('/data/spl11/day14', 'sleep2');

ts = dset_calc_timestamps(eeg(1).starttime, numel(eeg(1).data), eeg(1).fs);

muRate = histc(mu, ts) / mean(diff(ts));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Plot The Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('fig3_2A', 'var'), if ishandle(fig3_2A), close(fig3_2A); end; end;

fig3_2A = figure('Position', [650 50  700 354]);
ax3_2A(1) = axes('Position', [.13 .5 .775 .4]);
ax3_2A(2) = axes('Position', [.13 .05 .775 .4]);

xlim = [5850.3 5850.85];
plotIdx = find(ts >= xlim(1) & ts <= xlim(2));
muRateSm = smoothn(muRate, 6);

X = [ts(plotIdx(1)), ts(plotIdx), ts(plotIdx(end))];
Y = [0, muRateSm(plotIdx), 0];
p = patch(X, Y, 'b', 'Parent', ax3_2A(1)); 
l = line(ts(plotIdx), 3*eeg(1).data(plotIdx) + 10000, 'Color', 'k', 'Parent', ax3_2A(1));

stAll = {c.st};
% nSpike = cellfun(@numel, stAll);
% [~, cIdx] = sort(nSpike,'descend');

%st = stAll( cIdx( 34 - [11 16 19 22 25 26 29 31 33] ) );
st = stAll([5     2    31    27    18    20    21    29    16]);

rp = rasterplot( st, ax3_2A(2));
set(ax3_2A, 'Xlim', xlim, 'YTick', []);
xlabel('Time (s)');


%%
save_bilat_figure('figure3-2A2', fig3_2A);


end

