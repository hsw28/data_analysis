function [xs,ys] = gh_sdat_raster_points(sdat,varargin)

p = inputParser();
p.addParamValue('y_range',[0 1]);
p.parse(varargin{:});
opt = p.Results;

n_cells = numel(sdat.clust);
range_diff = diff(opt.y_range);
dp = range_diff/n_cells;
xs = [];
ys = [];

for n = 1:n_cells
    this_times = sdat.clust{n}.stimes;
    this_range = [opt.y_range(1)+dp*(n-1),...
        opt.y_range(1) + dp*(n)];
    [this_xs, this_ys] = gh_raster_points(this_times, 'y_range',this_range);
    xs = [xs, this_xs];
    ys = [ys, this_ys];
end