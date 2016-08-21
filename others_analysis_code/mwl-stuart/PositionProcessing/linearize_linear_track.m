function lin_pos = linearize_linear_track(xpos, ypos)

f = figure;
plot(xpos,ypos, 'r.');
title('Please draw the polyline representing this track');
nodes = getline(f);
waitfor(nodes);
close(gcf)
p1 = nodes(1,:);
p2 = nodes(2,:);

lin_pos = linearize_section(xpos, ypos, p1, p2);
