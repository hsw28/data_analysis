function lin_pos = linearize_section(xpos, ypos, p1, p2, varargin)

args.plot_track = false;

args = parseArgs(varargin, args);

mx = mean(xpos(~isnan(xpos)));
my = mean(ypos(~isnan(ypos)));

xpos = xpos-mx;
ypos = ypos-my;

%xi = 50:1:280;
%yi = slope*xi+intercept;

%theta = -1*atan(yi/xi);
dx = p2(1) - p1(1) ;
dy = p2(2) - p1(2);
theta = atan2(dy,dx);

disp(360*theta/(2*pi))
%{
if (0<=theta && theta<=)
   theta = theta-pi;
end
%}
disp(360*theta/(2*pi))
    

x_rot = cos(theta).*xpos - sin(theta).*ypos;
%y_rot = sin(theta).*xpos + cos(theta).*ypos;

x_rot = x_rot-min(x_rot);
lin_pos = x_rot;

if(args.plot_track)
    f1 = figure;
    plot(xpos, ypos)
    response = inputdlg('How long is the displayed section of track (in meters)?');
else
    response = inputdlg('How long is the track/section (in meters)?');
end

if exist('f1', 'var') && ishandle(f1)
    close(f1);
end
if isempty(response) || strcmp(response{1}, '')
    track_len = 1;
    disp('No track length given assuming 1 meter');
else
    track_len = str2double(response{1});
end

lin_pos = (lin_pos-min(lin_pos));
lin_pos = lin_pos*track_len/max(lin_pos);


end