
posfile


t = posfile(:,1);
x = posfile(:,2);
y = posfile(:,3);

fx = gradient(x);
fy = gradient(y);

% make a matrix of time, x, y, fx, fy
tfxfy = [t x y fx fy];

% go through and find times, assign fx fy values and position
% plot using quiver using subselected event specific x, y, fx, fy
% quiver(x, y, fx, fy);

