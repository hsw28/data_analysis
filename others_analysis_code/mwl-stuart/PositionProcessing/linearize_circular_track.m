function pos = linearize_circular_track(xpos, ypos)

f = figure;
plot(xpos,ypos, 'r.'); hold on;
title('Define the edges, middle click to start over, right click to close');
a = gca();
grid('minor');

[center radius]=draw_circular_track(a);

close(f);

xpos = xpos - center(1);
ypos = ypos - center(2);

f = figure; 
plot(xpos, ypos, 'r.');
title('left click on the 0-2pi boundry, right click when done');
node = getpolyline('axes', gca());
x = node.nodes(1,1);
y = node.nodes(1,2);
hold on;
plot([0, x], [0,y]);
pause(1);
close(f)
theta_adj = atan2(y,x);

theta = atan2(ypos, xpos);

theta = theta-theta_adj; 
theta(find(theta<0)) = theta(find(theta<0))+2*pi;

answer = inputdlg('What is the diameter of this track (in meters)?');
diam = str2double(answer);

pos = theta*diam/(2);

disp('Track Length is in DEGREES not in METERS FIX THIS');
