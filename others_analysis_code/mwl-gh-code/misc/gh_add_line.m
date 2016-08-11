function [fig gh_add_line_opt] = gh_add_line(x,y,varargin)

% fig = gh_add_line(x, y, varargin)
%
% GH_ADD_LINE adds a line plot to gcf
%
% -x,y are data pairs to plot
% -xlim, ylim are the [xmin xmax],[ymin ymax] of the little axes
% -pos are the x,y coordinates of mother plot where we'll draw the plot
% center
% -plot_size is [width height] in mother plot units of the little axes
% -MarkerFaceColor, MarkerEdgeColor are passed to plot
% -MarkerSize is also passed to plot
% -plot_format_string is passed to plot
% -bar produced a bar chart instead of line (for histograms)
% -clip_extremes drops points outside the xlim,ylim bounding box
% -plot_xy_axes plots x and y axes, if they are in the view
% 
% Example:

p = inputParser;
p.addParamValue('xlim',[min(x),max(x)]);
p.addParamValue('ylim',[min(y),max(y)]);
p.addParamValue('pos',[0 0]);
p.addParamValue('plot_size',[1,1]);
p.addParamValue('plot_format_string','-');
p.addParamValue('Color',[0 0 1]);
p.addParamValue('MarkerFaceColor',[0 0 1]);
p.addParamValue('MarkerEdgeColor',[0 0 0]);
p.addParamValue('MarkerSize',2);
p.addParamValue('fig',gcf);
p.addParamValue('bar',false);
p.addParamValue('plot_xy_axes',true);
p.addParamValue('clip_extremes',true);
p.addParamValue('gh_add_line_opt',[]);
p.parse(varargin{:});
opt = p.Results;
if(~isempty(opt.gh_add_line_opt))
    opt = opt.gh_add_line_opt;
end
gh_add_line_opt = opt.gh_add_line_opt;

width_mother_coords = opt.plot_size(1);
height_mother_coords = opt.plot_size(2);
width_little_coords = diff(opt.xlim);
height_little_coords = diff(opt.ylim);
width_little_to_big = width_mother_coords/width_little_coords;
height_little_to_big = height_mother_coords/height_little_coords;


x_mc = (x-mean(opt.xlim,2)) .* width_little_to_big + opt.pos(1); % x's is mother coordinates
y_mc = (y-mean(opt.ylim,2)) .* height_little_to_big + opt.pos(2); % y's in mother coordinates

if(~opt.bar)
    if(opt.plot_xy_axes)
        if(and(opt.xlim(1) <= 0, opt.xlim(2) >= 0))
            yaxis_ys = opt.pos(2) + opt.plot_size(2).*[-1/2, 1/2];
            yaxis_xs = (0 - mean(opt.xlim,2)) .* width_little_to_big + opt.pos(1);
            plot([yaxis_xs,yaxis_xs],yaxis_ys,'-');
        end
        if(and(opt.ylim(1) <= 0, opt.ylim(2) >= 0))
            xaxis_xs = opt.pos(1) + opt.plot_size(1).*[-1/2 1/2];
            xaxis_ys = (0- mean(opt.ylim,2)) .* height_little_to_big + opt.pos(2);
            plot(xaxis_xs,[xaxis_ys, xaxis_ys],'-');
        end
    end
    plot(x_mc,y_mc,opt.plot_format_string,'Color', opt.Color,'MarkerFaceColor',opt.MarkerFaceColor,'MarkerEdgeColor',opt.MarkerEdgeColor,...
        'MarkerSize',opt.MarkerSize);
else
    error('bar not implemented yet.');
end