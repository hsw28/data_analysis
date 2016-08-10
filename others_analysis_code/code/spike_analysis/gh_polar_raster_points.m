function [xs,ys] = gh_polar_raster_points(angles,varargin)
% [xs,ys] = GH_POLAR_RASTER(angles,varargin) returns x,y coords for tic marks at spike
% angles
%
% optional args:
% r_range [0 1]: radius-start and radius-end for tic marks
% center [0 0]:  offset in x,y coords for the tics
% circle_r []: specify a value and xs,ys will include points on a circle
% angle_offset [0]: zero radians corresponds to pointing-right.  Use
% radians here to add an offset (pass pi/2 to make 0 radians point straight
% up

p = inputParser();
p.addParamValue('r_range',[0 1]);
p.addParamValue('center',[0 0]);
p.addParamValue('circle_r',[]);
p.addParamValue('angle_offset',0);
p.addParamValue('color',[]);

p.parse(varargin{:});
opt = p.Results;

xs = NaN.*zeros(1,3*length(angles));
ys = NaN.*zeros(1,3*length(angles));

ind1 = [0:length(angles)-1].*3 + 1;
ind2 = [0:length(angles)-1].*3 + 2;

xs(ind1) = (opt.r_range(1).*(cos(angles) + opt.angle_offset) + opt.center(1));
xs(ind2) = (opt.r_range(2).*(cos(angles) + opt.angle_offset) + opt.center(1));
ys(ind1) = (opt.r_range(1).*(sin(angles) + opt.angle_offset) + opt.center(2));
ys(ind2) = (opt.r_range(2).*(sin(angles) + opt.angle_offset) + opt.center(2));

if(~isempty(opt.circle_r))
    n_circ_points = 200; % this should usually be smooth enough
    theta = [linspace(0,2*pi,n_circ_points),0];
    r = opt.circle_r .* ones(size(theta));
    xs_c = r.*cos(theta);
    ys_c = r.*sin(theta);
    xs = [xs,xs_c];
    ys = [ys,ys_c];
end