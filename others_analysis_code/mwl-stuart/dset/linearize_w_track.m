function [lp nodes] = linearize_w_track(pos, varargin)

args.cmperpixel = pos.cmperpixel;
args.bin_size = 1;
args = parseArgs(varargin, args);

rx = pos.x; 
ry = pos.y;
xpos = rx;
ypos = ry;

r_ind = 1:length(xpos);
lin_pos = [];%nan(size(r_ind));

more = 'Yes';
nodes = [];
nnodes = 0;

lp.paths.c2l = nan(size(xpos));
lp.paths.c2r = nan(size(xpos));
lp.paths.l2r = nan(size(xpos));

% Linearize the center arm
[sx, sy, sind_center, rx, ry, r_ind] = select_trajectory_points(rx, ry, xpos, ypos, r_ind, 'Select the CENTER arm');
lp_center_arm = round( (linearize_sub_track(sx, sy) * args.cmperpixel) * args.bin_size ) / args.bin_size;

lp.total(sind_center) = lp_center_arm;

% Linearize the left arm
[sx, sy, sind_left, rx, ry, r_ind] = select_trajectory_points(rx, ry, xpos, ypos, r_ind, 'Select the LEFT arm');
lp_left_arm = round( (linearize_sub_track(sx, sy) * args.cmperpixel) *args.bin_size ) /args.bin_size;
lp.total(sind_left) = lp_left_arm + max(lp_center_arm);

% Linearize the right arm
[sx, sy, sind_right, rx, ry, r_ind] = select_trajectory_points(rx, ry, xpos, ypos, r_ind, 'Select the RIGHT arm');
lp_right_arm = round( (linearize_sub_track(sx, sy) * args.cmperpixel) *args.bin_size ) /args.bin_size;
lp.total(sind_right) = lp_right_arm + max(lp_center_arm) + max(lp_right_arm);

lp.segment_lengths.c = max(lp_center_arm);
lp.segment_lengths.l = max(lp_left_arm);
lp.segment_lengths.r = max(lp_right_arm);

lp.path_occupancy.c = sind_center;
lp.path_occupancy.l = sind_left;
lp.path_occupancy.r = sind_right;

%build the trajectory specific sub spaces
lp.paths.c2l(sind_center) = lp_center_arm;
lp.paths.c2l(sind_left) = lp_left_arm + lp.segment_lengths.c;

lp.paths.c2r(sind_center) = lp_center_arm;
lp.paths.c2r(sind_right) = lp_right_arm + lp.segment_lengths.c;

mean_left = mean(lp_left_arm);
lp.paths.l2r(sind_left) = (-1 * (lp_left_a
rm - mean_left) ) + mean_left;
lp.paths.l2r(sind_right) = lp_right_arm + lp.segment_lengths.l;

lp.segments.left = lp_left_arm;
lp.segments.center = lp_center_arm;
lp.segments.right = lp_right_arm;

lp.ts = pos.ts;
lp.samplerate = 30;

lp.units = 'cm';

lp.raw.x = pos.x;
lp.raw.y = pos.y;
end

function lin_pos = linearize_sub_track(xpos, ypos)

happy = 'No';
f = figure( 'Position', [400, 400, 560, 420]);
while ~strcmp(happy, 'Yes')
    cla;
    plot(xpos,ypos, 'g.');
    zoomaxes(gca,1.2);
    
    title('Draw the polyline');
    pline = getpolyline('axes', gca(), 'spline', 1); hold on;

    points = spcrv(pline.nodes', 3, 1000);
    plot(points(1,:), points(2,:), 'k', 'LineWidth', 3);
    happy = questdlg('Are you happy with the spline?', 'Are you Happy?', 'No');
    if strcmp(happy, 'Cancel')
        return;
    end
end
close(f);

dx = diff(points(1,:));
dy = diff(points(2,:));

dz = (dx.^2 + dy.^2).^.5; % get distance from one point to the next
line_len = cumsum(dz); % calculate total distance of the line
line_len = [0, line_len]; % prepend a 0 to the vector

% OLD METHOD --------------
% d_tri = delaunay(points(1,:), points(2,:));
% lin_pos = dsearch(points(1,:), points(2,:), d_tri, xpos, ypos);
% 
% ind = ~isnan(lin_pos);
% 
% lin_pos(ind) = line_len(lin_pos(ind)); % convert from delauney point to actuall distance
% lin_pos(~ind) = nan; 
% 
% lin_pos = lin_pos - min(lin_pos);


% New METHOD --------------
 DT = DelaunayTri(points(1,:)', points(2,:)');
 idx = DT.nearestNeighbor([xpos, ypos]);
 lin_pos = line_len(idx);
 lin_pos = lin_pos - min(lin_pos);
 


%lin_pos = lin_pos.* (max(line_len) ./ max(lin_pos));
%disp(['Min:',  num2str(min(lin_pos)), ' Max:', num2str(max(lin_pos))]);
end

function [sel_x, sel_y, s_ind, rem_x, rem_y, r_ind] = select_trajectory_points(xpos, ypos, old_x, old_y, pos_ind, title)
    f_sel = figure('NumberTitle', 'off', 'Name', title, 'Position', [400, 400, 560, 420] );
    
    a = axes('Units', 'Normalized', 'Position', [0.01, .075, .98, .915],...
        'XTick', [], 'YTick', [], 'Box', 'on');
    line(old_x, old_y, 'color', [.7, .7, .7], 'marker', '.', 'linestyle', 'none');
    line(xpos, ypos, 'marker', '.', 'linestyle', 'none');
    
    %plot(xpos, ypos, '.')
    zoomaxes(gca, 1.2);
    [nodes] = draw_dynamic_polygon(a);
    
    polyx = nodes(1,:);
    polyy = nodes(2,:);
 
    close(f_sel);

    s_ind = inpolygon(xpos, ypos, polyx, polyy);
    r_ind = ~s_ind;

    sel_x = xpos(s_ind);
    sel_y = ypos(s_ind);

    rem_x = xpos(r_ind);
    rem_y = ypos(r_ind);
    
    s_ind = pos_ind(s_ind);
    r_ind = pos_ind(r_ind);
end