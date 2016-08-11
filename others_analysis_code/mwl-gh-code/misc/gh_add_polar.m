function fig = gh_add_polar(theta,r,varargin)

% fig = gh_add_polar(theta, r, varargin)
%
% GH_ADD_POLAR adds a polar histogram to gcf
%
% -theta is the vector of angle bin edges
% -r is the vector of values in those bins
% -max_r is the radius for the largest r value
% -pos is an [x,y] coordinate for the polar hist center
% -color is the color for the circular distribution patch
% -fig is the figure to draw on
% -plot_circ_hist is an option for plotting the circular distribution
% -plot_circ_mean is an option for plotting the circular mean
% -circ_mean_has_magnitude is an option for putting an r value on the circ mean
% 
% Example:
% gh_add_polar([-pi:1/20:pi],1+cos([-pi:1/20:pi]),'max_r',0.1,'pos',[2,3]);
% Adds to the current plot a funny looking polar plot.  Circuar hist data
% is usually given.

p = inputParser();
p.addParamValue('max_r',max(r),@isreal);
p.addParamValue('pos',[0 0],@isreal);
p.addParamValue('color',[0 1 0]);
p.addParamValue('fig',gcf);
p.addParamValue('plot_circ_mean',true,@islogical);
p.addParamValue('plot_circ_hist',true,@islogical);
p.addParamValue('circ_mean_has_magnitude',false,@islogical);
p.parse(varargin{:});
opt = p.Results;

scale_factor = opt.max_r/max(r);
%scale_factor = 0.001;

% append first theta and r to end, to close the circle
r = [r,r(1)];
theta = [theta,theta(1)];

xs = r.*cos(theta).*scale_factor + opt.pos(1);
ys = r.*sin(theta).*scale_factor + opt.pos(2);

figure(opt.fig);

if(opt.plot_circ_hist)
    patch(xs,ys,opt.color);
    hold on;
    plot(opt.pos(1),opt.pos(2),'k.');
end

if(p.Results.plot_circ_mean)
    xs = r.*cos(theta);%.*scale_factor
    ys = r.*sin(theta);%.*scale_factor
    x = mean(mean(xs(1:end-1)));
    y = mean(mean(ys(1:end-1)));
    if(not(opt.circ_mean_has_magnitude))
        a = angle([x + i*y]);
        x = opt.max_r * cos(a);
        y = opt.max_r * sin(a);
    end
    xs = [opt.pos(1), opt.pos(1) + x];
    ys = [opt.pos(2), opt.pos(2) + y];
    plot(xs,ys,'-','LineWidth',1);
    hold on;
    plot(opt.pos(1),opt.pos(2),'ko');
end
    