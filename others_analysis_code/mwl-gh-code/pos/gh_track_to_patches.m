function track_patches = gh_track_to_patches(track_points,varargin)
%  GH_TRACK_TO_PATCHES construct patch boundaries around
%  a list of x,y track points
%
%   track_points:  x positions of track positions in row 1
%                             y positions in row 2
%  pass 'width', w   -> set block width to w for straight-line tracks
%  pass 'fill_fraction', f  -> shrink patch edges toward track points
%        by (1-f)/(track_point to patch_point distance)
% pass 'test_plot', true -> draw the results make sure they look right
%
% Rationale: Linear tracks with bends are described as 2d spline:
%   seg = 1,2,3,...,100
%   x     = 0, 0.1, 0.2, ... 0.9, 1.0, 0.9, 0.8, ..., 0.0
%   y     =  0, 0.1, 0.2, .... 0.9, 1.0
%  This track has a backwards C shape.
%  If we plot(x,y), we get a C line.
%  But sometimes I don't want to see a C line, I want a 
%  series of boxes along the C whichI can fill with colors,
% to indicate where the rat is or to show the results of
% a reconstruction, or to plot some parameter as a function
% of track location, plotted at the original 2d positions, 
% not the linearized 

p = inputParser();
p.addParamValue('width',1);
p.addParamValue('fill_fraction',[]);
p.addParamValue('test_plot',false);
p.addParamValue('pos_info', []);
p.parse(varargin{:});
opt = p.Results;

% strategy - between each pair of track points, find the midpoint.
% draw a line width w, centered on that midpoint, perpendicular
% to the line connecting the pair of points.

% the patch centered on a track-point is composed of the top- and
% bottom-points of the preceding midpoint line, and the top- and
% bottom-points of the following midpoint line

% use imaginary plane so that angles 180 deg apart aren't ambiguous
% we need all 360 degrees to be unique or we risk mixing up 'top'
% and 'bottom' of these midpoint-lines.

% The first and last track points have no preceding and following
% midpoints.  Treat the point itself as the 'midpoint'.  Use the 
% next or previous midpoint's slope as this 'midpoint's slope

% First, if trackpoints isn't provided, figure them out from opt.pos_info
%if(isempty(track_points))
 %   track

n_trackpoints = size(track_points,2);

% patch_points - formatted for use with patch(x,y,c)
% independent faces are in different columns
x_patch_points = NaN .* zeros(4, n_trackpoints);
y_patch_points = NaN .* zeros(4, n_trackpoints);

x_trackpoints = track_points(1,:);
y_trackpoints = track_points(2,:);

x_diffs = diff(x_trackpoints);
y_diffs = diff(y_trackpoints);

x_midpoints = x_trackpoints(1:(end-1)) + x_diffs/2;
y_midpoints = y_trackpoints(1:(end-1)) + y_diffs/2;

% determine the angles of lines centered on the midpoints
%  and oriented 90 degrees counterclockwise from the
%  line between previous trackpoint and next trackpoint
midpoint_angles = angle( x_diffs + i .* y_diffs ) + pi/2;

% For the first and last track_point, add:
%  x_midpoints
%  y_midpoints
%  midpoint_angles
x_midpoints = [x_trackpoints(1), ...
                            x_midpoints,...
                            x_trackpoints(end)];
y_midpoints = [y_trackpoints(1),...
                            y_midpoints,...
                            y_trackpoints(end)];
midpoint_angles = [midpoint_angles(1),...
                                    midpoint_angles,...
                                    midpoint_angles(end)];
                                
% get the coordinates for the 'midpoint lines'
midpoint_line_x_top = x_midpoints + ...
    opt.width./2 * cos(midpoint_angles);

midpoint_line_x_bottom = x_midpoints - ...
    opt.width./2 .* cos(midpoint_angles);

midpoint_line_y_top = y_midpoints + ...
    opt.width./2 * sin(midpoint_angles);

midpoint_line_y_bottom = y_midpoints - ...
    opt.width./2 * sin(midpoint_angles);

% assign the ends of the midpoint lines into 
% the right spots in the patch_points array

% first column of x_patch_points - the x values for the first patch
% I'll choose points in this order: 
%  1) previous midpoint line's upper side
%  2) previous midpoint line's lower side
%  3) next midpoint line's lower side
%  4) next midpoint line's upper side
% Tracing along this sequence gives the quadrilateral
%  with no 'bowtie' twist in the middle.

x_patch_points = [midpoint_line_x_top(1:(end-1)); ...
                                  midpoint_line_x_bottom(1:(end-1));...
                                  midpoint_line_x_bottom(2:end);...
                                  midpoint_line_x_top(2:end)];
                              
y_patch_points = [midpoint_line_y_top(1:(end-1));...
                                  midpoint_line_y_bottom(1:(end-1));...
                                  midpoint_line_y_bottom(2:end);...
                                  midpoint_line_y_top(2:end)];
                              
                              
if(opt.test_plot)
    plot(track_points(1,:), track_points(2,:),'.');
    hold on;
    c = linspace(1,2, n_trackpoints);
    patch(x_patch_points, y_patch_points,c);
    for n = 1:(n_trackpoints+1)
        plot([midpoint_line_x_top(n)],...
                [midpoint_line_y_top(n)],'.b');
            plot([midpoint_line_x_bottom(n)],...
                [midpoint_line_y_bottom(n)],'.r');
    end
end

track_patches.x = x_patch_points;
track_patches.y = y_patch_points;