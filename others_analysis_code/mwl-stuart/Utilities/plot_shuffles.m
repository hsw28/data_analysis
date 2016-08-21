function a = plot_shuffles(shuffleDist, stat, titles)
%% PLOT_SHUFFLES - a simple function that plots a histogram shuffle statistics compared the actual stat
%
% shuffleDist can be a vector of samples, or a cell array containing
% vectors of samples
% stats is a scalar

if nargin==2
    titles = repmat({' '}, numel(stat), 1);
end

if ~isvector(shuffleDist)
    error('ShuffleDist must be a vector, or a cell-array vector');
end

if nargin<2 || isempty(stat)
    error('The test statistic must be provided');
end

numel(shuffleDist) == numel(stat)

if iscell(shuffleDist) && numel(shuffleDist) ~= numel(stat)
    error('A test statistic for each distribution must be provided');
elseif ~iscell(shuffleDist) && ~isscalar(stat) 
    error('A single test statistic should be provided');
end

if ~iscell(shuffleDist)
    shuffleDist = {shuffleDist};
end

if ~all( cellfun(@isvector, shuffleDist))
    error('Shuffle distributions must be vectors');
end

nDist = numel(shuffleDist);

a = zeros(nDist, 1);
figure;
for i = 1:nDist;
    a(i) = subplot(nDist, 1, i);
    nBins = round (sqrt( numel( shuffleDist{i} )));
    bins = linspace( min( shuffleDist{i}), max( shuffleDist{i}), nBins);
    
    h = histc(shuffleDist{i}, bins);
    
    bar(bins, h, 1, 'Parent', a(i));
    
    ylim = get(a(1), 'YLim');
    
    line( [stat(i) stat(i)], ylim, 'color', 'r', 'linewidth', 2);
    title(titles{i});
end

set(a,'Xlim', [-.2 .8]);