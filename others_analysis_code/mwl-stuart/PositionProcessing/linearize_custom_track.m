function lin_pos = linearize_custom_track(xpos, ypos)
% LINEARIZE_CUSTOM_TRACK(xpos,ypos)
%
% A simple gui to draw splines and calculate the linear version of a
% "non-linear" 1 dimensional track.  The user is prompted for the track
% length.
%
% linear_position is returned which ranges from 0 to x meters with x being
% the user specified length

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
dz = (dx.^2 + dy.^2).^.5;
line_len = max(cumsum(dz));
line_len = [0, line_len]; % pad the array

d_tri = delaunay(points(1,:), points(2,:));
lin_pos = dsearch(points(1,:), points(2,:), d_tri, xpos, ypos);

ind = ~isnan(lin_pos);

lin_pos(ind) = line_len(lin_pos(ind)); % convert from delauney point to actuall distance
lin_pos(~ind) = nan; 

lin_pos = lin_pos - min(lin_pos);

lin_pos = lin_pos.* (max(line_len) ./ max(lin_pos));
response = inputdlg('How many meters long is the track?');
if isempty(response) || strcmp(response{1}, '')
    track_len = 1;
    disp('No track length given assuming 1 meter');
else
    track_len = str2double(response{1});
end

lin_pos = (lin_pos-min(lin_pos));
lin_pos = lin_pos*track_len/max(lin_pos);



