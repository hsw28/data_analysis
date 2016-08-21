function [lin_pos nodes] = linearize_complex_track(xpos, ypos)
% LINEARIZE_CUSTOM_TRACK(xpos,ypos)
%
% A simple gui to subdivide a complex multi-trajectory track into a linear
% environment.
% linear_position is returned which ranges from 0 to x meters with x being
% the user specified length
%
% Order of Operations
%   1- Display all available points
%   2- Cut out desired trajectory
%   3- Linearize sub trajectory
%   4- Append linearized trajectory to current trajectory
%   5- Done?
%       no - Go to step 1
%       yes- End

rx = xpos; 
ry = ypos;
r_ind = 1:length(xpos);
lin_pos = nan(size(r_ind));

more = 'Yes';
nodes = [];
nnodes = 0;
while strcmp(more, 'Yes');
    [sx, sy, s_ind, rx, ry, r_ind] = select_trajectory_points(rx, ry, r_ind);
    lin_pos_sel = linearize_sub_track(sx, sy);
% 
%     disp('s_ind,    lin_pos,  sx,  sy');
%     disp([size(s_ind), size(lin_pos_sel), size(sx), size(sy)]);

    mp = max(lin_pos);
    if isnan(mp)
        lin_pos(s_ind) = lin_pos_sel;
    else
        lin_pos_sel = lin_pos_sel + mp;
        lin_pos(s_ind) = lin_pos_sel;
        nnodes=nnodes+1;
        nodes(nnodes) = mp; %#ok
    end
     
    more = questdlg('Select another subregion of track?');
    close(gcf);
end
% 
% response = inputdlg('What is the total length of the track in meters?');
% if isempty(response) || strcmp(response{1}, '')
%     track_len = 10;
%     disp('No track length given assuming 10 meters');
% else
%     track_len = str2double(response{1});
% end
% 
% nodes = nodes*track_len/max(lin_pos);
% lin_pos = (lin_pos-min(lin_pos));
% lin_pos = lin_pos*track_len/max(lin_pos);
end

function lin_pos = linearize_sub_track(xpos, ypos)

happy = 'No';
f = figure;
while ~strcmp(happy, 'Yes')
    cla;
    plot(xpos,ypos, 'g.');
    title('Draw the polyline');
    pline = getpolyline('axes', gca(), 'spline', 1); hold on;

    points = spcrv(pline.nodes', 3, 10000);
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
line_len = [0, line_len]; % pad the array

d_tri = delaunay(points(1,:), points(2,:));
lin_pos = dsearch(points(1,:), points(2,:), d_tri, xpos, ypos);

ind = ~isnan(lin_pos);

lin_pos(ind) = line_len(lin_pos(ind)); % convert from delauney point to actuall distance
lin_pos(~ind) = nan; 

lin_pos = lin_pos - min(lin_pos);

lin_pos = lin_pos.* (max(line_len) ./ max(lin_pos));
%disp(['Min:',  num2str(min(lin_pos)), ' Max:', num2str(max(lin_pos))]);
end

function [sel_x, sel_y, s_ind, rem_x, rem_y, r_ind] = select_trajectory_points(xpos, ypos, pos_ind)
    f_sel = figure();
    
    a = axes('Units', 'Normalized', 'Position', [0.01, .075, .98, .915],...
        'XTick', [], 'YTick', [], 'Box', 'on');
    plot(xpos, ypos, '.')
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