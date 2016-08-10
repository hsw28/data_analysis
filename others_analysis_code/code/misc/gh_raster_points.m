function [xs,ys] = gh_raster_points(times,varargin)
p = inputParser();
p.addParamValue('y_range',[0 1])
p.parse(varargin{:});
opt = p.Results;

nt = length(times);
xs = NaN.*ones(1,3*nt);
ys = NaN.*ones(1,3*nt);
xs([0:(nt-1)]*3+1) = times;
xs([0:(nt-1)]*3+2) = times;
ys([0:(nt-1)]*3+1) = opt.y_range(1);
ys([0:(nt-1)]*3+2) = opt.y_range(2);
