function a = accel(file1);

%computes acceleration. input a [2, #of points] vector, where first column is velcotiy, second is time
%
% returns acceleration per ms and time stamp vector
% doesn't smooth or transform-- do that later when you assign velocities

file = file1';

vel = file(1, :);
tm = file(2, :);

a = diff(vel, tm);


